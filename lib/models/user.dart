import 'package:intl/intl.dart';
import 'package:mongo_dart/mongo_dart.dart';

class User {
  static const String ID = '_id';
  static const String USERNAME = 'username';
  static const String DEVICES = 'devices';
  static const String CREATED_DATE = 'created_date';
  static const String UPDATED_DATE = 'updated_date';

  String? id;
  String? username;
  List<String>? devices;
  DateTime? createdDate;
  DateTime? updatedDate;

  User();

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      USERNAME: username,
      CREATED_DATE: createdDate!.toUtc().toIso8601String(),
    };
    if (id != null) {
      map[ID] = id;
    }
    return map;
  }

  User.fromMap(Map<String, dynamic> map) {
    id = (map[ID] as ObjectId).$oid;
    username = map[USERNAME] as String?;
    createdDate = DateFormat('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'')
        .parse(map[CREATED_DATE] as String);
  }

  User.fromMapPref(Map<String, dynamic> map) {
    id = map[ID];
    username = map[USERNAME];
    createdDate = DateFormat('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'')
        .parse(map[CREATED_DATE] as String);
  }
}
