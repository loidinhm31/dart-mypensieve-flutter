import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:my_pensieve/daos/categories_dao.dart';
import 'package:my_pensieve/daos/fragments_dao.dart';
import 'package:my_pensieve/daos/linked_fragments_dao.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'database.g.dart';

@DataClassName('Category')
class Categories extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
}

class Fragments extends Table {
  TextColumn get id => text()();
  TextColumn get categoryId => text().named('category_id')();
  TextColumn get title => text()();
  TextColumn get description => text()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get date => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class LinkedFragments extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get fragmentId =>
      text().named('fragment_id').references(Fragments, #id)();
  TextColumn get linkedId =>
      text().named('linked_id').references(Fragments, #id)();

  @override
  List<Set<Column>> get uniqueKeys => [
        {fragmentId, linkedId}
      ];
}

@DriftDatabase(tables: [
  Categories,
  Fragments,
  LinkedFragments,
], daos: [
  CategoriesDao,
  FragmentsDao,
  LinkedFragmentsDao,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) async {
        await m.createAll();
      },
    );
  }
}

LazyDatabase _openConnection() {
  // the LazyDatabase util lets us find the right location for the file async.
  return LazyDatabase(() async {
    // put the database file, called db.sqlite here, into the documents folder
    // for your app.
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join('${dbFolder.path}/pensieve', 'db.sqlite'));

    return NativeDatabase.createInBackground(file);
  });
}
