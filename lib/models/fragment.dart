class Fragment {
  final String? id;
  final String category;
  final String title;
  final String value;
  final String? note;
  final DateTime? date;

  Fragment({
    this.id,
    required this.category,
    required this.title,
    required this.value,
    this.note,
    this.date,
  });
}
