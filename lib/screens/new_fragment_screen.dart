import 'package:flutter/material.dart';
import 'package:my_pensieve/widgets/new_fragment.dart';

class NewFragmentScreenWidget extends StatelessWidget {
  const NewFragmentScreenWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NewFragmentWidget(addFragment: () {}),
    );
  }
}
