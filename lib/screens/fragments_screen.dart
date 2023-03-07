import 'package:flutter/material.dart';
import 'package:my_pensieve/models/category.dart';
import 'package:my_pensieve/models/device_sync.dart';
import 'package:my_pensieve/models/fragment.dart';
import 'package:my_pensieve/providers/auth.dart';
import 'package:my_pensieve/providers/fragments.dart';
import 'package:my_pensieve/repositories/hive/category_repository.dart';
import 'package:my_pensieve/repositories/hive/fragment_repository.dart';
import 'package:my_pensieve/services/sync_service.dart';
import 'package:my_pensieve/widgets/fragment_list.dart';
import 'package:provider/provider.dart';

class FragmentListScreenWidget extends StatelessWidget {
  const FragmentListScreenWidget({super.key});

  static const routeName = "/fragments";

  Future<void> _handleSync(String userId) async {
    final SyncService syncFragmentService = SyncService<FragmentHiveRepository>(
      Fragment.collection,
      () => FragmentHiveRepository(),
    );
    await syncFragmentService.syncDownload(userId);
    await syncFragmentService.syncUpload(userId);

    final SyncService syncCategoryService = SyncService<CategoryHiveRepository>(
      Category.collection,
      () => CategoryHiveRepository(),
    );
    await syncCategoryService.syncDownload(userId);
    await syncCategoryService.syncUpload(userId);
  }

  @override
  Widget build(BuildContext context) {
    final userId = Provider.of<Auth>(context).user.id;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () async {
            await _handleSync(userId!).then((_) =>
                Provider.of<Fragments>(context, listen: false)
                    .fetchAndSetFragments());
          },
          icon: const Icon(
            Icons.refresh,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              final SyncService syncFragmentService = SyncService();
              await syncFragmentService.initCloudObjects(
                  userId!, [Fragment.collection, Category.collection]);
            },
            icon: const Icon(
              Icons.cloud_sync,
            ),
          ),
        ],
      ),
      body: const FragmentListWidget(),
    );
  }
}
