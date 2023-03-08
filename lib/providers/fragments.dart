import 'package:flutter/widgets.dart';
import 'package:my_pensieve/models/hive/fragment.dart';
import 'package:my_pensieve/services/fragment_service.dart';

class Fragments with ChangeNotifier {
  List<FragmentHive> _items = [];

  List<FragmentHive> get items {
    return [..._items];
  }

  FragmentHive findById(String id) {
    return _items.firstWhere((el) => el.id == id,
        orElse: () => throw Exception());
  }

  Future<void> fetchAndSetFragments() async {
    final FragmentService fragmentService = FragmentService();
    try {
      _items = await fragmentService.getFragments();
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> addFragment(FragmentHive fragment) async {
    final FragmentService fragmentService = FragmentService();

    try {
      await fragmentService.addFragment(fragment);
      _items.add(fragment);
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> updateFragment(FragmentHive editFragment) async {
    final fragmentIndex = _items.indexWhere((el) => el.id == editFragment.id);

    if (fragmentIndex >= 0) {
      final FragmentService fragmentService = FragmentService();
      try {
        await fragmentService.updateFragment(editFragment);

        _items[fragmentIndex] = editFragment;
        notifyListeners();
      } catch (error) {
        rethrow;
      }
    }
  }

  Future<void> removeItem(String id) async {
    final fragmentIndex = _items.indexWhere((el) => el.id == id);

    if (fragmentIndex >= 0) {
      final FragmentService fragmentService = FragmentService();

      try {
        fragmentService.removeItem(id);
        _items.removeAt(fragmentIndex);
        notifyListeners();
      } catch (error) {
        rethrow;
      }
    }
  }
}
