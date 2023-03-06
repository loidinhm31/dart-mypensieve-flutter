class LocalSync {
  static const String DEVICE = 'device';
  static const String OBJECT = 'object';
  static const String ADDED = 'added';
  static const String UPDATED = 'updated';
  static const String DELETED = 'deleted';

  String? device;
  String? object;
  List<String>? added;
  List<String>? updated;
  List<String>? deleted;
}
