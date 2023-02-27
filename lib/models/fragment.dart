class Fragment {
  String? id;
  String category;
  String title;
  String value;
  String? note;
  DateTime? date;

  Fragment({
    this.id,
    required this.category,
    required this.title,
    required this.value,
    this.note,
    this.date,
  });
}
