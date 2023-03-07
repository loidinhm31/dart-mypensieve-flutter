import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:my_pensieve/models/base.dart';
import 'package:my_pensieve/models/hive/fragment.dart';
import 'package:my_pensieve/repositories/hive/base_repository.dart';

class FragmentHiveRepository extends BaseHiveRepository<FragmentHive> {
  static String boxInit = 'fragments';

  @override
  String get boxName => 'fragments';

  @override
  FragmentHive creator() {
    return FragmentHive();
  }

  @override
  List<FragmentHive> findAllByKeys(List<String?> keys) {
    List<FragmentHive> results =
        box!.values.where((element) => keys.contains(element.id)).toList();
    return results;
  }

  @override
  FragmentHive? findByKey(String key) {
    FragmentHive? results = box!.get(key);
    return results;
  }

  @override
  Future<void> addAll(List<BaseModel> objectHives) async {
    Map<String, FragmentHive> hiveMap = {};
    for (var element in objectHives) {
      hiveMap.putIfAbsent((element as FragmentHive).id!, () => element);
    }
    await box!.putAll(hiveMap);
  }

  @override
  Future<void> deleteAll(List<String> keys) async {
    await box!.deleteAll(keys);
  }

  @override
  void save(FragmentHive hiveObject) {
    hiveObject.save();
  }

  Future<String> addOneWithCreatedId(FragmentHive fragmentHive) async {
    fragmentHive.id = mongo.ObjectId().toHexString();
    fragmentHive.date = fragmentHive.date!.toUtc();
    await box!.put(fragmentHive.id, fragmentHive);
    return fragmentHive.id!;
  }

  List<FragmentHive> findAll(bool isSort) {
    List<FragmentHive> results = box!.values.toList();
    if (isSort) {
      results.sort((a, b) => b.date!.compareTo(a.date!));
    }
    return results;
  }

  List<FragmentHive> findAllByTitle(String title) {
    List<FragmentHive> results =
        box!.values.where((element) => element.title == title).toList();
    return results;
  }
}
