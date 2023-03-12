import 'dart:developer';

import 'package:mongo_dart/mongo_dart.dart';
import 'package:my_pensieve/models/base.dart';
import 'package:my_pensieve/models/device_sync.dart';
import 'package:my_pensieve/models/hive/local_sync.dart';
import 'package:my_pensieve/repositories/hive/local_sync_repository.dart';
import 'package:my_pensieve/repositories/mongo_repository.dart';
import 'package:my_pensieve/repositories/sqlite/sync_repository.dart';
import 'package:my_pensieve/utils/device_info.dart';

class SyncService<T extends SyncRepository?> {
  late SyncRepository _syncRepository;
  late LocalSyncHiveRepository _localSyncHiveRepository;
  late MongoRepository _mongoRepository;
  final String? _collection;

  SyncService([this._collection, T Function()? creator]) {
    if (creator != null) {
      _syncRepository = creator()!;
    }
    _localSyncHiveRepository = LocalSyncHiveRepository();
    _mongoRepository = MongoRepository();
  }

  Future<void> syncUpload(String userId) async {
    final String deviceId = await DeviceUtil.deviceId;

    try {
      await _localSyncHiveRepository.open(_localSyncHiveRepository.boxName);

      final LocalSyncHive unsyncObjects =
          _localSyncHiveRepository.findByObject(_collection!);

      List<String>? added = unsyncObjects.added;
      List<String>? updated = unsyncObjects.updated;
      List<String>? deleted = unsyncObjects.deleted;

      await _mongoRepository.open();

      // Notify cloud before upload (for non-current devices)
      await _notifyAnotherDevices(userId, added, updated, deleted, deviceId);

      _syncRepository.init();

      // Upload
      await _uploadAddedItems(userId, added);

      await _uploadUpdatedItems(userId, updated);

      await _uploadDeletedItems(userId, deleted);
    } catch (error, stack) {
      log('Error: $error');
      log('StackTrace: $stack');
    } finally {
      await _mongoRepository.close();

      try {
        // Update sync for local hive
        await _updateLocalHive();
      } catch (error, stack) {
        log('Error: $error');
        log('StackTrace: $stack');
        rethrow;
      } finally {
        await _localSyncHiveRepository.close();
      }
    }
  }

  Future<void> syncDownload(String userId) async {
    final String deviceId = await DeviceUtil.deviceId;

    try {
      await _mongoRepository.open();

      List<Map<String, dynamic>> unsyncObjects =
          await _mongoRepository.find(LocalSync.collection, {
        BaseClass.fUserId: userId,
        LocalSync.fDevice: deviceId,
        LocalSync.fObject: _collection,
      });

      if (unsyncObjects.isNotEmpty) {
        List<String> added = unsyncObjects[0][LocalSync.fAdded] != null
            ? List<String>.from(unsyncObjects[0][LocalSync.fAdded]).toList()
            : [];
        List<String> updated = unsyncObjects[0][LocalSync.fUpdated] != null
            ? List<String>.from(unsyncObjects[0][LocalSync.fUpdated]).toList()
            : [];
        List<String> deleted = unsyncObjects[0][LocalSync.fDeleted] != null
            ? List<String>.from(unsyncObjects[0][LocalSync.fDeleted]).toList()
            : [];

        _syncRepository.init();

        await _downloadAddedItems(userId, added);

        await _downloadUpdatedItems(userId, updated);

        await _downloadDeletedItems(deleted);
      }
    } catch (error, stack) {
      log('Error: $error');
      log('StackTrace: $stack');
    } finally {
      try {
        // Remove in cloud sync collection
        await _removeFromCloudForThisDevice(userId, deviceId);
      } catch (error, stack) {
        log('Error: $error');
        log('StackTrace: $stack');
        rethrow;
      } finally {
        await _mongoRepository.close();
      }
    }
  }

