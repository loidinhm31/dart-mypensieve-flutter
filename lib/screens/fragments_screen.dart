import 'package:flutter/material.dart';
import 'package:my_pensieve/providers/auth.dart';
import 'package:my_pensieve/providers/fragments.dart';
import 'package:my_pensieve/services/sync_service.dart';
import 'package:my_pensieve/widgets/fragment_list.dart';
import 'package:provider/provider.dart';

class FragmentListScreenWidget extends StatelessWidget {
  const FragmentListScreenWidget({super.key});

  static const routeName = "/fragments";

  @override
  Widget build(BuildContext context) {
    final SyncService syncService = SyncService();

    final userId = Provider.of<Auth>(context).user.id;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () async {
            try {
              await syncService.syncDownload(userId!);
              await syncService.syncUpload(userId);
            } finally {
              await Provider.of<Fragments>(context, listen: false)
                  .fetchAndSetFragments();
            }
          },
          icon: const Icon(
            Icons.refresh,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              await syncService.initCloudObject(userId!);
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
