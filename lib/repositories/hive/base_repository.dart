import 'package:hive/hive.dart';
import 'package:my_pensieve/repositories/hive/sync_repository.dart';

abstract class BaseHiveRepository<T> implements SyncHiveRepository<T> {
  Box<T>? box;

  static Future<void> init(String boxName) async {
    bool exists = await Hive.boxExists(boxName);
    if (exists) {
      // Create a box collection
      await BoxCollection.open(
        'pensieve', // Name of your database
        {boxName}, // Names of your boxes
        path:
            './', // Path where to store your boxes (Only used in Flutter / Dart IO)
      );
    }
  }

  String get boxName;

  Future<void> open(String boxName) async {
    await Hive.openBox<T>(boxName);
    box = Hive.box<T>(boxName);
  }

  Future<void> clear() async {
    await box!.clear();
  }

  Future<void> close() async {
    if (box != null && box!.isOpen) {
      await box!.close();
    }
  }
}
