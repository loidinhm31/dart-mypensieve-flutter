import 'package:mongo_dart/mongo_dart.dart';

class MongoRepository {
  // Keeps the finalizer itself reachable, otherwise it might be disposed
  // before the finalizer callback gets a chance to run.
  static final Finalizer<Db> _finalizer =
      Finalizer((connection) => connection.close());

  String dbString =
      'mongodb://mongodb:mongodbpw@127.0.0.1:27017/pensieve?authSource=admin';
  Db? _db;

  Future<void> open() async {
    _db = await Db.create(dbString);
    await _db!.open();
  }

  Future<List<Map<String, dynamic>>> findAll(
      String collection, String sortBy) async {
    var coll = _db!.collection(collection);
    List<Map<String, dynamic>> results =
        await coll.find(where.sortBy(sortBy)).toList();
    return results;
  }

  Future<List<Map<String, dynamic>>> find(
      String collection, Map<String, dynamic> condition) async {
    var coll = _db!.collection(collection);
    List<Map<String, dynamic>> results = await coll.find(condition).toList();
    return results;
  }

  Future<String> insertOne(String collection, Map<String, dynamic> data) async {
    var coll = _db!.collection(collection);
    await coll.insertOne(data);
    return (data['_id'] as ObjectId).$oid;
  }

  Future<void> update(String collection, Map<String, dynamic> update) async {
    var coll = _db!.collection(collection);

    var v0 = await coll.findOne(
        {update['selector']['field'] as String: update['selector']['value']});

    Map<String, dynamic> mapUpdate = update['update'];

    mapUpdate.forEach((key, value) {
      v0![key] = value;
    });

    await coll.replaceOne(
        {update['selector']['field']: update['selector']['value']}, v0!);
  }

  Future<void> delete(String collection, Map<String, dynamic> condition) async {
    var coll = _db!.collection(collection);
    await coll.deleteOne(condition);
  }

  Future<void> close() async {
    // User requested close.
    await _db!.close();
    // Detach from finalizer, no longer needed.
    _finalizer.detach(this);
  }
}
