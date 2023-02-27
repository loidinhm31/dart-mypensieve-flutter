import 'package:flutter/widgets.dart';
import 'package:my_pensieve/models/fragment.dart';

class Fragments with ChangeNotifier {
  List<Fragment> _items = [
    Fragment(
      id: "1",
      category: 'category1',
      title: 'title1',
      value: 'value1',
      note: 'note test 1',
      date: DateTime.now(),
    ),
    Fragment(
      id: "2",
      category: 'category2',
      title: 'title2',
      value: 'value2',
      note: 'note test 2',
      date: DateTime.now(),
    ),
  ];

  List<Fragment> get items {
    return [..._items];
  }

  Fragment findById(String id) {
    return _items.firstWhere((el) => el.id == id);
  }

  void addFragment(Fragment fragment) {
    fragment.id = DateTime.now().toString(); // TODO remove
    _items.add(fragment);
    notifyListeners();
  }

  void updateFragment(String id, Fragment newFragment) {
    final fragmentIndex = _items.indexWhere((el) => el.id == id);
    if (fragmentIndex >= 0) {
      _items[fragmentIndex] = newFragment;
      notifyListeners();
    }
  }
}
