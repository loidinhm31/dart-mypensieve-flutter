import 'package:flutter/material.dart';
import 'package:my_pensieve/providers/fragments.dart';
import 'package:my_pensieve/widgets/fragment_detail.dart';
import 'package:provider/provider.dart';

class DetailFragmentScreenWidget extends StatelessWidget {
  const DetailFragmentScreenWidget({super.key});

  static const routeName = "/fragment-detail";

  @override
  Widget build(BuildContext context) {
    final fragmentId = ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      body: ViewFragmentWidget(
        fragmentId: fragmentId,
      ),
    );
  }
}
