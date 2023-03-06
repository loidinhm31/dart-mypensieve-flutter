import 'package:intl/intl.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:my_pensieve/models/device_sync.dart';
import 'package:my_pensieve/models/fragment.dart';
import 'package:my_pensieve/models/hive/fragment.dart';
import 'package:my_pensieve/models/hive/local_sync.dart';
import 'package:my_pensieve/repository/hive/fragment_repository.dart';
import 'package:my_pensieve/repository/hive/local_sync_repository.dart';
import 'package:my_pensieve/repository/mongo_repository.dart';

class SyncService {
  Future<void> upload() async {
    final LocalSyncHiveRepository localSyncHiveRepository =
        LocalSyncHiveRepository();
    await localSyncHiveRepository.open(LocalSyncHiveRepository.boxName);

    final LocalSyncHive unsyncFragments =
        localSyncHiveRepository.findByObject('fragments');

    List<String>? added = unsyncFragments.added;
    List<String>? updated = unsyncFragments.updated;
    List<String>? deleted = unsyncFragments.deleted;

    final MongoRepository mongoRepository = MongoRepository();
    await mongoRepository.open();

    // Notify cloud before upload (for non-current devices)
    Map<String, dynamic> nonCurrentDeviceCondition = {
      '\$and': [
        {
          'device': {
            '\$nin': ['deviceId'] // TODO
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
        nonCurrentDeviceCondition,
        {
          LocalSync.ADDED: newAdded,
          LocalSync.UPDATED: newUpdated,
          LocalSync.DELETED: newDeleted,
        },
      );
    }

    // Upload
    List<Map<String, dynamic>> currentDeviceCloudSync =
        await mongoRepository.find(deviceSyncColl, {
      LocalSync.DEVICE: 'deviceId',
      LocalSync.OBJECT: fragmentColl,
    });
    if (currentDeviceCloudSync.isEmpty) {
      await mongoRepository.insertOne(
        deviceSyncColl,
        {
          LocalSync.DEVICE: 'deviceId',
          LocalSync.OBJECT: fragmentColl,
        },
      );

      currentDeviceCloudSync = await mongoRepository.find(deviceSyncColl, {
        LocalSync.DEVICE: 'deviceId',
        LocalSync.OBJECT: fragmentColl,
      });
    }

    final FragmentHiveRepository fragmentHiveRepository =
        FragmentHiveRepository();
    await fragmentHiveRepository.open(FragmentHiveRepository.boxName);
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
    if (updated != null && updated.isNotEmpty) {
      List<FragmentHive> fragmentHives =
          fragmentHiveRepository.findAllByKeys(updated);
      for (var element in fragmentHives) {
        mongoRepository.replaceOne(
          fragmentColl,
          {Fragment.ID: element.id},
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

    if (deleted != null && deleted.isNotEmpty) {
      for (var id in deleted) {
        await mongoRepository.deleteOne(
            fragmentColl, {Fragment.ID: ObjectId.parse(id as String)});
      }
    }

    // Update sync for local hive
    final LocalSyncHive fragmentsLocal =
        localSyncHiveRepository.findByObject('fragments');
    fragmentsLocal.added = [];
    fragmentsLocal.updated = [];
    fragmentsLocal.deleted = [];
    fragmentsLocal.save();

    await localSyncHiveRepository.close();
    await mongoRepository.close();
  }

  Future<void> download() async {
    final MongoRepository mongoRepository = MongoRepository();
    await mongoRepository.open();

    List<Map<String, dynamic>> unsyncFragments =
        await mongoRepository.find(deviceSyncColl, {
      'device': 'deviceId', // TODO
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

      final FragmentHiveRepository fragmentHiveRepository =
          FragmentHiveRepository();
      await fragmentHiveRepository.open(FragmentHiveRepository.boxName);

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

      if (deleted.isNotEmpty) {
        await fragmentHiveRepository.deleteAll(deleted);
      }

      // Remove in cloud sync collection
      await mongoRepository.replaceOne(
        deviceSyncColl,
        {
          'device': 'deviceId', // TODO
          LocalSync.OBJECT: 'fragments',
        },
        {
          LocalSync.ADDED: [],
          LocalSync.UPDATED: [],
          LocalSync.DELETED: [],
        },
      );
      await fragmentHiveRepository.close();
      await mongoRepository.close();
    }
  }
}
