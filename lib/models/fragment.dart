import 'package:intl/intl.dart';
import 'package:mongo_dart/mongo_dart.dart';

class Fragment {
  static const String ID = '_id';
  static const String CATEGORY = 'category';
  static const String TITLE = 'title';
  static const String DESCRIPTION = 'description';
  static const String NOTE = 'note';
  static const String DATE = 'date';

  String? id;
  String? category;
  String? title;
  String? description;
  String? note;
  DateTime? date;

  Fragment({
    this.id,
    required this.category,
    required this.title,
    required this.description,
    this.note,
    this.date,
  });

  Map<String, Object?> toMap() {
    var map = <String, Object?>{
      CATEGORY: category,
      TITLE: title,
      DESCRIPTION: description,
      NOTE: note,
      DATE: date!.toUtc().toIso8601String(),
    };
    if (id != null) {
      map[ID] = id;
    }
    return map;
  }

  Map<String, Object?> toMapUpdate() {
    var map = <String, Object?>{
      CATEGORY: category,
      TITLE: title,
      DESCRIPTION: description,
      NOTE: note,
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
    date = DateFormat('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'')
        .parse(map[DATE] as String);
  }
}
