import 'package:my_pensieve/repositories/sqlite/base_repository.dart';

class LinkedFragmentRepository extends BaseRepository {

  @override
  String get table => "linked_fragments";

  @override
  Future<void> clear() async {
    await database!.linkedFragmentsDao.clearAll();
  }

  Future<List<String>> findLinkedFragmentsByFragmentId(String fragmentId) async {
    return (await database!.linkedFragmentsDao.findByFragmentId(fragmentId))
        .map((o) => o.linkedId).toList();
  }
}
