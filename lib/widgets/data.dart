import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mongo_dart/mongo_dart.dart';

class DataWidget extends StatelessWidget {
  const DataWidget({super.key});

  void test() async {
    var db =
        await Db.create('mongodb://mongodb:mongodbpw@localhost:27017/qushift');
    await db.open();
    var coll = db.collection('topics');
    await coll.insertOne(
        {'login': 'jdoe', 'name': 'John Doe', 'email': 'john@doe.com'});

    var v1 = await coll.findOne({'name': 'b'});

    if (v1 != null) {
      print(v1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          ElevatedButton(onPressed: test, child: Text('hit')),
          Text('T2')
        ]);
  }
}
