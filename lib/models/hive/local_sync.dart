import 'package:hive/hive.dart';

part 'local_sync.g.dart';

@HiveType(typeId: 1)
class LocalSyncHive extends HiveObject {
  @HiveField(1)
  String? object;

  @HiveField(2)
  List<String>? added;

  @HiveField(3)
  List<String>? updated;

  @HiveField(4)
  List<String>? deleted;
}
