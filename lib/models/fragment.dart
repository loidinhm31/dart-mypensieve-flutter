class Fragment {
  final String? id;
  final String category;
  final String title;
  final String value;
  final DateTime? date;

  Fragment({
    this.id,
    required this.category,
    required this.title,
    required this.value,
    required this.date,
  });
}
