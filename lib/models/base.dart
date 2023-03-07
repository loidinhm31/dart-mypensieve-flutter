import 'package:hive/hive.dart';

abstract class BaseModel<T> extends HiveObject {
  static const String fId = '_id';
  static const String fUserId = 'user_id';

  String? get $id;
  Map<String, dynamic> toMap(String userId);
  Map<String, dynamic> toMapUpdate();
  HiveObject fromMap(BaseModel baseModel, Map<String, Object?> map);
}
