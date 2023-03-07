import 'package:intl/intl.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:my_pensieve/models/base.dart';

class Fragment {
  static const String collection = 'fragments';

  static const String fCategoryId = 'category_id';
  static const String fTitle = 'title';
  static const String fDescription = 'description';
  static const String fNote = 'note';
  static const String fLinkedItems = 'linked_items';
  static const String fDate = 'date';

  String? id;
  String? categoryId;
  String? title;
  String? description;
  String? note;
  List<String?>? linkedItems;
  DateTime? date;

  Fragment();

  Fragment.fromMap(Map<String, Object?> map) {
    id = (map[BaseModel.fId] as ObjectId).$oid;
    categoryId = map[fCategoryId] as String?;
    title = map[fTitle] as String?;
    description = map[fDescription] as String?;
    note = map[fNote] as String?;
    linkedItems = List<String>.from(
        map[fLinkedItems] != null ? map[fLinkedItems] as List<dynamic> : []);
    date = DateFormat('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'')
        .parse(map[fDate] as String);
  }
}