  Future<void> initCloudObjects(
      String userId, List<String> objectCollections) async {
    try {
      await _mongoRepository.open();
      await _localSyncHiveRepository.open(_localSyncHiveRepository.boxName);
      final String deviceId = await DeviceUtil.deviceId;

      for (var coll in objectCollections) {
        await _initCloud(userId, deviceId, coll);

        await _initLocal(coll);
      }
    } catch (error, stack) {
      log('Error: $error');
      log('StackTrace: $stack');
    } finally {
      await _mongoRepository.close();
      await _localSyncHiveRepository.close();
    }
  }

  Future<void> _initCloud(
      String userId, String deviceId, String collection) async {
    List<Map<String, dynamic>> currentDeviceWithObjectCloudSync =
        await _mongoRepository.find(LocalSync.collection, {
      BaseClass.fUserId: userId,
      LocalSync.fDevice: deviceId,
      LocalSync.fObject: collection,
    });

    if (currentDeviceWithObjectCloudSync.isEmpty) {
      // Find all items from cloud
      List<Map<String, dynamic>> cloudItems =
          await _mongoRepository.find(collection, {
        BaseClass.fUserId: userId,
      });

      List<String> ids = [];
      for (var element in cloudItems) {
        ids.add((element[BaseClass.fId] as ObjectId).$oid);
      }

      // Add new device with object to cloud
      await _mongoRepository.insertOne(
        LocalSync.collection,
        {
          BaseClass.fUserId: userId,
          LocalSync.fDevice: deviceId,
          LocalSync.fObject: collection,
          LocalSync.fAdded: ids,
        },
      );
      currentDeviceWithObjectCloudSync =
          await _mongoRepository.find(LocalSync.collection, {
        LocalSync.fDevice: deviceId,
        LocalSync.fObject: collection,
      });
    }
  }

  Future<void> _initLocal(String coll) async {
    await _localSyncHiveRepository.addData(coll, {
      LocalSync.fAdded: <String>[],
      LocalSync.fUpdated: <String>[],
      LocalSync.fDeleted: <String>[],
    });
  }

  Future<void> _notifyAnotherDevices(String userId, List<String>? added,
      List<String>? updated, List<String>? deleted, String deviceId) async {
    Map<String, dynamic> nonCurrentDeviceCondition = {
      '\$and': [
        {
          BaseClass.fUserId: userId,
          LocalSync.fDevice: {
            '\$nin': [deviceId]
          },
        }
      ]
    };
    List<Map<String, dynamic>> nonCurrentDevicesCloudSync =
        await _mongoRepository.find(
            LocalSync.collection, nonCurrentDeviceCondition);

    // Change fields for non-current devices
    for (var device in nonCurrentDevicesCloudSync) {
      List<String> newAdded = device[LocalSync.fAdded] != null
          ? List.from(device[LocalSync.fAdded])
          : [];

      if (newAdded.isNotEmpty) {
        if (added != null && added.isNotEmpty) {
          newAdded.addAll(added);
        }
      } else {
        newAdded = added ?? [];
      }

      List<String> newUpdated = device[LocalSync.fUpdated] != null
          ? List.from(device[LocalSync.fUpdated])
          : [];
      if (newUpdated.isNotEmpty) {
        if (updated != null && updated.isNotEmpty) {
          newUpdated.addAll(updated);
        }
      } else {
        newUpdated = updated ?? [];
      }

      List<String> newDeleted = device[LocalSync.fDeleted] != null
          ? List.from(device[LocalSync.fDeleted])
          : [];
      if (newDeleted.isNotEmpty) {
        if (deleted != null && deleted.isNotEmpty) {
          newDeleted.addAll(deleted);
        }
      } else {
        newDeleted = deleted ?? [];
      }
      await _mongoRepository.replaceOne(
        LocalSync.collection,
        {
          LocalSync.fDevice: device[LocalSync.fDevice],
          LocalSync.fObject: _collection,
        },
        {
          LocalSync.fAdded: newAdded,
          LocalSync.fUpdated: newUpdated,
          LocalSync.fDeleted: newDeleted,
        },
      );
    }
  }

