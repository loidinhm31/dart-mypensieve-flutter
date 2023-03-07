abstract class SyncHiveRepository<T> {
  T creator();

  List<T> findAllByKeys(List<String?> keys);

  T? findByKey(String key);

  Future<void> addAll(List<T> hiveObjects);

  Future<void> deleteAll(List<String> keys);

  void save(T hiveObject);
}
