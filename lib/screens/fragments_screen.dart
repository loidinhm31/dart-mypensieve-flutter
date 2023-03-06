import 'package:flutter/material.dart';
import 'package:my_pensieve/providers/fragments.dart';
import 'package:my_pensieve/service/sync_service.dart';
import 'package:my_pensieve/widgets/fragment_list.dart';
import 'package:provider/provider.dart';

class FragmentListScreenWidget extends StatelessWidget {
  const FragmentListScreenWidget({super.key});

  static const routeName = "/fragments";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () async {
            try {
              SyncService syncService = SyncService();
              await syncService.syncDownload();
              await syncService.syncUpload();
            } finally {
              await Provider.of<Fragments>(context, listen: false)
                  .fetchAndSetFragments();
            }
          },
          icon: const Icon(
            Icons.refresh,
          ),
        ),
      ),
      body: const FragmentListWidget(),
    );
  }
}