  Future<void> _uploadAddedItems(String userId, List<String>? added) async {
    if (added != null && added.isNotEmpty) {
      List objects = await _syncRepository.syncFindAllByIds(added);
      // Insert
      List<Map<String, dynamic>> maps = [];
      for (var element in objects) {
        maps.add((element as BaseClass).toMap(userId));
      }
      // Execute upload added data
      await _mongoRepository.insertAll(_collection!, maps);
    }
  }

  Future<void> _uploadUpdatedItems(String userId, List<String>? updated) async {
    if (updated != null && updated.isNotEmpty) {
      List objects = await _syncRepository.syncFindAllByIds(updated);
      for (var element in objects) {
        await _mongoRepository.replaceOne(
          _collection!,
          {
            BaseClass.fId: ObjectId.parse(element.$id!),
            BaseClass.fUserId: userId,
          },
            (element as BaseClass).toMapUpdate(),
        );
      }
    }
  }

  Future<void> _uploadDeletedItems(String userId, List<String>? deleted) async {
    if (deleted != null && deleted.isNotEmpty) {
      for (var id in deleted) {
        await _mongoRepository.deleteOne(_collection!, {
          BaseClass.fId: ObjectId.parse(id),
          BaseClass.fUserId: userId,
        });
      }
    }
  }

  Future<void> _updateLocalHive() async {
    final LocalSyncHive objecttsLocal =
        _localSyncHiveRepository.findByObject(_collection!);
    objecttsLocal.added = [];
    objecttsLocal.updated = [];
    objecttsLocal.deleted = [];
    objecttsLocal.save();
  }

  Future<void> _downloadAddedItems(String userId, List<String> added) async {
    if (added.isNotEmpty) {
      List<Map<String, dynamic>> orCondition = [];
      for (var id in added) {
        orCondition.add({
          BaseClass.fId: ObjectId.parse(id),
          BaseClass.fUserId: userId,
        });
      }

      // Get added data from cloud
      List<Map<String, dynamic>> addedObjects =
          await _mongoRepository.find(_collection!, {
        '\$or': orCondition,
      });

      List objects = addedObjects.map((e) {
        BaseClass f = _syncRepository.creator();
        f.fromMap(f, e);
        return f;
      }).toList();
      await _syncRepository.syncSaveAll(objects);
    }
  }

  Future<void> _downloadUpdatedItems(
      String userId, List<String> updated) async {
    if (updated.isNotEmpty) {
      List<Map<String, dynamic>> orCondition = [];
      for (var id in updated) {
        orCondition.add({
          BaseClass.fId: ObjectId.parse(id),
          BaseClass.fUserId: userId,
        });
      }
      // Get updated data from cloud
      List<Map<String, dynamic>> updatedObjects =
          await _mongoRepository.find(_collection!, {
        '\$or': orCondition,
      });

      List<BaseClass> baseObjects = updatedObjects.map((updatedObject) {
        BaseClass baseObject = _syncRepository.creator();
        baseObject.fromMap(baseObject, updatedObject);
        return baseObject;
      }).toList();

      await _syncRepository.syncUpdateAll(baseObjects);
    }
  }

  Future<void> _downloadDeletedItems(List<String> deleted) async {
    if (deleted.isNotEmpty) {
      await _syncRepository.syncDeleteAll(deleted);
    }
  }

  Future<void> _removeFromCloudForThisDevice(
      String userId, String deviceId) async {
    await _mongoRepository.replaceOne(
      LocalSync.collection,
      {
        BaseClass.fUserId: userId,
        LocalSync.fDevice: deviceId,
        LocalSync.fObject: _collection,
      },
      {
        LocalSync.fAdded: [],
        LocalSync.fUpdated: [],
        LocalSync.fDeleted: [],
      },
    );
  }
}
