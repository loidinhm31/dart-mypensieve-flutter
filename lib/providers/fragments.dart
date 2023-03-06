import 'package:flutter/widgets.dart';
import 'package:my_pensieve/models/device_sync.dart';
import 'package:my_pensieve/models/hive/category.dart';
import 'package:my_pensieve/models/hive/fragment.dart';
import 'package:my_pensieve/repositories/hive/category_repository.dart';
import 'package:my_pensieve/repositories/hive/fragment_repository.dart';
import 'package:my_pensieve/repositories/hive/local_sync_repository.dart';

class Fragments with ChangeNotifier {
  final _fragmentsColl = 'fragments';

  List<FragmentHive> _items = [];

  List<FragmentHive> get items {
    return [..._items];
  }

  FragmentHive findById(String id) {
    return _items.firstWhere((el) => el.id == id,
        orElse: () => throw Exception());
  }

  Future<void> fetchAndSetFragments() async {
    final FragmentHiveRepository fragmentHiveRepository =
        FragmentHiveRepository();
    await fragmentHiveRepository.open(FragmentHiveRepository.boxName);

    final CategoryHiveRepository categoryHiveRepository =
        CategoryHiveRepository();
    await categoryHiveRepository.open(CategoryHiveRepository.boxName);

    try {
      final categories = categoryHiveRepository.findAll();

      final fragments = fragmentHiveRepository.findAll(true);
      for (var f in fragments) {
        CategoryHive c = categories.firstWhere((c1) => c1.id == f.categoryId);
        f.categoryName = c.name;
      }

      if (fragments.isNotEmpty) {
        _items = fragments;
        notifyListeners();
      } else {
        _items = [];
        notifyListeners();
      }
    } catch (error) {
      rethrow;
    } finally {
      await fragmentHiveRepository.close();
    }
  }

  Future<void> addFragment(FragmentHive fragment) async {
    final FragmentHiveRepository fragmentHiveRepository =
        FragmentHiveRepository();
    await fragmentHiveRepository.open(FragmentHiveRepository.boxName);

    final LocalSyncHiveRepository localSyncHiveRepository =
        LocalSyncHiveRepository();
    await localSyncHiveRepository.open(LocalSyncHiveRepository.boxName);

    try {
      String id = await fragmentHiveRepository.addOneWithCreatedId(fragment);

      await localSyncHiveRepository.add('fragments', {
        LocalSync.ADDED: [id],
      });
    } catch (error) {
      rethrow;
    } finally {
      _items.add(fragment);
      notifyListeners();

      await fragmentHiveRepository.close();
      await localSyncHiveRepository.close();
    }
  }

  Future<void> updateFragment(FragmentHive editFragment) async {
    final fragmentIndex = _items.indexWhere((el) => el.id == editFragment.id);

    if (fragmentIndex >= 0) {
      final FragmentHiveRepository fragmentHiveRepository =
          FragmentHiveRepository();
      await fragmentHiveRepository.open(FragmentHiveRepository.boxName);

      final LocalSyncHiveRepository localSyncHiveRepository =
          LocalSyncHiveRepository();
      await localSyncHiveRepository.open(LocalSyncHiveRepository.boxName);

      FragmentHive? fragmentHive =
          fragmentHiveRepository.findByKey(editFragment.id!);
      if (fragmentHive != null) {
        try {
          fragmentHive.categoryId = editFragment.categoryId;
          fragmentHive.title = editFragment.title;
          fragmentHive.description = editFragment.description;
          fragmentHive.note = editFragment.note;
          fragmentHive.linkedItems = editFragment.linkedItems;
          fragmentHive.date = editFragment.date!.toUtc();
          fragmentHive.save();

          await localSyncHiveRepository.add('fragments', {
            LocalSync.UPDATED: [fragmentHive.id as String],
          });
        } catch (error) {
          rethrow;
        } finally {
          _items[fragmentIndex] = editFragment;
          notifyListeners();

          await fragmentHiveRepository.close();
          await localSyncHiveRepository.close();
        }
      }
    }
  }

  Future<void> removeItem(String id) async {
    final fragmentIndex = _items.indexWhere((el) => el.id == id);

    if (fragmentIndex >= 0) {
      final FragmentHiveRepository fragmentHiveRepository =
          FragmentHiveRepository();
      await fragmentHiveRepository.open(FragmentHiveRepository.boxName);

      final LocalSyncHiveRepository localSyncHiveRepository =
          LocalSyncHiveRepository();
      await localSyncHiveRepository.open(LocalSyncHiveRepository.boxName);

      FragmentHive? fragmentHive = fragmentHiveRepository.findByKey(id);
      if (fragmentHive != null) {
        try {
          fragmentHive.delete();

          await localSyncHiveRepository.add('fragments', {
            LocalSync.DELETED: [fragmentHive.id as String],
          });
        } catch (error) {
          rethrow;
        } finally {
          _items.removeAt(fragmentIndex);
          notifyListeners();

          await fragmentHiveRepository.close();
          await localSyncHiveRepository.close();
        }
      }
    }
  }
}
