import 'package:flutter/material.dart';
import 'package:my_pensieve/models/hive/fragment.dart';
import 'package:my_pensieve/providers/fragments.dart';
import 'package:my_pensieve/screens/fragment_edit_screen.dart';
import 'package:my_pensieve/widgets/fragment_detail.dart';
import 'package:provider/provider.dart';

class DetailFragmentScreenWidget extends StatefulWidget {
  const DetailFragmentScreenWidget({super.key});

  static const routeName = "/fragment-detail";

  @override
  State<DetailFragmentScreenWidget> createState() =>
      _DetailFragmentScreenWidgetState();
}

class _DetailFragmentScreenWidgetState
    extends State<DetailFragmentScreenWidget> {
  late FragmentHive _loadedFragment;

  void _handleCancelButton(BuildContext context) {
    Navigator.of(context).pop();
  }

  void _handleEditButton(BuildContext context) {
    Navigator.of(context)
        .pushNamed(
      EditFragmentScreenWidget.routeName,
      arguments: ModalRoute.of(context)!.settings.arguments as String,
    )
        .then((value) {
      if (value == true) {
        setState(() {
          _loadedFragment = Provider.of<Fragments>(context, listen: false)
              .findById(_loadedFragment.id!);
        });
      }
    });
  }

  void _handleDeleteButton(BuildContext context, String fragmentId) async {
    Provider.of<Fragments>(context, listen: false).removeItem(fragmentId);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final fragmentId = ModalRoute.of(context)!.settings.arguments as String;
    _loadedFragment =
        Provider.of<Fragments>(context, listen: false).findById(fragmentId);

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
          TextButton(
            onPressed: () => _handleDeleteButton(context, fragmentId),
            child: const Icon(Icons.delete),
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
        fragment: _loadedFragment,
      ),
    );
  }
}
