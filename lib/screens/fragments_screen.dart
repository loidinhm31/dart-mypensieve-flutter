import 'package:flutter/material.dart';
import 'package:my_pensieve/widgets/fragment_list.dart';

class FragmentListScreenWidget extends StatelessWidget {
  const FragmentListScreenWidget({super.key});

  static const routeName = "/fragments";

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: FragmentListWidget(),
    );
  }
}
