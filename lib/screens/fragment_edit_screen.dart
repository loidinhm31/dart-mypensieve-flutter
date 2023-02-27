import 'package:flutter/material.dart';
import 'package:my_pensieve/controller/controller.dart';
import 'package:my_pensieve/widgets/fragment_edit.dart';

class EditFragmentScreenWidget extends StatelessWidget {
  EditFragmentScreenWidget({super.key});

  static const routeName = '/fragment-new';

  final CustomController customController = CustomController();

  void _handleCancelButton(BuildContext context) {
    final routeArg = ModalRoute.of(context)?.settings.arguments;
    if (routeArg != null) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushReplacementNamed('/');
    }
  }

  void _handleSaveFragment() {
    customController.handleController();
  }

  @override
  Widget build(BuildContext context) {
    final routeArg = ModalRoute.of(context)?.settings.arguments;
    final fragmentId = routeArg != null ? routeArg as String : '';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: TextButton(
          onPressed: () => _handleCancelButton(context),
          child: const Icon(
            Icons.cancel,
          ),
        ),
        title: Text(fragmentId.isEmpty ? 'Add Fragment' : 'Edit Fragment'),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () => _handleSaveFragment(),
            child: const Text('Save'),
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
      body: EditFragmentWidget(
        fragmentId: fragmentId,
        customController: customController,
      ),
    );
  }
}
