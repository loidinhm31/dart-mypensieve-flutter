import 'package:drift/drift.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:my_pensieve/daos/database.dart';
import 'package:my_pensieve/models/pageable.dart';

part 'fragments_dao.g.dart';

@DriftAccessor(tables: [Fragments])
class FragmentsDao extends DatabaseAccessor<AppDatabase>
    with _$FragmentsDaoMixin {
  FragmentsDao(AppDatabase db) : super(db);

  Future<List<Fragment>> findAll() async {
    return select(fragments).get();
  }

  Future<List<FragmentWithCategoryName>> findPageableAll(
      Pageable pageable) async {
    final categories = alias(db.categories, 'c');
    final query = select(fragments).join([
      leftOuterJoin(
        categories,
        categories.id.equalsExp(fragments.categoryId),
      )
    ]);
    query.limit(
      pageable.pageSize,
      offset: (pageable.pageSize * pageable.pageNumber),
    );
    query.orderBy(
        [OrderingTerm(expression: fragments.date, mode: OrderingMode.desc)]);
    final rows = await query.get();
    return rows.map((row) {
      return FragmentWithCategoryName(
        fragment: row.readTable(fragments),
        categoryName: row.read(categories.name),
      );
    }).toList();
  }

  Future<List<Fragment>> findAllByIdList(List<String?> ids) async {
    return (select(fragments)
          ..where((tbl) => tbl.id.isIn(ids.map((e) => e.toString()))))
        .get();
  }

  Future<List<FragmentWithCategoryName>> findAllWithCategoryByIdList(
      List<String?> ids) async {
    final categories = alias(db.categories, 'c');

    final query = select(fragments).join([
      leftOuterJoin(
        categories,
        categories.id.equalsExp(fragments.categoryId),
      ),
    ]);
    query.where(fragments.id.isIn(ids.map((e) => e.toString())));
    final rows = await query.get();
    return rows.map((row) {
      return FragmentWithCategoryName(
          fragment: row.readTable(fragments),
          categoryName: row.read(categories.name));
    }).toList();
  }

  Future<Fragment> findById(String id) async {
    return (select(fragments)..where((tbl) => tbl.id.equals(id))).getSingle();
  }

  Future<List<Fragment>> findAllByTitle(String title) async {
    return (select(fragments)..where((tbl) => tbl.title.equals(title))).get();
  }

  Future<Fragment> insert(FragmentsCompanion entry) async {
    return into(fragments).insertReturning(entry);
  }

  Future<void> updateById(String id, FragmentsCompanion targetEntry) async {
    (update(fragments)..where((tbl) => tbl.id.equals(id))).write(
      targetEntry,
    );
  }

  Future<void> insertOrReplace(FragmentsCompanion entry) async {
    into(fragments).insertOnConflictUpdate(entry);
  }

  Future<void> deleteById(String id) async {
    (delete(fragments)..where((tbl) => tbl.id.equals(id))).go();
  }

  Future<void> insertMultiple(List<FragmentsCompanion> entries) async {
    await batch((batch) {
      batch.insertAll(
        fragments,
        entries,
      );
    });
  }

  Future<void> updateMultiple(List<FragmentsCompanion> entries) async {
    await batch((batch) {
      batch.insertAllOnConflictUpdate(
        fragments,
        entries,
      );
    });
  }

  Future<void> deleteMultiple(List<String> ids) async {
    (delete(fragments)..where((tbl) => tbl.id.isIn(ids))).go();
  }

  Future<void> clearAll() async {
    delete(fragments).go();
  }
}

class FragmentWithCategoryName {
  final Fragment fragment;
  final String? categoryName;

  FragmentWithCategoryName(
      {required this.fragment, required this.categoryName});
}
