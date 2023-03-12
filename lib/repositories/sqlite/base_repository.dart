import 'package:get/get.dart';
import 'package:my_pensieve/daos/database.dart';

abstract class BaseRepository {
  AppDatabase? database;

  String get table;

  void init() {
    database = Get.find<AppDatabase>();
  }

  Future<void> clear();
}
