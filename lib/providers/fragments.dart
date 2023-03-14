import 'package:flutter/widgets.dart';
import 'package:my_pensieve/models/fragment.dart';
import 'package:my_pensieve/models/pageable.dart';
import 'package:my_pensieve/services/fragment_service.dart';

class Fragments with ChangeNotifier {
  List<Fragment> _items = [];

  List<Fragment> get items {
    return [..._items];
  }

  Fragment findById(String id) {
    return _items.firstWhere((el) => el.id == id,
        orElse: () => throw Exception());
  }

  Future<void> fetchAndSetFragments(Pageable pageable) async {
    final FragmentService fragmentService = FragmentService();
    try {
      _items = await fragmentService.getPageableFragments(
        Pageable(pageNumber: pageable.pageNumber),
      );
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<List<Fragment>> fetchFragments(Pageable pageable) async {
    final FragmentService fragmentService = FragmentService();
    List<Fragment> newFragments = [];
    try {
      newFragments = await fragmentService.getPageableFragments(
        Pageable(pageNumber: pageable.pageNumber),
      );
    } catch (error) {
      rethrow;
    }
    _items.addAll(newFragments);

    return newFragments;
  }

  Future<void> addFragment(Fragment fragment) async {
    final FragmentService fragmentService = FragmentService();

    try {
      await fragmentService.addFragment(fragment);
    } catch (error) {
      rethrow;
    }
    _items.add(fragment);
    notifyListeners();
  }

  Future<void> updateFragment(Fragment editFragment) async {
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
