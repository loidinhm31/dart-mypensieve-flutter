import 'package:flutter/material.dart';
import 'package:my_pensieve/models/category.dart';
import 'package:my_pensieve/models/fragment.dart';
import 'package:my_pensieve/providers/auth.dart';
import 'package:my_pensieve/providers/fragments.dart';
import 'package:my_pensieve/repositories/hive/category_repository.dart';
import 'package:my_pensieve/repositories/hive/fragment_repository.dart';
import 'package:my_pensieve/services/sync_service.dart';
import 'package:my_pensieve/widgets/fragment_list.dart';
import 'package:provider/provider.dart';

class FragmentListScreenWidget extends StatefulWidget {
  const FragmentListScreenWidget({super.key});

  static const routeName = "/fragments";

  @override
  State<FragmentListScreenWidget> createState() =>
      _FragmentListScreenWidgetState();
}

class _FragmentListScreenWidgetState extends State<FragmentListScreenWidget> {
  String? _syncStatus;

  Future<void> _handleSync(String userId) async {
    try {
      setState(() {
        _syncStatus = 'Syncing data...';
      });
      final SyncService syncFragmentService =
          SyncService<FragmentHiveRepository>(
        Fragment.collection,
        () => FragmentHiveRepository(),
      );
      await syncFragmentService.syncDownload(userId);
      await syncFragmentService.syncUpload(userId);

      final SyncService syncCategoryService =
          SyncService<CategoryHiveRepository>(
        Category.collection,
        () => CategoryHiveRepository(),
      );
      await syncCategoryService.syncDownload(userId);
      await syncCategoryService.syncUpload(userId);
    } catch (error) {
      setState(() {
        _syncStatus = '$error';
      });
    } finally {
      setState(() {
        _syncStatus = 'Synchronization is complete';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userId = Provider.of<Auth>(context).user.id;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            _handleSync(userId!).then((value) {
              Provider.of<Fragments>(context, listen: false)
                  .fetchAndSetFragments();
              Future.delayed(const Duration(milliseconds: 3000), () {
                setState(() {
                  _syncStatus = '';
                });
              });
            });
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
      body: SizedBox(
        child: Column(
          children: <Widget>[
            _syncStatus != null && _syncStatus!.isNotEmpty
                ? Container(
                    padding: const EdgeInsets.all(5.0),
                    alignment: Alignment.center,
                    child: Text(
                      _syncStatus!,
                      style: theme.textTheme.displayLarge,
                    ),
                  )
                : Container(),
            const Expanded(
              child: FragmentListWidget(),
            ),
          ],
        ),
      ),
    );
  }
}
