import 'package:flutter/widgets.dart';
import 'package:my_pensieve/models/hive/fragment.dart';
import 'package:my_pensieve/repository/hive/fragment_repository.dart';

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
    await fragmentHiveRepository.open();
    try {
      final fragments = fragmentHiveRepository.findAll();

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
    await fragmentHiveRepository.open();

    try {
      await fragmentHiveRepository.add(fragment);
    } catch (error) {
      rethrow;
    } finally {
      _items.add(fragment);
      notifyListeners();

      await fragmentHiveRepository.close();
    }
  }

  Future<void> updateFragment(FragmentHive editFragment) async {
    final fragmentIndex = _items.indexWhere((el) => el.id == editFragment.id);

    if (fragmentIndex >= 0) {
      final FragmentHiveRepository fragmentHiveRepository =
          FragmentHiveRepository();
      await fragmentHiveRepository.open();

      FragmentHive? fragmentHive =
          fragmentHiveRepository.findByKey(editFragment.id!);
      if (fragmentHive != null) {
        try {
          fragmentHive.category = editFragment.category;
          fragmentHive.title = editFragment.title;
          fragmentHive.description = editFragment.description;
          fragmentHive.note = editFragment.note;
          fragmentHive.date = editFragment.date!.toUtc();
          fragmentHive.save();
        } catch (error) {
          rethrow;
        } finally {
          _items[fragmentIndex] = editFragment;
          notifyListeners();

          await fragmentHiveRepository.close();
        }
      }
    }
  }

  Future<void> removeItem(String id) async {
    final fragmentIndex = _items.indexWhere((el) => el.id == id);

    if (fragmentIndex >= 0) {
      final FragmentHiveRepository fragmentHiveRepository =
          FragmentHiveRepository();
      await fragmentHiveRepository.open();

      FragmentHive? fragmentHive = fragmentHiveRepository.findByKey(id);
      if (fragmentHive != null) {
        try {
          fragmentHive.delete();
        } catch (error) {
          rethrow;
        } finally {
          await fragmentHiveRepository.close();
          _items.removeAt(fragmentIndex);
          notifyListeners();
        }
      }
    }
  }
}
