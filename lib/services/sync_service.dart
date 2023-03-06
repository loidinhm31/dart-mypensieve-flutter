import 'dart:developer';

import 'package:intl/intl.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:my_pensieve/models/device_sync.dart';
import 'package:my_pensieve/models/fragment.dart';
import 'package:my_pensieve/models/hive/fragment.dart';
import 'package:my_pensieve/models/hive/local_sync.dart';
import 'package:my_pensieve/models/user.dart';
import 'package:my_pensieve/repositories/hive/fragment_repository.dart';
import 'package:my_pensieve/repositories/hive/local_sync_repository.dart';
import 'package:my_pensieve/repositories/mongo_repository.dart';
import 'package:my_pensieve/utils/device_info.dart';

class SyncService {
  late FragmentHiveRepository _fragmentHiveRepository;
  late LocalSyncHiveRepository _localSyncHiveRepository;
  late MongoRepository _mongoRepository;

  SyncService() {
    _fragmentHiveRepository = FragmentHiveRepository();
    _localSyncHiveRepository = LocalSyncHiveRepository();
    _mongoRepository = MongoRepository();
  }

  Future<void> syncUpload(String userId) async {
    final String deviceId = await DeviceUtil.deviceId;

    try {
      await _localSyncHiveRepository.open(LocalSyncHiveRepository.boxName);

      final LocalSyncHive unsyncFragments =
          _localSyncHiveRepository.findByObject(fragmentColl);

      List<String>? added = unsyncFragments.added;
      List<String>? updated = unsyncFragments.updated;
      List<String>? deleted = unsyncFragments.deleted;

      await _mongoRepository.open();

      // Notify cloud before upload (for non-current devices)
      await _notifyAnotherDevices(userId, added, updated, deleted, deviceId);

      await _fragmentHiveRepository.open(FragmentHiveRepository.boxName);

      // Upload
      await _uploadAddedItems(userId, added);

      await _uploadUpdatedItems(userId, updated);

      await _uploadDeletedItems(userId, deleted);
    } catch (error, stack) {
      log('Error: $error');
      log('StackTrace: $stack');
    } finally {
      await _fragmentHiveRepository.close();
      await _mongoRepository.close();

      try {
        // Update sync for local hive
        await _updateLocalHive();
      } catch (error, stack) {
        log('Error: $error');
        log('StackTrace: $stack');
      } finally {
        await _localSyncHiveRepository.close();
      }
    }
  }

  Future<void> syncDownload(String userId) async {
    _mongoRepository = MongoRepository();
    _fragmentHiveRepository = FragmentHiveRepository();

    final String deviceId = await DeviceUtil.deviceId;

    try {
      await _mongoRepository.open();

      List<Map<String, dynamic>> unsyncFragments =
          await _mongoRepository.find(deviceSyncColl, {
        USER_ID: userId,
        LocalSync.DEVICE: deviceId,
        LocalSync.OBJECT: fragmentColl,
      });

      if (unsyncFragments.isNotEmpty) {
        List<String> added = unsyncFragments[0][LocalSync.ADDED] != null
            ? List<String>.from(unsyncFragments[0][LocalSync.ADDED]).toList()
            : [];
        List<String> updated = unsyncFragments[0][LocalSync.UPDATED] != null
            ? List<String>.from(unsyncFragments[0][LocalSync.UPDATED]).toList()
            : [];
        List<String> deleted = unsyncFragments[0][LocalSync.DELETED] != null
            ? List<String>.from(unsyncFragments[0][LocalSync.DELETED]).toList()
            : [];

        await _fragmentHiveRepository.open(FragmentHiveRepository.boxName);

        await _downloadAddedItems(userId, added);

        await _downloadUpdatedItems(userId, updated);

        await _downloadDeletedItems(deleted);
      }
    } catch (error, stack) {
      log('Error: $error');
      log('StackTrace: $stack');
    } finally {
      await _fragmentHiveRepository.close();

      try {
        // Remove in cloud sync collection
        await _removeFromCloudForThisDevice(userId, deviceId);
      } catch (error, stack) {
        log('Error: $error');
        log('StackTrace: $stack');
      } finally {
        await _mongoRepository.close();
      }
    }
  }

