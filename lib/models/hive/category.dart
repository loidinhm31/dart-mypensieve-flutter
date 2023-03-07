import 'package:hive/hive.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:my_pensieve/models/base.dart';
import 'package:my_pensieve/models/category.dart';

part 'category.g.dart';

@HiveType(typeId: 2)
class CategoryHive extends BaseModel<CategoryHive> {
  @HiveField(0)
  String? id;

  @HiveField(1)
  String? name;

  @override
  String? get $id => id;

  @override
  Map<String, dynamic> toMap(String userId) {
    var map = {
      BaseModel.fId: ObjectId.parse(id as String),
      BaseModel.fUserId: userId,
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
  BaseModel fromMap(BaseModel baseModel, Map<String, Object?> map) {
    (baseModel as CategoryHive).id = (map[BaseModel.fId] as ObjectId).$oid;
    baseModel.name = map[Category.fname] as String?;

    return baseModel;
  }
}
