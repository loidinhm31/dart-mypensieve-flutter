import 'package:flutter/material.dart';
import 'package:my_pensieve/models/hive/fragment.dart';

class LinkedFragments with ChangeNotifier {
  List<FragmentHive> _linkedItems = [];

  List<FragmentHive> get linkedItems {
    return [..._linkedItems];
  }

  void addLinkedItem(FragmentHive fragment) {
    if (!_linkedItems.contains(fragment)) {
      _linkedItems.add(fragment);
    }
  }

  void removeLinkedItem(FragmentHive fragment) {
    _linkedItems.removeWhere((element) => element.id == fragment.id);
  }

  void changeLinkedItems(List<FragmentHive> fragments) {
    _linkedItems = fragments;
    notifyListeners();
  }

  void clearSelectedLinkedItem() {
    _linkedItems = [];
    notifyListeners();
  }
}