  Future<void> initCloudObject(String userId) async {
    try {
      await _mongoRepository.open();
      final String deviceId = await DeviceUtil.deviceId;

      List<Map<String, dynamic>> currentDeviceCloudSync =
          await _mongoRepository.find(deviceSyncColl, {
        USER_ID: userId,
        LocalSync.DEVICE: deviceId,
        LocalSync.OBJECT: fragmentColl,
      });

      if (currentDeviceCloudSync.isEmpty) {
        // Find all items from cloud
        List<Map<String, dynamic>> cloudItems =
            await _mongoRepository.find(fragmentColl, {
          USER_ID: userId,
        });

        List<String> ids = [];
        for (var element in cloudItems) {
          ids.add((element[Fragment.ID] as ObjectId).$oid);
        }

        // Add new device with object to cloud
        await _mongoRepository.insertOne(
          deviceSyncColl,
          {
            USER_ID: userId,
            LocalSync.DEVICE: deviceId,
            LocalSync.OBJECT: fragmentColl,
            LocalSync.ADDED: ids,
          },
        );
        currentDeviceCloudSync = await _mongoRepository.find(deviceSyncColl, {
          LocalSync.DEVICE: deviceId,
          LocalSync.OBJECT: fragmentColl,
        });
      }
    } catch (error, stack) {
      log('Error: $error');
      log('StackTrace: $stack');
    } finally {
      _mongoRepository.close();
    }
  }

  Future<void> _notifyAnotherDevices(String userId, List<String>? added,
      List<String>? updated, List<String>? deleted, String deviceId) async {
    Map<String, dynamic> nonCurrentDeviceCondition = {
      '\$and': [
        {
          USER_ID: userId,
          LocalSync.DEVICE: {
            '\$nin': [deviceId]
          },
        }
      ]
    };
    List<Map<String, dynamic>> nonCurrentDevicesCloudSync =
        await _mongoRepository.find(deviceSyncColl, nonCurrentDeviceCondition);

    // Change fields for non-current devices
    for (var device in nonCurrentDevicesCloudSync) {
      List<String> newAdded = device[LocalSync.ADDED] != null
          ? List.from(device[LocalSync.ADDED])
          : [];

      if (newAdded.isNotEmpty) {
        newAdded.addAll(added!);
      } else {
        newAdded = added!;
      }

      List<String> newUpdated = device[LocalSync.UPDATED] != null
          ? List.from(device[LocalSync.UPDATED])
          : [];
      if (newUpdated.isNotEmpty) {
        newUpdated.addAll(updated!);
      } else {
        newUpdated = updated!;
      }

      List<String> newDeleted = device[LocalSync.DELETED] != null
          ? List.from(device[LocalSync.DELETED])
          : [];
      if (newDeleted.isNotEmpty) {
        newDeleted.addAll(deleted!);
      } else {
        newDeleted = deleted!;
      }
      await _mongoRepository.replaceOne(
        deviceSyncColl,
        {
          LocalSync.DEVICE: device[LocalSync.DEVICE],
          LocalSync.OBJECT: fragmentColl,
        },
        {
          LocalSync.ADDED: newAdded,
          LocalSync.UPDATED: newUpdated,
          LocalSync.DELETED: newDeleted,
        },
      );
    }
  }

  Future<void> _uploadAddedItems(String userId, List<String>? added) async {
    if (added != null && added.isNotEmpty) {
      List<FragmentHive> fragmentHives =
          _fragmentHiveRepository.findAllByKeys(added);
      // Insert
      List<Map<String, dynamic>> maps = [];
      for (var element in fragmentHives) {
        maps.add({
          Fragment.ID: ObjectId.parse(element.id as String),
          USER_ID: userId,
          Fragment.CATEGORY_ID: element.categoryId,
          Fragment.TITLE: element.title,
          Fragment.DESCRIPTION: element.description,
          Fragment.NOTE: element.note,
          Fragment.LINKED_ITEMS: element.linkedItems,
          Fragment.DATE: element.date!.toIso8601String(),
        });
      }
      // Excecute upload added data
      await _mongoRepository.insertAll(fragmentColl, maps);
    }
  }

