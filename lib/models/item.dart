class Item {
  final String? id;
  final String category;
  final String title;
  final String value;
  final DateTime? date;

  Item({
    this.id,
    required this.category,
    required this.title,
    required this.value,
    required this.date,
  });
}
