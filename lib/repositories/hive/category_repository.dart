import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:my_pensieve/models/base.dart';
import 'package:my_pensieve/models/hive/category.dart';
import 'package:my_pensieve/repositories/hive/base_repository.dart';

class CategoryHiveRepository extends BaseHiveRepository<CategoryHive> {
  static String boxInit = 'categories';

  @override
  String get boxName => 'categories';

  @override
  CategoryHive creator() {
    return CategoryHive();
  }

  @override
  List<CategoryHive> findAllByKeys(List<String?> keys) {
    List<CategoryHive> results =
        box!.values.where((element) => keys.contains(element.id)).toList();
    return results;
  }

  @override
  CategoryHive? findByKey(String key) {
    CategoryHive? results = box!.get(key);
    return results;
  }

  @override
  Future<void> addAll(List<BaseModel> objectHives) async {
    Map<String, CategoryHive> hiveMap = {};
    for (var element in objectHives) {
      hiveMap.putIfAbsent((element as CategoryHive).id!, () => element);
    }
    await box!.putAll(hiveMap);
  }

  @override
  Future<void> deleteAll(List<String> keys) async {
    await box!.deleteAll(keys);
  }

  @override
  void save(CategoryHive hiveObject) {
    hiveObject.save();
  }

  Future<String> addOneWithCreatedId(CategoryHive categoryHive) async {
    categoryHive.id = mongo.ObjectId().toHexString();
    await box!.put(categoryHive.id, categoryHive);
    return categoryHive.id!;
  }

  List<CategoryHive> findAll() {
    List<CategoryHive> categories = box!.values.toList();
    categories.sort((a, b) => a.name!.compareTo(b.name!));
    return categories;
  }

  CategoryHive findById(String id) {
    CategoryHive category =
        box!.values.where((element) => element.id == id).first;
    return category;
  }
}