  Future<void> _uploadUpdatedItems(String userId, List<String>? updated) async {
    if (updated != null && updated.isNotEmpty) {
      List<FragmentHive> fragmentHives =
          _fragmentHiveRepository.findAllByKeys(updated);
      for (var element in fragmentHives) {
        await _mongoRepository.replaceOne(
          fragmentColl,
          {
            Fragment.ID: ObjectId.parse(element.id as String),
            USER_ID: userId,
          },
          {
            Fragment.CATEGORY_ID: element.categoryId,
            Fragment.TITLE: element.title,
            Fragment.DESCRIPTION: element.description,
            Fragment.NOTE: element.note,
            Fragment.LINKED_ITEMS: element.linkedItems,
            Fragment.DATE: element.date!.toIso8601String(),
          },
        );
      }
    }
  }

  Future<void> _uploadDeletedItems(String userId, List<String>? deleted) async {
    if (deleted != null && deleted.isNotEmpty) {
      for (var id in deleted) {
        await _mongoRepository.deleteOne(fragmentColl, {
          Fragment.ID: ObjectId.parse(id),
          USER_ID: userId,
        });
      }
    }
  }

  Future<void> _updateLocalHive() async {
    final LocalSyncHive fragmentsLocal =
        _localSyncHiveRepository.findByObject(fragmentColl);
    fragmentsLocal.added = [];
    fragmentsLocal.updated = [];
    fragmentsLocal.deleted = [];
    fragmentsLocal.save();
  }

  Future<void> _downloadAddedItems(String userId, List<String> added) async {
    if (added.isNotEmpty) {
      List<Map<String, dynamic>> orCondition = [];
      for (var id in added) {
        orCondition.add({
          Fragment.ID: ObjectId.parse(id),
          USER_ID: userId,
        });
      }

      // Get added data from cloud
      List<Map<String, dynamic>> addedFragments =
          await _mongoRepository.find(fragmentColl, {
        '\$or': orCondition,
      });

      List<FragmentHive> fragments = addedFragments.map((e) {
        FragmentHive f = FragmentHive();
        f.id = (e[Fragment.ID] as ObjectId).$oid;
        f.categoryId = e[Fragment.CATEGORY_ID];
        f.title = e[Fragment.TITLE];
        f.description = e[Fragment.DESCRIPTION];
        f.note = e[Fragment.NOTE] ?? '';
        f.linkedItems = e[Fragment.LINKED_ITEMS] != null
            ? List.from(e[Fragment.LINKED_ITEMS])
            : [];
        f.date = DateFormat('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'')
            .parse(e[Fragment.DATE]);
        return f;
      }).toList();
      await _fragmentHiveRepository.addAll(fragments);
    }
  }

  Future<void> _downloadUpdatedItems(
      String userId, List<String> updated) async {
    if (updated.isNotEmpty) {
      List<Map<String, dynamic>> orCondition = [];
      for (var id in updated) {
        orCondition.add({
          Fragment.ID: ObjectId.parse(id),
          USER_ID: userId,
        });
      }
      // Get added data from cloud
      List<Map<String, dynamic>> updatedFragments =
          await _mongoRepository.find(fragmentColl, {
        '\$or': orCondition,
      });

      final List<FragmentHive> fragments =
          _fragmentHiveRepository.findAllByKeys(updated);

      for (var updatedFragment in updatedFragments) {
        String hexStringId = (updatedFragment[Fragment.ID] as ObjectId).$oid;
        FragmentHive f = fragments
            .firstWhere((currFragment) => currFragment.id == hexStringId);
        f.id = hexStringId;
        f.categoryId = updatedFragment[Fragment.CATEGORY_ID];
        f.title = updatedFragment[Fragment.TITLE];
        f.note = updatedFragment[Fragment.NOTE];
        f.linkedItems = updatedFragment[Fragment.LINKED_ITEMS] != null
            ? List.from(updatedFragment[Fragment.LINKED_ITEMS])
            : [];
        f.date = DateFormat('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'')
            .parse(updatedFragment[Fragment.DATE]);
        f.save();
      }
    }
  }

  Future<void> _downloadDeletedItems(List<String> deleted) async {
    if (deleted.isNotEmpty) {
      await _fragmentHiveRepository.deleteAll(deleted);
    }
  }

  Future<void> _removeFromCloudForThisDevice(
      String userId, String deviceId) async {
    await _mongoRepository.replaceOne(
      deviceSyncColl,
      {
        USER_ID: userId,
        LocalSync.DEVICE: deviceId,
        LocalSync.OBJECT: 'fragments',
      },
      {
        LocalSync.ADDED: [],
        LocalSync.UPDATED: [],
        LocalSync.DELETED: [],
      },
    );
  }
}
