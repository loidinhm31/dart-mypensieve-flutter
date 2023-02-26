import 'package:flutter/material.dart';
import 'package:my_pensieve/widgets/fragment_new.dart';

class NewFragmentScreenWidget extends StatelessWidget {
  const NewFragmentScreenWidget({super.key});

  static const routeName = '/fragment-new';

  void _handleCancelButton(BuildContext context) {
    Navigator.of(context).pushReplacementNamed('/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: TextButton(
          onPressed: () => _handleCancelButton(context),
          child: const Icon(
            Icons.cancel,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2.0),
          child: Container(
            color: Colors.blueGrey,
            height: 1.0,
          ),
        ),
      ),
      body: NewFragmentWidget(addFragment: () {}),
    );
  }
}
