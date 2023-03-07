import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:my_pensieve/models/base.dart';
import 'package:my_pensieve/models/fragment.dart';

part 'fragment.g.dart';

@HiveType(typeId: 1)
class FragmentHive extends BaseModel<FragmentHive> {
  @HiveField(0)
  String? id;

  @HiveField(1)
  String? categoryId;

  String? categoryName;

  @HiveField(2)
  String? title;

  @HiveField(3)
  String? description;

  @HiveField(4)
  String? note;

  @HiveField(5)
  List<String?>? linkedItems;

  @HiveField(6)
  DateTime? date;

  @override
  String? get $id => id;

  @override
  Map<String, dynamic> toMap(String userId) {
    var map = {
      BaseModel.fId: ObjectId.parse(id as String),
      BaseModel.fUserId: userId,
      Fragment.fCategoryId: categoryId,
      Fragment.fTitle: title,
      Fragment.fDescription: description,
      Fragment.fNote: note,
      Fragment.fLinkedItems: linkedItems,
      Fragment.fDate: date!.toIso8601String(),
    };
    return map;
  }

  @override
  Map<String, dynamic> toMapUpdate() {
    var map = {
      Fragment.fCategoryId: categoryId,
      Fragment.fTitle: title,
      Fragment.fDescription: description,
      Fragment.fNote: note,
      Fragment.fLinkedItems: linkedItems,
      Fragment.fDate: date!.toIso8601String(),
    };
    return map;
  }

  @override
  FragmentHive fromMap(BaseModel baseModel, Map<String, Object?> map) {
    (baseModel as FragmentHive).id = (map[BaseModel.fId] as ObjectId).$oid;
    baseModel.categoryId = map[Fragment.fCategoryId] as String?;
    baseModel.title = map[Fragment.fTitle] as String?;
    baseModel.description = map[Fragment.fDescription] as String?;
    baseModel.note = map[Fragment.fNote] as String?;
    baseModel.linkedItems = List<String>.from(map[Fragment.fLinkedItems] != null
        ? map[Fragment.fLinkedItems] as List<dynamic>
        : []);
    baseModel.date = DateFormat('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'')
        .parse(map[Fragment.fDate] as String);
    return baseModel;
  }
}
