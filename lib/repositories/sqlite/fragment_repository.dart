import 'package:drift/drift.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:my_pensieve/daos/database.dart';
import 'package:my_pensieve/daos/fragments_dao.dart';
import 'package:my_pensieve/models/base.dart';
import 'package:my_pensieve/models/fragment.dart' as f;
import 'package:my_pensieve/models/pageable.dart';
import 'package:my_pensieve/repositories/sqlite/sync_repository.dart';

class FragmentRepository extends SyncRepository<f.Fragment> {
  @override
  String get table => 'fragments';

  @override
  f.Fragment creator() {
    return f.Fragment();
  }

  @override
  Future<void> clear() async {
    database!.fragmentsDao.clearAll();
  }

  @override
  Future<List<f.Fragment>> syncFindAllByIds(List<String?> ids) async {
    List<Fragment> fragments =
        await database!.fragmentsDao.findAllByIdList(ids);
    List<f.Fragment> resultFragments = [];
    for (var el in fragments) {
      f.Fragment fragment = f.Fragment.fromDatabase(el);
      List<String> linkedIds =
          (await database!.linkedFragmentsDao.findByFragmentId(el.id))
              .map((e) => e.linkedId)
              .toList();
      fragment.linkedItems = linkedIds;

      resultFragments.add(fragment);
    }
    return resultFragments;
  }

  @override
  Future<f.Fragment?> findById(String id) async {
    Fragment fragment = await database!.fragmentsDao.findById(id);
    return f.Fragment.fromDatabase(fragment);
  }

  @override
  Future<String> save(f.Fragment object) async {
    String createdId = ObjectId().toHexString();
    Fragment theFragment =
        await database!.fragmentsDao.insert(FragmentsCompanion(
      id: Value(createdId),
      categoryId: Value(object.categoryId!),
      title: Value(object.title!),
      description: Value(object.description!),
      note: object.note == null ? const Value(null) : Value(object.note!),
      date: Value(object.date!),
    ));

    if (object.linkedItems != null) {
      List<LinkedFragmentsCompanion> linkedEntries = [];

      for (var l in object.linkedItems!) {
        linkedEntries.add(
          LinkedFragmentsCompanion(
            fragmentId: Value(createdId),
            linkedId: Value(l),
          ),
        );
      }

      await database!.linkedFragmentsDao.insertMultiple(linkedEntries);
    }
    return theFragment.id;
  }

  @override
  Future<void> syncSaveAll(List<BaseClass> objects) async {
    for (var object in objects) {
      await database!.fragmentsDao.insert(
        FragmentsCompanion.insert(
          id: (object as f.Fragment).id!,
          categoryId: object.categoryId!,
          title: object.title!,
          description: object.description!,
          note: object.note == null ? const Value(null) : Value(object.note!),
          date: object.date!,
        ),
      );

      if (object.linkedItems != null) {
        List<LinkedFragmentsCompanion> linkedEntries = [];

        for (var l in object.linkedItems!) {
          linkedEntries.add(
            LinkedFragmentsCompanion(
              fragmentId: Value(object.id!),
              linkedId: Value(l),
            ),
          );
        }
        await database!.linkedFragmentsDao.insertMultiple(linkedEntries);
      }
    }
  }

  @override
  Future<void> syncUpdateAll(List<BaseClass> objects) async {
    List<FragmentsCompanion> entries = [];

    for (var object in objects) {
      entries.add(
        FragmentsCompanion.insert(
          id: (object as f.Fragment).id!,
          categoryId: object.categoryId!,
          title: object.title!,
          description: object.description!,
          note: object.note == null ? const Value(null) : Value(object.note!),
          date: object.date!,
        ),
      );

      if (object.linkedItems != null) {
        _updateLinkedFragments(object);
      }
    }

    // Update fragments
    await database!.fragmentsDao.updateMultiple(entries);
  }

  @override
  Future<void> syncDeleteAll(List<String> ids) async {
    await database!.linkedFragmentsDao.deleteMultipleByFragmentId(ids);

    await database!.fragmentsDao.deleteMultiple(ids);
  }

  Future<List<f.Fragment>> findAllByIds(List<String?> ids) async {
    List<FragmentWithCategoryName> fragments =
        await database!.fragmentsDao.findAllWithCategoryByIdList(ids);

    List<f.Fragment> resultFragments = fragments.map((e) {
      return f.Fragment.fromDatabaseWithCustomFields(e);
    }).toList();
    return resultFragments;
  }

  Future<List<f.Fragment>> findAll() async {
    List<Fragment> fragments = await database!.fragmentsDao.findAll();

    List<f.Fragment> resultFragments = fragments.map((e) {
      return f.Fragment.fromDatabase(e);
    }).toList();
    return resultFragments;
  }

  Future<List<f.Fragment>> findPageableAll(Pageable pageable) async {
    List<FragmentWithCategoryName> fragments =
        await database!.fragmentsDao.findPageableAll(pageable);

    List<f.Fragment> resultFragments = fragments.map((e) {
      return f.Fragment.fromDatabaseWithCustomFields(e);
    }).toList();
    return resultFragments;
  }

  Future<List<f.Fragment>> findAllByTitle(String title) async {
    List<Fragment> fragments =
        await database!.fragmentsDao.findAllByTitle(title);

    List<f.Fragment> resultFragments = fragments.map((e) {
      return f.Fragment.fromDatabase(e);
    }).toList();
    return resultFragments;
  }

  Future<void> update(f.Fragment object) async {
    await database!.fragmentsDao.updateById(
      object.id!,
      FragmentsCompanion(
        categoryId: Value(object.categoryId!),
        title: Value(object.title!),
        description: Value(object.description!),
        note: object.note == null ? const Value(null) : Value(object.note!),
        date: Value(object.date!),
      ),
    );

    if (object.linkedItems != null) {
      _updateLinkedFragments(object);
    }
  }

  Future<void> _updateLinkedFragments(f.Fragment fragment) async {
    List<LinkedFragmentsCompanion> addingIds = [];

    List<LinkedFragment> linkedFragments =
        await database!.linkedFragmentsDao.findByFragmentId(fragment.id!);

    // Check and delete linked fragments
    for (LinkedFragment savedObject in linkedFragments) {
      if (!fragment.linkedItems!
          .any((updateId) => updateId == savedObject.linkedId)) {
        database!.linkedFragmentsDao.deleteByFragmentIdAndLinkedId(
            savedObject.fragmentId, savedObject.linkedId);
      }
    }

    // Check and add linked fragments
    for (String newId in fragment.linkedItems!) {
      if (!linkedFragments
          .any((savedObject) => savedObject.linkedId == newId)) {
        addingIds.add(LinkedFragmentsCompanion.insert(
            fragmentId: fragment.id!, linkedId: newId));
      }
    }

    // Insert new linked fragments
    database!.linkedFragmentsDao.insertMultiple(addingIds);
  }

  Future<void> delete(String id) async {
    await database!.fragmentsDao.deleteById(id);
  }
}
