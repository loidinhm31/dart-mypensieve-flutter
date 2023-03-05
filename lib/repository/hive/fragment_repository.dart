import 'package:hive/hive.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:my_pensieve/models/hive/fragment.dart';

class FragmentHiveRepository {
  static String fragmentsBox = 'fragments';

  late Box<FragmentHive> box;

  static Future<void> init() async {
    bool exists = await Hive.boxExists(fragmentsBox);
    if (!exists) {
      // Create a box collection
      await BoxCollection.open(
        'pensieve', // Name of your database
        {fragmentsBox}, // Names of your boxes
        path:
            './', // Path where to store your boxes (Only used in Flutter / Dart IO)
      );
    }
  }

  Future<void> open() async {
    await Hive.openBox<FragmentHive>(fragmentsBox);
    box = Hive.box<FragmentHive>(fragmentsBox);
  }

  Future<String> add(FragmentHive fragmentHive) async {
    fragmentHive.id = mongo.ObjectId().toHexString();
    await box.put(fragmentHive.id, fragmentHive);
    return fragmentHive.id!;
  }

  List<FragmentHive> findAll() {
    List<FragmentHive> results = box.values.toList();
    results.sort((a, b) => b.date!.compareTo(a.date!));
    return results;
  }

  FragmentHive? findByKey(String key) {
    FragmentHive? results = box.get(key);
    return results;
  }

  List<FragmentHive> findAllByKeys(List<String?> keys) {
    List<FragmentHive> results =
        box.values.where((element) => keys.contains(element.id)).toList();
    return results;
  }

  List<FragmentHive> findAllByTitle(String title) {
    List<FragmentHive> results =
        box.values.where((element) => element.title == title).toList();
    return results;
  }

  Future<void> clear() async {
    await box.clear();
  }

  Future<void> close() async {
    await box.close();
  }
}
