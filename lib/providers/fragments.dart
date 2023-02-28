import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:my_pensieve/models/fragment.dart';

class Fragments with ChangeNotifier {
  final _fragmentsRef = 'pensieve/fragments';

  List<Fragment> _items = [];

  List<Fragment> get items {
    return [..._items];
  }

  Fragment findById(String id) {
    return _items.firstWhere((el) => el.id == id);
  }

  Future<void> fetchAndSetFragments() async {
    DatabaseReference fragmentsRef =
        FirebaseDatabase.instance.ref(_fragmentsRef);
    try {
      final snapshot = await fragmentsRef.get();

      if (snapshot.exists) {
        final List<Fragment> loadedFragments = [];
        final responseData =
            jsonDecode(jsonEncode(snapshot.value)) as Map<String, dynamic>;
        responseData.forEach((fragmentId, fragmentData) {
          loadedFragments.add(Fragment(
            id: fragmentData['id'],
            category: fragmentData['category'],
            title: fragmentData['title'],
            description: fragmentData['description'],
            note: fragmentData['note'],
            date: DateFormat('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'')
                .parse(fragmentData['date']),
          ));
        });

        _items = loadedFragments;
        notifyListeners();
      } else {
        if (snapshot.children.isEmpty) {
          _items = [];
          notifyListeners();
        }
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<void> addFragment(Fragment fragment) async {
    DatabaseReference fragmentsRef =
        FirebaseDatabase.instance.ref(_fragmentsRef);
    DatabaseReference newFragmensRef = fragmentsRef.push();

    try {
      await newFragmensRef.set({
        'id': newFragmensRef.key,
        'category': fragment.category,
        'title': fragment.title,
        'description': fragment.description,
        'note': fragment.note,
        'date': fragment.date?.toUtc().toIso8601String(),
      });

      notifyListeners();
    } catch (error) {
      rethrow;
    }

    _items.add(fragment);
    notifyListeners();
  }

  Future<void> updateFragment(String id, Fragment newFragment) async {
    final fragmentIndex = _items.indexWhere((el) => el.id == id);

    if (fragmentIndex >= 0) {
      DatabaseReference fragmentsRef =
          FirebaseDatabase.instance.ref('$_fragmentsRef/$id');

      fragmentsRef.child('category').set(newFragment.category);
      fragmentsRef.child('title').set(newFragment.title);
      fragmentsRef.child('description').set(newFragment.description);
      fragmentsRef.child('note').set(newFragment.note);
      fragmentsRef
          .child('date')
          .set(newFragment.date?.toUtc().toIso8601String());

      // _items[fragmentIndex] = newFragment;
      notifyListeners();
    }
  }
}
