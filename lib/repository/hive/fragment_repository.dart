import 'package:hive/hive.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:my_pensieve/models/hive/fragment.dart';
import 'package:my_pensieve/repository/hive/base_repository.dart';

class FragmentHiveRepository extends BaseHiveRepository<FragmentHive> {
  static String boxName = 'fragments';

  late Box<FragmentHive> box;

  Future<String> addWithCreatedId(FragmentHive fragmentHive) async {
    fragmentHive.id = mongo.ObjectId().toHexString();
    fragmentHive.date = fragmentHive.date!.toUtc();
    await box.put(fragmentHive.id, fragmentHive);
    return fragmentHive.id!;
  }

  Future<void> addAll(List<FragmentHive> fragmentHives) async {
    Map<String, FragmentHive> hiveMap = {};
    for (var element in fragmentHives) {
      hiveMap.putIfAbsent(element.id!, () => element);
    }
    await box.putAll(hiveMap);
  }

  List<FragmentHive> findAll(bool isSort) {
    List<FragmentHive> results = box.values.toList();
    if (isSort) {
      results.sort((a, b) => b.date!.compareTo(a.date!));
    }
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

  Future<void> deleteAll(List<String> keys) async {
    await box.deleteAll(keys);
  }
}
