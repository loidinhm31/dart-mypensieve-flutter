import 'package:hive/hive.dart';

part 'fragment.g.dart';

@HiveType(typeId: 0)
class FragmentHive extends HiveObject {
  @HiveField(0)
  String? id;

  @HiveField(1)
  String? category;

  @HiveField(2)
  String? title;

  @HiveField(3)
  String? description;

  @HiveField(4)
  String? note;

  @HiveField(5)
  List<String?>? linkedItems;

  @HiveField(6)
  DateTime? date;

  @HiveField(7)
  bool? sync;
}
