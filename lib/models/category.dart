import 'package:mongo_dart/mongo_dart.dart';
import 'package:my_pensieve/models/base.dart';
import 'package:my_pensieve/daos/database.dart' as db;

class Category extends BaseClass {
  static const String collection = 'categories';

  static const String fname = 'name';

  String? id;
  String? name;

  Category();

  @override
  String? get $id => id;

  @override
  Map<String, dynamic> toMap(String userId) {
    var map = {
      BaseClass.fId: ObjectId.parse(id as String),
      BaseClass.fUserId: userId,
      Category.fname: name,
    };
    return map;
  }

  @override
  Map<String, dynamic> toMapUpdate() {
    var map = {
      Category.fname: name,
    };
    return map;
  }

  @override
  BaseClass fromMap(BaseClass baseObject, Map<String, Object?> map) {
    (baseObject as Category).id = (map[BaseClass.fId] as ObjectId).$oid;
    baseObject.name = map[Category.fname] as String?;

    return baseObject;
  }

  Category.fromDatabase(db.Category category) {
    id = category.id;
    name = category.name;
  }
}
