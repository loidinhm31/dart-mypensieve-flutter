import 'package:drift/drift.dart';
import 'package:my_pensieve/daos/database.dart';

part 'linked_fragments_dao.g.dart';

@DriftAccessor(tables: [LinkedFragments])
class LinkedFragmentsDao extends DatabaseAccessor<AppDatabase>
    with _$LinkedFragmentsDaoMixin {
  LinkedFragmentsDao(AppDatabase db) : super(db);

  Future<List<LinkedFragment>> findByFragmentId(String fragmentId) async {
    return (select(linkedFragments)..where((tbl) => tbl.fragmentId.equals(fragmentId)))
        .get();
  }

  Future<LinkedFragment> insert(
      LinkedFragmentsCompanion entry) async {
    return into(linkedFragments).insertReturning(entry);
  }

  Future<void> insertMultiple(
      List<LinkedFragmentsCompanion> entries) async {
    await batch((batch) {
      batch.insertAllOnConflictUpdate(
        linkedFragments,
        entries,
      );
    });
  }

  Future<void> deleteMultipleByFragmentId(
      List<String> ids) async {
    (delete(linkedFragments)..where((tbl) => tbl.fragmentId.isIn(ids))).go();
  }

  Future<void> deleteByFragmentIdAndLinkedId(String fragmentId, String linkedId) async {
    (delete(linkedFragments)..where((tbl) {
      return tbl.fragmentId.equals(fragmentId) & tbl.linkedId.equals(linkedId);
    })).go();
  }

  Future<void> clearAll() async {
    delete(linkedFragments).go();
  }
}
