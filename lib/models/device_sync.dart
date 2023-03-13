class LocalSync {
  static const String collection = 'device_syncs'; // for cloud use

  static const String fDevice = 'device';
  static const String fObject = 'object';
  static const String fAdded = 'added';
  static const String fUpdated = 'updated';
  static const String fDeleted = 'deleted';

  String? device;
  String? object;
  List<String>? added;
  List<String>? updated;
  List<String>? deleted;
}
