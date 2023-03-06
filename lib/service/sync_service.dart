import 'dart:developer';

import 'package:intl/intl.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:my_pensieve/models/device_sync.dart';
import 'package:my_pensieve/models/fragment.dart';
import 'package:my_pensieve/models/hive/fragment.dart';
import 'package:my_pensieve/models/hive/local_sync.dart';
import 'package:my_pensieve/repository/hive/fragment_repository.dart';
import 'package:my_pensieve/repository/hive/local_sync_repository.dart';
import 'package:my_pensieve/repository/mongo_repository.dart';
import 'package:my_pensieve/util/device_info.dart';

class SyncService {
  Future<void> syncUpload() async {
    final FragmentHiveRepository fragmentHiveRepository =
        FragmentHiveRepository();
    final LocalSyncHiveRepository localSyncHiveRepository =
        LocalSyncHiveRepository();
    final MongoRepository mongoRepository = MongoRepository();

    final String deviceId = await DeviceUtil.deviceId;

    try {
      await localSyncHiveRepository.open(LocalSyncHiveRepository.boxName);

      final LocalSyncHive unsyncFragments =
          localSyncHiveRepository.findByObject(fragmentColl);

      List<String>? added = unsyncFragments.added;
      List<String>? updated = unsyncFragments.updated;
      List<String>? deleted = unsyncFragments.deleted;

      await mongoRepository.open();

      // Notify cloud before upload (for non-current devices)
      await _notifyAnotherDevices(
          mongoRepository, added, updated, deleted, deviceId);

      await fragmentHiveRepository.open(FragmentHiveRepository.boxName);

      // Upload
      List<Map<String, dynamic>> currentDeviceCloudSync =
          await mongoRepository.find(deviceSyncColl, {
        LocalSync.DEVICE: deviceId,
        LocalSync.OBJECT: fragmentColl,
      });
      if (currentDeviceCloudSync.isEmpty) {
        await mongoRepository.insertOne(
          deviceSyncColl,
          {
            LocalSync.DEVICE: deviceId,
            LocalSync.OBJECT: fragmentColl,
          },
        );

        currentDeviceCloudSync = await mongoRepository.find(deviceSyncColl, {
          LocalSync.DEVICE: deviceId,
          LocalSync.OBJECT: fragmentColl,
        });
      }

      await _uploadAddedItems(mongoRepository, fragmentHiveRepository, added);

      await _uploadUpdatedItems(
          mongoRepository, fragmentHiveRepository, updated);

      await _uploadDeletedItems(
          mongoRepository, fragmentHiveRepository, deleted);
    } catch (error, stack) {
      log('Error: $error');
      log('StackTrace: $stack');
    } finally {
      await fragmentHiveRepository.close();
      await mongoRepository.close();

      try {
        // Update sync for local hive
        await _updateLocalHive(localSyncHiveRepository);
      } catch (error, stack) {
        log('Error: $error');
        log('StackTrace: $stack');
      } finally {
        await localSyncHiveRepository.close();
      }
    }
  }

