import 'package:flutter/material.dart';
import 'package:my_pensieve/screens/fragment_edit_screen.dart';
import 'package:my_pensieve/widgets/fragment_detail.dart';

class DetailFragmentScreenWidget extends StatelessWidget {
  const DetailFragmentScreenWidget({super.key});

  static const routeName = "/fragment-detail";

  void _handleCancelButton(BuildContext context) {
    Navigator.of(context).pop();
  }

  void _handleEditButton(BuildContext context) {
    Navigator.of(context).pushNamed(
      EditFragmentScreenWidget.routeName,
      arguments: ModalRoute.of(context)!.settings.arguments as String,
    );
  }

  @override
  Widget build(BuildContext context) {
    final fragmentId = ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: TextButton(
          onPressed: () => _handleCancelButton(context),
          child: const Icon(
            Icons.cancel,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => _handleEditButton(context),
            child: const Icon(Icons.edit),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2.0),
          child: Container(
            color: Colors.blueGrey,
            height: 1.0,
          ),
        ),
      ),
      body: ViewFragmentWidget(
        fragmentId: fragmentId,
      ),
    );
  }
}
