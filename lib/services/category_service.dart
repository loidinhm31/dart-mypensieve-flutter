import 'package:my_pensieve/models/hive/category.dart';
import 'package:my_pensieve/repositories/hive/category_repository.dart';

class CategoryService {
  static List<CategoryHive> items = [];

  late CategoryHiveRepository categoryHiveRepository;

  CategoryService() {
    categoryHiveRepository = CategoryHiveRepository();
  }

  Future<void> addOne(CategoryHive categoryHive) async {
    try {
      await categoryHiveRepository.open(CategoryHiveRepository.boxName);
      String id =
          await categoryHiveRepository.addOneWithCreatedId(categoryHive);
    } finally {
      await categoryHiveRepository.close();
    }
  }

  Future<CategoryHive> getCategoryById(String id) async {
    CategoryHive categoryHive;
    try {
      await categoryHiveRepository.open(CategoryHiveRepository.boxName);
      categoryHive = categoryHiveRepository.findById(id);
    } finally {
      await categoryHiveRepository.close();
    }
    return categoryHive;
  }

  Future<List<CategoryHive>> getCategories() async {
    List<CategoryHive> categories;
    try {
      await categoryHiveRepository.open(CategoryHiveRepository.boxName);
      categories = categoryHiveRepository.findAll();
    } finally {
      await categoryHiveRepository.close();
    }
    return categories;
  }
}
