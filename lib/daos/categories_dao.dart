import 'package:drift/drift.dart';
import 'package:my_pensieve/daos/database.dart';

part 'categories_dao.g.dart';

@DriftAccessor(tables: [Categories])
class CategoriesDao extends DatabaseAccessor<AppDatabase>
    with _$CategoriesDaoMixin {
  CategoriesDao(AppDatabase db) : super(db);

  Future<List<Category>> findAll() async {
    return select(categories).get();
  }

  Future<List<Category>> findAllByIdList(List<String?> ids) async {
    return (select(categories)
          ..where((tbl) => tbl.id.isIn(ids.map((e) => e.toString()))))
        .get();
  }

  Future<Category> findById(String id) async {
    return (select(categories)..where((tbl) => tbl.id.equals(id))).getSingle();
  }

  Future<Category> insert(CategoriesCompanion entry) async {
    return into(categories).insertReturning(entry);
  }

  Future<void> insertMultiple(
      List<CategoriesCompanion> entries) async {
    await batch((batch) {
      batch.insertAll(
        categories,
        entries,
      );
    });
  }

  Future<void> updateMultiple(
      List<CategoriesCompanion> entries) async {
    await batch((batch) {
      batch.insertAllOnConflictUpdate(
        categories,
        entries,
      );
    });
  }

  Future<void> deleteMultiple(List<String> ids) async {
    (delete(categories)..where((tbl) => tbl.id.isIn(ids))).go();
  }

  Future<void> clearAll() async {
    delete(categories).go();
  }
}
