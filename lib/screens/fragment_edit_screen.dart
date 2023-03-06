import 'package:flutter/material.dart';
import 'package:my_pensieve/controller/controller.dart';
import 'package:my_pensieve/providers/linked_fragments.dart';
import 'package:my_pensieve/screens/tabs_screen.dart';
import 'package:my_pensieve/widgets/fragment_edit.dart';
import 'package:provider/provider.dart';

class EditFragmentScreenWidget extends StatelessWidget {
  EditFragmentScreenWidget({super.key});

  static const routeName = '/fragment-new';

  final CustomController customController = CustomController();

  void _handleCancelButton(BuildContext context) {
    // Clear selected linked fragments before leaving
    Provider.of<LinkedFragments>(context, listen: false)
        .clearSelectedLinkedItem();

    final routeArg = ModalRoute.of(context)?.settings.arguments;
    if (routeArg != null) {
      Navigator.of(context).pop(false);
    } else {
      Navigator.of(context).pushReplacementNamed(TabScreenWidget.routeName);
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
        leading: IconButton(
          onPressed: () => _handleCancelButton(context),
          icon: const Icon(
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
