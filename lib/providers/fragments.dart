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
    _items.add(fragment);
    notifyListeners();
  }
}
