abstract class BaseClass {
  static const String fId = '_id';
  static const String fUserId = 'user_id';

  String? get $id;

  Map<String, dynamic> toMap(String userId);
  Map<String, dynamic> toMapUpdate();
  BaseClass fromMap(BaseClass baseObject, Map<String, Object?> map);
}
