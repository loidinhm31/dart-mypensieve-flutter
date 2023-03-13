import 'package:drift/drift.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:my_pensieve/daos/database.dart';
import 'package:my_pensieve/models/base.dart';
import 'package:my_pensieve/models/category.dart' as c;
import 'package:my_pensieve/repositories/sqlite/sync_repository.dart';

class CategoryRepository extends SyncRepository<c.Category> {
  @override
  String get table => 'categories';

  @override
  c.Category creator() {
    return c.Category();
  }

  @override
  Future<void> clear() async {
    await database!.categoriesDao.clearAll();
  }

  @override
  Future<List<c.Category>> syncFindAllByIds(List<String?> ids) {
    return findAllByIds(ids);
  }

  @override
  Future<c.Category?> findById(String id) async {
    Category category = await database!.categoriesDao.findById(id);
    return c.Category.fromDatabase(category);
  }

  @override
  Future<String> save(c.Category object) async {
    Category theCategory =
        await database!.categoriesDao.insert(CategoriesCompanion(
      id: Value(ObjectId().toHexString()),
      name: Value(object.name!),
    ));

    return theCategory.id;
  }

  @override
  Future<void> syncSaveAll(List<BaseClass> objects) async {
    List<CategoriesCompanion> entries = objects.map((e) {
      return CategoriesCompanion.insert(
        id: (e as c.Category).id!,
        name: e.name!,
      );
    }).toList();

    await database!.categoriesDao.insertMultiple(entries);
  }

  @override
  Future<void> syncUpdateAll(List<BaseClass> objects) async {
    List<CategoriesCompanion> entries = objects.map((object) {
      return CategoriesCompanion.insert(
        id: (object as c.Category).id!,
        name: object.name!,
      );
    }).toList();

    await database!.categoriesDao.updateMultiple(entries);
  }

  @override
  Future<void> syncDeleteAll(List<String> ids) async {
    await database!.categoriesDao.deleteMultiple(ids);
  }

  Future<List<c.Category>> findAllByIds(List<String?> ids) async {
    List<Category> categories =
    await database!.categoriesDao.findAllByIdList(ids);

    List<c.Category> resultCategories = categories.map((e) {
      return c.Category.fromDatabase(e);
    }).toList();
    return resultCategories;
  }

  Future<List<c.Category>> findAll() async {
    List<Category> categories =
        await database!.categoriesDao.findAll();
    List<c.Category> resultCategories = categories.map((e) {
      return c.Category.fromDatabase(e);
    }).toList();
    return resultCategories;
  }
}
