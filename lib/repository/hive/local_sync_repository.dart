import 'package:hive/hive.dart';
import 'package:my_pensieve/models/device_sync.dart';
import 'package:my_pensieve/models/hive/local_sync.dart';
import 'package:my_pensieve/repository/hive/base_repository.dart';

class LocalSyncHiveRepository extends BaseHiveRepository<LocalSyncHive> {
  static String boxName = 'localsyncs';

  LocalSyncHive findByObject(String object) {
    LocalSyncHive results =
        box.values.firstWhere((element) => element.object == object);
    return results;
  }

  Future<void> add(String object, Map<String, dynamic> syncData) async {
    try {
      LocalSyncHive localSyncHive = box.values
          .firstWhere((element) => element.object == object, orElse: () {
        throw Exception();
      });
      syncData.forEach((key, value) {
        switch (key) {
          case LocalSync.ADDED:
            localSyncHive.added!.addAll(value);
            break;
          case LocalSync.UPDATED:
            localSyncHive.updated!.addAll(value);
            break;
          case LocalSync.DELETED:
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
          case LocalSync.ADDED:
            localSyncHive.added = value;
            break;
          case LocalSync.UPDATED:
            localSyncHive.updated = value;
            break;
          case LocalSync.DELETED:
            localSyncHive.deleted = value;
            break;
        }
      });
      await box.add(localSyncHive);
    }
  }
}
