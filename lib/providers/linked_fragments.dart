import 'package:flutter/material.dart';
import 'package:my_pensieve/models/fragment.dart';

class LinkedFragments with ChangeNotifier {
  List<Fragment> _linkedItems = [];

  List<Fragment> get linkedItems {
    return [..._linkedItems];
  }

  void addLinkedItem(Fragment fragment) {
    if (!_linkedItems.contains(fragment)) {
      _linkedItems.add(fragment);
    }
  }

  void removeLinkedItem(Fragment fragment) {
    _linkedItems.removeWhere((element) => element.id == fragment.id);
  }

  void changeLinkedItems(List<Fragment> fragments) {
    _linkedItems = fragments;
    notifyListeners();
  }

  void clearSelectedLinkedItem() {
    _linkedItems = [];
    notifyListeners();
  }
}
