import 'dart:ffi';

import 'package:my_pensieve/models/device_sync.dart';
import 'package:my_pensieve/models/hive/local_sync.dart';
import 'package:my_pensieve/repositories/hive/base_repository.dart';

class LocalSyncHiveRepository extends BaseHiveRepository<LocalSyncHive> {
  static String boxInit = 'localsyncs';

  @override
  String get boxName => 'localsyncs';

  LocalSyncHive findByObject(String object) {
    LocalSyncHive results =
        box!.values.firstWhere((element) => element.object == object);
    return results;
  }

  @override
  LocalSyncHive creator() {
    return LocalSyncHive();
  }

  @override
  List<LocalSyncHive> findAllByKeys(List<String?> keys) {
    // This hive object have not a real key or id to implement
    throw UnimplementedError();
  }

  @override
  LocalSyncHive? findByKey(String key) {
    // This hive object have not a real key or id to implement
    throw UnimplementedError();
  }

  @override
  Future<void> addAll(List<LocalSyncHive> hiveObjects) {
    // This hive object have not a real key or id to implement
    throw UnimplementedError();
  }

  @override
  Future<void> deleteAll(List<String> keys) async {
    // This hive object have not a real key or id to implement
    throw UnimplementedError();
  }

  @override
  void save(LocalSyncHive hiveObject) {
    hiveObject.save();
  }

  Future<void> addData(String object, Map<String, dynamic> syncData) async {
    try {
      LocalSyncHive localSyncHive = box!.values
          .firstWhere((element) => element.object == object, orElse: () {
        throw Exception();
      });
      syncData.forEach((key, value) {
        switch (key) {
          case LocalSync.fAdded:
            localSyncHive.added!.addAll(value);
            break;
          case LocalSync.fUpdated:
            localSyncHive.updated!.addAll(value);
            break;
          case LocalSync.fDeleted:
            localSyncHive.deleted!.addAll(value);
            break;
        }
      });
      localSyncHive.save();
    } catch (error) {
      LocalSyncHive localSyncHive = LocalSyncHive();
      localSyncHive.object = object;
      syncData.forEach((key, value) {
        switch (key) {
          case LocalSync.fAdded:
            localSyncHive.added = value;
            break;
          case LocalSync.fUpdated:
            localSyncHive.updated = value;
            break;
          case LocalSync.fDeleted:
            localSyncHive.deleted = value;
            break;
        }
      });
      await box!.add(localSyncHive);
    }
  }
}
