import 'dart:developer';

import 'package:my_pensieve/models/hive/local_sync.dart';
import 'package:my_pensieve/repositories/hive/local_sync_repository.dart';

class LocalSyncService {
  late final LocalSyncHiveRepository _localSyncHiveRepository;

  LocalSyncService() {
    _localSyncHiveRepository = LocalSyncHiveRepository();
  }

  Future<LocalSyncHive> getData(String object) async {
    await _localSyncHiveRepository.open(_localSyncHiveRepository.boxName);
    LocalSyncHive localSyncHive;
    try {
      localSyncHive = _localSyncHiveRepository.findByObject(object);
    } catch (error, stack) {
      log('Error: $error');
      log('StackTrace: $stack');
      rethrow;
    } finally {
      await _localSyncHiveRepository.close();
    }
    return localSyncHive;
  }

  Future<void> addData(String object, Map<String, dynamic> syncData) async {
    await _localSyncHiveRepository.open(_localSyncHiveRepository.boxName);
    try {
      await _localSyncHiveRepository.addData(object, syncData);
    } catch (error, stack) {
      log('Error: $error');
      log('StackTrace: $stack');
      rethrow;
    } finally {
      await _localSyncHiveRepository.close();
    }
  }

  Future<void> updateLocalSync(LocalSyncHive editLocalSync) async {
    await _localSyncHiveRepository.open(_localSyncHiveRepository.boxName);

    LocalSyncHive? localSyncHive =
        _localSyncHiveRepository.findByObject(editLocalSync.object!);
    try {
      localSyncHive.added = editLocalSync.added;
      localSyncHive.updated = editLocalSync.updated;
      localSyncHive.deleted = editLocalSync.deleted;

      localSyncHive.save();
    } catch (error, stack) {
      log('Error: $error');
      log('StackTrace: $stack');
      rethrow;
    } finally {
      await _localSyncHiveRepository.close();
    }
  }
}
