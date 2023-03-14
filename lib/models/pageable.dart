class Pageable {
  int pageNumber;
  int pageSize;

  Pageable({
    required this.pageNumber,
    this.pageSize = 5,
  });
}
