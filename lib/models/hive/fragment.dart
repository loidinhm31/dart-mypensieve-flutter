import 'package:hive/hive.dart';

part 'fragment.g.dart';

@HiveType(typeId: 1)
class FragmentHive extends HiveObject {
  @HiveField(0)
  String? id;

  @HiveField(1)
  String? categoryId;

  String? categoryName;

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
}
