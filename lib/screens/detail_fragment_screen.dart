import 'package:flutter/material.dart';
import 'package:my_pensieve/models/fragment.dart';
import 'package:my_pensieve/widgets/detail_fragment.dart';

class DetailFragmentScreenWidget extends StatelessWidget {
  const DetailFragmentScreenWidget({super.key});

  static const routeName = "/fragment-detail";

  @override
  Widget build(BuildContext context) {
    final routeArgs = ModalRoute.of(context)!.settings.arguments as Fragment;

    return Scaffold(
      body: ViewFragmentWidget(
        fragment: routeArgs,
      ),
    );
  }
}
