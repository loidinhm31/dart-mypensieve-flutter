import 'dart:developer';

import 'package:my_pensieve/models/category.dart';
import 'package:my_pensieve/models/device_sync.dart';
import 'package:my_pensieve/repositories/sqlite/category_repository.dart';
import 'package:my_pensieve/repositories/hive/local_sync_repository.dart';

class CategoryService {
  late final CategoryRepository _categoryRepository;
  late final LocalSyncHiveRepository _localSyncHiveRepository;

  CategoryService() {
    _categoryRepository = CategoryRepository();
    _localSyncHiveRepository = LocalSyncHiveRepository();
  }

  Future<void> addOne(Category category) async {
    _categoryRepository.init();
    await _localSyncHiveRepository.open(_localSyncHiveRepository.boxName);

    try {
      String id = await _categoryRepository.save(category);
      await _localSyncHiveRepository.open(_localSyncHiveRepository.boxName);

      await _localSyncHiveRepository.addData(Category.collection, {
        LocalSync.fAdded: [id],
      });
    } catch (error, stack) {
      log('Error: $error');
      log('StackTrace: $stack');
      rethrow;
    } finally {
      await _localSyncHiveRepository.close();
    }
  }

  Future<Category> getCategoryById(String id) async {
    Category category;
    try {
      _categoryRepository.init();
      category = (await _categoryRepository.findById(id))!;
    } catch (error, stack) {
      log('Error: $error');
      log('StackTrace: $stack');
      rethrow;
    }
    return category;
  }

  Future<List<Category>> getCategories() async {
    List<Category> categories;
    try {
      _categoryRepository.init();
      categories = await _categoryRepository.findAll();
    } catch (error, stack) {
      log('Error: $error');
      log('StackTrace: $stack');
      rethrow;
    }
    return categories;
  }
}
