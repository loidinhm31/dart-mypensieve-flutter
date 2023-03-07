import 'package:hive/hive.dart';
import 'package:my_pensieve/models/base.dart';

part 'local_sync.g.dart';

@HiveType(typeId: 0)
class LocalSyncHive extends BaseModel<LocalSyncHive> {
  @HiveField(1)
  String? object;

  @HiveField(2)
  List<String>? added;

  @HiveField(3)
  List<String>? updated;

  @HiveField(4)
  List<String>? deleted;

  @override
  // This hive object have not a real key or id to implement
  String? get $id => throw UnimplementedError();

  @override
  Map<String, dynamic> toMapUpdate() {
    // This hive object have not a real key or id to implement
    throw UnimplementedError();
  }

  @override
  Map<String, dynamic> toMap(String userId) {
    // This hive object have not a real key or id to implement
    throw UnimplementedError();
  }

  @override
  BaseModel fromMap(BaseModel baseModel, Map<String, Object?> map) {
    // This hive object have not a real key or id to implement
    throw UnimplementedError();
  }
}