  Future<void> syncDownload() async {
    final MongoRepository mongoRepository = MongoRepository();
    final FragmentHiveRepository fragmentHiveRepository =
        FragmentHiveRepository();

    final String deviceId = await DeviceUtil.deviceId;

    try {
      await mongoRepository.open();

      List<Map<String, dynamic>> unsyncFragments =
          await mongoRepository.find(deviceSyncColl, {
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

        await fragmentHiveRepository.open(FragmentHiveRepository.boxName);

        await _downloadAddedItems(
            mongoRepository, fragmentHiveRepository, added);

        await _downloadUpdatedItems(
            mongoRepository, fragmentHiveRepository, updated);

        await _downloadDeletedItems(fragmentHiveRepository, deleted);
      }
    } catch (error, stack) {
      log('Error: $error');
      log('StackTrace: $stack');
    } finally {
      await fragmentHiveRepository.close();

      try {
        // Remove in cloud sync collection
        await _removeFromCloudForThisDevice(mongoRepository, deviceId);
      } catch (error, stack) {
        log('Error: $error');
        log('StackTrace: $stack');
      } finally {
        await mongoRepository.close();
      }
    }
  }

  Future<void> _notifyAnotherDevices(
      MongoRepository mongoRepository,
      List<String>? added,
      List<String>? updated,
      List<String>? deleted,
      String deviceId) async {
    Map<String, dynamic> nonCurrentDeviceCondition = {
      '\$and': [
        {
          'device': {
            '\$nin': [deviceId]
          },
        }
      ]
    };
    List<Map<String, dynamic>> nonCurrentDevicesCloudSync =
        await mongoRepository.find(deviceSyncColl, nonCurrentDeviceCondition);

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
      await mongoRepository.replaceOne(
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

  Future<void> _uploadAddedItems(
      MongoRepository mongoRepository,
      FragmentHiveRepository fragmentHiveRepository,
      List<String>? added) async {
    if (added != null && added.isNotEmpty) {
      List<FragmentHive> fragmentHives =
          fragmentHiveRepository.findAllByKeys(added);
      // Insert
      List<Map<String, dynamic>> maps = [];
      for (var element in fragmentHives) {
        maps.add({
          Fragment.ID: ObjectId.parse(element.id as String),
          Fragment.CATEGORY: element.category,
          Fragment.TITLE: element.title,
          Fragment.DESCRIPTION: element.description,
          Fragment.NOTE: element.note,
          Fragment.LINKED_ITEMS: element.linkedItems,
          Fragment.DATE: element.date!.toIso8601String(),
        });
      }
      // Excecute upload added data
      await mongoRepository.insertAll(fragmentColl, maps);
    }
  }

  Future<void> _uploadUpdatedItems(
      MongoRepository mongoRepository,
      FragmentHiveRepository fragmentHiveRepository,
      List<String>? updated) async {
    if (updated != null && updated.isNotEmpty) {
      List<FragmentHive> fragmentHives =
          fragmentHiveRepository.findAllByKeys(updated);
      for (var element in fragmentHives) {
        mongoRepository.replaceOne(
          fragmentColl,
          {Fragment.ID: ObjectId.parse(element.id as String)},
          {
            Fragment.CATEGORY: element.category,
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

  Future<void> _uploadDeletedItems(
      MongoRepository mongoRepository,
      FragmentHiveRepository fragmentHiveRepository,
      List<String>? deleted) async {
    if (deleted != null && deleted.isNotEmpty) {
      for (var id in deleted) {
        await mongoRepository.deleteOne(
            fragmentColl, {Fragment.ID: ObjectId.parse(id as String)});
      }
    }
  }

  Future<void> _updateLocalHive(
      LocalSyncHiveRepository localSyncHiveRepository) async {
    final LocalSyncHive fragmentsLocal =
        localSyncHiveRepository.findByObject(fragmentColl);
    fragmentsLocal.added = [];
    fragmentsLocal.updated = [];
    fragmentsLocal.deleted = [];
    fragmentsLocal.save();
  }

  Future<void> _downloadAddedItems(MongoRepository mongoRepository,
      FragmentHiveRepository fragmentHiveRepository, List<String> added) async {
    if (added.isNotEmpty) {
      List<Map<String, dynamic>> orCondition = [];
      for (var id in added) {
        orCondition.add({Fragment.ID: ObjectId.parse(id)});
      }

      // Get added data from cloud
      List<Map<String, dynamic>> addedFragments =
          await mongoRepository.find(fragmentColl, {
        '\$or': orCondition,
      });

      List<FragmentHive> fragments = addedFragments.map((e) {
        FragmentHive f = FragmentHive();
        f.id = (e[Fragment.ID] as ObjectId).$oid;
        f.category = e[Fragment.CATEGORY];
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
      await fragmentHiveRepository.addAll(fragments);
    }
  }

  Future<void> _downloadUpdatedItems(
      MongoRepository mongoRepository,
      FragmentHiveRepository fragmentHiveRepository,
      List<String> updated) async {
    if (updated.isNotEmpty) {
      List<Map<String, dynamic>> orCondition = [];
      for (var id in updated) {
        orCondition.add({Fragment.ID: ObjectId.parse(id)});
      }
      // Get added data from cloud
      List<Map<String, dynamic>> updatedFragments =
          await mongoRepository.find(fragmentColl, {
        '\$or': orCondition,
      });

      final List<FragmentHive> fragments =
          fragmentHiveRepository.findAllByKeys(updated);

      for (var updatedFragment in updatedFragments) {
        String hexStringId = (updatedFragment[Fragment.ID] as ObjectId).$oid;
        FragmentHive f = fragments
            .firstWhere((currFragment) => currFragment.id == hexStringId);
        f.id = hexStringId;
        f.category = updatedFragment[Fragment.CATEGORY];
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

  Future<void> _downloadDeletedItems(
      FragmentHiveRepository fragmentHiveRepository,
      List<String> deleted) async {
    if (deleted.isNotEmpty) {
      await fragmentHiveRepository.deleteAll(deleted);
    }
  }

  Future<void> _removeFromCloudForThisDevice(
      MongoRepository mongoRepository, String deviceId) async {
    await mongoRepository.replaceOne(
      deviceSyncColl,
      {
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
