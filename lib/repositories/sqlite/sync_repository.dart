import 'package:my_pensieve/repositories/sqlite/base_repository.dart';

abstract class SyncRepository<T> extends BaseRepository {
  T creator();

  Future<List<T>> syncFindAllByIds(List<String?> ids);

  Future<T?> findById(String id);

  Future<String> save(T object);

  Future<void> syncSaveAll(List<T> objects);

  Future<void> syncUpdateAll(List<T> objects);

  Future<void> syncDeleteAll(List<String> ids);
}
