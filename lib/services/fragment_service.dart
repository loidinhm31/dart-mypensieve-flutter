import 'dart:developer';

import 'package:my_pensieve/models/category.dart';
import 'package:my_pensieve/models/device_sync.dart';
import 'package:my_pensieve/models/fragment.dart';
import 'package:my_pensieve/repositories/hive/local_sync_repository.dart';
import 'package:my_pensieve/repositories/sqlite/category_repository.dart';
import 'package:my_pensieve/repositories/sqlite/fragment_repository.dart';
import 'package:my_pensieve/repositories/sqlite/linked_fragment_repository.dart';

class FragmentService {
  late final FragmentRepository _fragmentRepository;
  late final LocalSyncHiveRepository _localSyncHiveRepository;
  late final CategoryRepository _categoryRepository;
  late final LinkedFragmentRepository _linkedFragmentRepository;

  FragmentService() {
    _fragmentRepository = FragmentRepository();
    _linkedFragmentRepository = LinkedFragmentRepository();
    _localSyncHiveRepository = LocalSyncHiveRepository();
    _categoryRepository = CategoryRepository();
  }

  Future<List<Fragment>> getFragments() async {
    _fragmentRepository.init();
    _categoryRepository.init();

    List<Fragment> fragments = [];
    try {
      fragments = await _fragmentRepository.findAll();
      final List<Category> categories = await _categoryRepository.findAll();

      for (var f in fragments) {
        Category currCategory;
        try {
          currCategory = categories.firstWhere((c1) => c1.id == f.categoryId,
              orElse: () => throw Exception());
          f.categoryName = currCategory.name;
        } catch (_) {
          f.categoryName = 'UNKNOW';
        }
      }
    } catch (error, stack) {
      log('Error: $error');
      log('StackTrace: $stack');
      rethrow;
    }
    return fragments;
  }

  Future<List<Fragment>> getLinkedFragments(String id) async {
    _fragmentRepository.init();
    _linkedFragmentRepository.init();
    _categoryRepository.init();

    List<Fragment> linkedFragments = [];
    try {
      final linkedIds =
          await _linkedFragmentRepository.findLinkedFragmentsByFragmentId(id);
      linkedFragments = await _fragmentRepository.findAllByIds(linkedIds);

      final List<Category> categories = await _categoryRepository.findAll();
      for (var lf in linkedFragments) {
        Category currCategory;
        try {
          currCategory = categories.firstWhere((c1) => c1.id == lf.categoryId,
              orElse: () => throw Exception());
          lf.categoryName = currCategory.name;
        } catch (_) {
          lf.categoryName = 'UNKNOW';
        }
      }
    } catch (error, stack) {
      log('Error: $error');
      log('StackTrace: $stack');
      rethrow;
    }
    return linkedFragments;
  }

  Future<void> addFragment(Fragment fragment) async {
    _fragmentRepository.init();
    await _localSyncHiveRepository.open(_localSyncHiveRepository.boxName);

    try {
      String id = await _fragmentRepository.save(fragment);

      await _localSyncHiveRepository.addData(_fragmentRepository.table, {
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

  Future<void> updateFragment(Fragment editFragment) async {
    _fragmentRepository.init();
    await _localSyncHiveRepository.open(_localSyncHiveRepository.boxName);

    Fragment? fragment = await _fragmentRepository.findById(editFragment.id!);
    if (fragment != null) {
      try {
        fragment.categoryId = editFragment.categoryId;
        fragment.title = editFragment.title;
        fragment.description = editFragment.description;
        fragment.note = editFragment.note;
        fragment.linkedItems = editFragment.linkedItems;
        fragment.date = editFragment.date!;

        await _fragmentRepository.update(fragment);

        await _localSyncHiveRepository.addData(_fragmentRepository.table, {
          LocalSync.fUpdated: [fragment.id as String],
        });
      } catch (error, stack) {
        log('Error: $error');
        log('StackTrace: $stack');
        rethrow;
      } finally {
        await _localSyncHiveRepository.close();
      }
    }
  }

  Future<void> removeItem(String id) async {
    _fragmentRepository.init();
    await _localSyncHiveRepository.open(_localSyncHiveRepository.boxName);

    Fragment? fragment = await _fragmentRepository.findById(id);
    if (fragment != null) {
      try {
        await _fragmentRepository.delete(fragment.id!);

        await _localSyncHiveRepository.addData(_fragmentRepository.table, {
          LocalSync.fDeleted: [fragment.id as String],
        });
      } catch (error, stack) {
        log('Error: $error');
        log('StackTrace: $stack');
        rethrow;
      } finally {
        await _localSyncHiveRepository.close();
      }
    }
  }
}
