import 'package:hive/hive.dart';

part 'category.g.dart';

@HiveType(typeId: 2)
class CategoryHive extends HiveObject {
  @HiveField(0)
  String? id;

  @HiveField(1)
  String? name;
}
