import 'package:flutter/material.dart';
import 'package:my_pensieve/models/fragment.dart';
import 'package:my_pensieve/widgets/fragment_list.dart';

class FragmentListScreenWidget extends StatelessWidget {
  const FragmentListScreenWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FragmentListWidget(fragments: [
        Fragment(
          id: "1",
          category: 'category1',
          title: 'title1',
          value: 'value1',
          note: 'note test',
          date: DateTime.now(),
        ),
      ]),
    );
  }
}
