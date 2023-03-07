import 'package:my_pensieve/models/category.dart';
import 'package:my_pensieve/models/device_sync.dart';
import 'package:my_pensieve/models/hive/category.dart';
import 'package:my_pensieve/repositories/hive/category_repository.dart';
import 'package:my_pensieve/repositories/hive/local_sync_repository.dart';

class CategoryService {
  static List<CategoryHive> items = [];

  late final CategoryHiveRepository _categoryHiveRepository;
  late final LocalSyncHiveRepository _localSyncHiveRepository;

  CategoryService() {
    _categoryHiveRepository = CategoryHiveRepository();
    _localSyncHiveRepository = LocalSyncHiveRepository();
  }

  Future<void> addOne(CategoryHive categoryHive) async {
    await _categoryHiveRepository.open(_categoryHiveRepository.boxName);
    await _localSyncHiveRepository.open(_localSyncHiveRepository.boxName);

    try {
      String id =
          await _categoryHiveRepository.addOneWithCreatedId(categoryHive);
      await _localSyncHiveRepository.open(_localSyncHiveRepository.boxName);

      await _localSyncHiveRepository.add(Category.collection, {
        LocalSync.fAdded: [id],
      });
    } finally {
      await _categoryHiveRepository.close();
      await _localSyncHiveRepository.close();
    }
  }

  Future<CategoryHive> getCategoryById(String id) async {
    CategoryHive categoryHive;
    try {
      await _categoryHiveRepository.open(_categoryHiveRepository.boxName);
      categoryHive = _categoryHiveRepository.findById(id);
    } finally {
      await _categoryHiveRepository.close();
    }
    return categoryHive;
  }

  Future<List<CategoryHive>> getCategories() async {
    List<CategoryHive> categories;
    try {
      await _categoryHiveRepository.open(_categoryHiveRepository.boxName);
      categories = _categoryHiveRepository.findAll();
    } finally {
      await _categoryHiveRepository.close();
    }
    return categories;
  }
}
