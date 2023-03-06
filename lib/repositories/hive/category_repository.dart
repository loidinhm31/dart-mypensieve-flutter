import 'package:hive/hive.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:my_pensieve/models/hive/category.dart';
import 'package:my_pensieve/repositories/hive/base_repository.dart';

class CategoryHiveRepository extends BaseHiveRepository<CategoryHive> {
  static String boxName = 'categories';

  late Box<CategoryHive> box;

  Future<String> addOneWithCreatedId(CategoryHive categoryHive) async {
    categoryHive.id = mongo.ObjectId().toHexString();
    await box.put(categoryHive.id, categoryHive);
    return categoryHive.id!;
  }

  List<CategoryHive> findAll() {
    List<CategoryHive> categories = box.values.toList();
    categories.sort((a, b) => a.name!.compareTo(b.name!));
    return categories;
  }

  CategoryHive findById(String id) {
    CategoryHive category =
        box.values.where((element) => element.id == id).first;
    return category;
  }
}
