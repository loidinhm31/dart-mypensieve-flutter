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
      await localSyncHive.save();
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
