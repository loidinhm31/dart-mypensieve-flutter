class Fragment {
  String? id;
  String category;
  String title;
  String description;
  String? note;
  DateTime? date;

  Fragment({
    this.id,
    required this.category,
    required this.title,
    required this.description,
    this.note,
    this.date,
  });
}
