import 'package:intl/intl.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:my_pensieve/daos/database.dart' as db;
import 'package:my_pensieve/daos/fragments_dao.dart';
import 'package:my_pensieve/models/base.dart';

class Fragment extends BaseClass {
  static const String collection = 'fragments';

  static const String fCategoryId = 'category_id';
  static const String fTitle = 'title';
  static const String fDescription = 'description';
  static const String fNote = 'note';
  static const String fLinkedItems = 'linked_items';
  static const String fDate = 'date';

  String? id;
  String? categoryId;
  String? categoryName;
  String? title;
  String? description;
  String? note;
  List<String>? linkedItems;
  DateTime? date;

  Fragment();

  @override
  String? get $id => id;

  @override
  Map<String, dynamic> toMap(String userId) {
    var map = {
      BaseClass.fId: ObjectId.parse(id as String),
      BaseClass.fUserId: userId,
      Fragment.fCategoryId: categoryId,
      Fragment.fTitle: title,
      Fragment.fDescription: description,
      Fragment.fNote: note,
      Fragment.fLinkedItems: linkedItems,
      Fragment.fDate: date!.toUtc().toIso8601String(),
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
      Fragment.fDate: date!.toUtc().toIso8601String(),
    };
    return map;
  }

  @override
  Fragment fromMap(BaseClass baseObject, Map<String, Object?> map) {
    (baseObject as Fragment).id = (map[BaseClass.fId] as ObjectId).$oid;
    baseObject.categoryId = map[Fragment.fCategoryId] as String?;
    baseObject.title = map[Fragment.fTitle] as String?;
    baseObject.description = map[Fragment.fDescription] as String?;
    baseObject.note = map[Fragment.fNote] as String?;
    baseObject.linkedItems = List<String>.from(
        map[Fragment.fLinkedItems] != null
            ? map[Fragment.fLinkedItems] as List<dynamic>
            : []);
    baseObject.date = DateFormat('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'')
        .parse(map[Fragment.fDate] as String);
    return baseObject;
  }

  Fragment.fromDatabase(db.Fragment fragment) {
    id = fragment.id;
    categoryId = fragment.categoryId;
    title = fragment.title;
    description = fragment.description;
    note = fragment.note;
    date = fragment.date;
  }

  Fragment.fromDatabaseWithCustomFields(
      FragmentWithCategoryName fragmentCustom) {
    id = fragmentCustom.fragment.id;
    categoryId = fragmentCustom.fragment.categoryId;
    categoryName = fragmentCustom.categoryName ?? 'UNKNOW';
    title = fragmentCustom.fragment.title;
    description = fragmentCustom.fragment.description;
    note = fragmentCustom.fragment.note;
    date = fragmentCustom.fragment.date;
  }
}
