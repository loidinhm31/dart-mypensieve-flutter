import 'package:flutter/widgets.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:my_pensieve/models/fragment.dart';
import 'package:my_pensieve/repository/mongo_repository.dart';

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
    final MongoRepository mongoRepository = MongoRepository();
    await mongoRepository.open();

    try {
      final fragments = await mongoRepository.findAll('fragments', 'date');

      if (fragments.isNotEmpty) {
        final List<Fragment> loadedFragments = [];
        for (var element in fragments) {
          loadedFragments.add(Fragment.fromMap(element));
        }

        _items = loadedFragments;
        notifyListeners();
      } else {
        _items = [];
        notifyListeners();
      }
    } catch (error) {
      rethrow;
    } finally {
      await mongoRepository.close();
    }
  }

  Future<void> addFragment(Fragment fragment) async {
    final MongoRepository mongoRepository = MongoRepository();
    await mongoRepository.open();

    try {
      await mongoRepository
          .insertOne('fragments', fragment.toMap())
          .then((_id) => fragment.id = _id);
    } catch (error) {
      rethrow;
    } finally {
      _items.add(fragment);
      notifyListeners();

      await mongoRepository.close();
    }
  }

  Future<void> updateFragment(String id, Fragment newFragment) async {
    final fragmentIndex = _items.indexWhere((el) => el.id == id);

    if (fragmentIndex >= 0) {
      final MongoRepository mongoRepository = MongoRepository();
      await mongoRepository.open();
      try {
        Map<String, dynamic> update = {
          'selector': {
            'field': Fragment.ID,
            'value': ObjectId.parse(id),
          },
          'update': newFragment.toMapUpdate(),
        };
        print(update);
        await mongoRepository.update('fragments', update);
      } catch (error) {
        rethrow;
      } finally {
        _items[fragmentIndex] = newFragment;
        notifyListeners();

        await mongoRepository.close();
      }
    }
  }
}
