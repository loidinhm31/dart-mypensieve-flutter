import 'dart:developer';

import 'package:my_pensieve/models/device_sync.dart';
import 'package:my_pensieve/models/hive/category.dart';
import 'package:my_pensieve/models/hive/fragment.dart';
import 'package:my_pensieve/repositories/hive/category_repository.dart';
import 'package:my_pensieve/repositories/hive/fragment_repository.dart';
import 'package:my_pensieve/repositories/hive/local_sync_repository.dart';

class FragmentService {
  late final LocalSyncHiveRepository _localSyncHiveRepository;
  late final FragmentHiveRepository _fragmentHiveRepository;
  late final CategoryHiveRepository _categoryHiveRepository;

  FragmentService() {
    _localSyncHiveRepository = LocalSyncHiveRepository();
    _fragmentHiveRepository = FragmentHiveRepository();
    _categoryHiveRepository = CategoryHiveRepository();
  }

  Future<List<FragmentHive>> getFragments() async {
    await _fragmentHiveRepository.open(_fragmentHiveRepository.boxName);
    await _categoryHiveRepository.open(_categoryHiveRepository.boxName);

    List<FragmentHive> fragments = [];
    try {
      fragments = _fragmentHiveRepository.findAll(true);
      final categories = _categoryHiveRepository.findAll();

      for (var f in fragments) {
        CategoryHive currCategory;
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
    } finally {
      await _fragmentHiveRepository.close();
      await _categoryHiveRepository.close();
    }
    return fragments;
  }

  Future<List<FragmentHive>> getLinkedFragments(List<String?> keys) async {
    await _fragmentHiveRepository.open(_fragmentHiveRepository.boxName);
    await _categoryHiveRepository.open(_categoryHiveRepository.boxName);

    List<FragmentHive> linkedFragments = [];
    try {
      linkedFragments = _fragmentHiveRepository.findAllByKeys(keys);
      final categories = _categoryHiveRepository.findAll();
      for (var f in linkedFragments) {
        CategoryHive currCategory;
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
    } finally {
      await _fragmentHiveRepository.close();
      await _categoryHiveRepository.close();
    }
    return linkedFragments;
  }

  Future<void> addFragment(FragmentHive fragmentHive) async {
    await _fragmentHiveRepository.open(_fragmentHiveRepository.boxName);
    await _localSyncHiveRepository.open(_localSyncHiveRepository.boxName);

    try {
      String id =
          await _fragmentHiveRepository.addOneWithCreatedId(fragmentHive);

      await _localSyncHiveRepository.addData(_fragmentHiveRepository.boxName, {
        LocalSync.fAdded: [id],
      });
    } catch (error, stack) {
      log('Error: $error');
      log('StackTrace: $stack');
      rethrow;
    } finally {
      await _fragmentHiveRepository.close();
      await _localSyncHiveRepository.close();
    }
  }

  Future<void> updateFragment(FragmentHive editFragment) async {
    await _fragmentHiveRepository.open(_fragmentHiveRepository.boxName);
    await _localSyncHiveRepository.open(_localSyncHiveRepository.boxName);

    FragmentHive? fragmentHive =
        _fragmentHiveRepository.findByKey(editFragment.id!);
    if (fragmentHive != null) {
      try {
        fragmentHive.categoryId = editFragment.categoryId;
        fragmentHive.title = editFragment.title;
        fragmentHive.description = editFragment.description;
        fragmentHive.note = editFragment.note;
        fragmentHive.linkedItems = editFragment.linkedItems;
        fragmentHive.date = editFragment.date!.toUtc();
        fragmentHive.save();

        await _localSyncHiveRepository
            .addData(_fragmentHiveRepository.boxName, {
          LocalSync.fUpdated: [fragmentHive.id as String],
        });
      } catch (error, stack) {
        log('Error: $error');
        log('StackTrace: $stack');
        rethrow;
      } finally {
        await _fragmentHiveRepository.close();
        await _localSyncHiveRepository.close();
      }
    }
  }

  Future<void> removeItem(String id) async {
    await _fragmentHiveRepository.open(_fragmentHiveRepository.boxName);
    await _localSyncHiveRepository.open(_localSyncHiveRepository.boxName);

    FragmentHive? fragmentHive = _fragmentHiveRepository.findByKey(id);
    if (fragmentHive != null) {
      try {
        fragmentHive.delete();

        await _localSyncHiveRepository
            .addData(_fragmentHiveRepository.boxName, {
          LocalSync.fDeleted: [fragmentHive.id as String],
        });
      } catch (error, stack) {
        log('Error: $error');
        log('StackTrace: $stack');
        rethrow;
      } finally {
        await _fragmentHiveRepository.close();
        await _localSyncHiveRepository.close();
      }
    }
  }
}
