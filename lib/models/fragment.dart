import 'package:intl/intl.dart';
import 'package:mongo_dart/mongo_dart.dart';

class Fragment {
  static const String ID = '_id';
  static const String CATEGORY = 'category';
  static const String TITLE = 'title';
  static const String DESCRIPTION = 'description';
  static const String NOTE = 'note';
  static const String LINKED_ITEMS = 'linked_items';
  static const String DATE = 'date';

  String? id;
  String? category;
  String? title;
  String? description;
  String? note;
  List<String?>? linkedItems;
  DateTime? date;

  Fragment({
    this.id,
    required this.category,
    required this.title,
    required this.description,
    this.note,
    this.linkedItems,
    this.date,
  });

  Map<String, dynamic> toMap() {
    var map = <String, Object?>{
      CATEGORY: category,
      TITLE: title,
      DESCRIPTION: description,
      NOTE: note,
      LINKED_ITEMS: linkedItems,
      DATE: date!.toUtc().toIso8601String(),
    };
    if (id != null) {
      map[ID] = id;
    }
    return map;
  }

  Map<String, dynamic> toMapUpdate() {
    var map = <String, dynamic>{
      CATEGORY: category,
      TITLE: title,
      DESCRIPTION: description,
      NOTE: note,
      LINKED_ITEMS: linkedItems,
      DATE: date!.toUtc().toIso8601String(),
    };
    return map;
  }

  Fragment.fromMap(Map<String, Object?> map) {
    id = (map[ID] as ObjectId).$oid;
    category = map[CATEGORY] as String?;
    title = map[TITLE] as String?;
    description = map[DESCRIPTION] as String?;
    note = map[NOTE] as String?;
    linkedItems = List<String>.from(
        map[LINKED_ITEMS] != null ? map[LINKED_ITEMS] as List<dynamic> : []);
    date = DateFormat('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'')
        .parse(map[DATE] as String);
  }
}
