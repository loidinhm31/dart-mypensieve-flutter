import 'package:flutter/material.dart';
import 'package:my_pensieve/models/fragment.dart';
import 'package:my_pensieve/widgets/fragment_list.dart';
import 'package:my_pensieve/widgets/new_fragment.dart';

class UserFragmentsWidget extends StatefulWidget {
  const UserFragmentsWidget({super.key});

  @override
  State<StatefulWidget> createState() => _UserFragmentsWidgetState();
}

class _UserFragmentsWidgetState extends State<UserFragmentsWidget> {
  final List<Fragment> _userFragments = [];

  void _addNewFragment(
      String fCategory, String fTitle, String fValue, DateTime fDate) {
    final newFragment = Fragment(
      id: (_userFragments.length + 1).toString(), // TODO remove
      category: fCategory,
      title: fTitle,
      value: fValue,
      date: fDate,
    );

    setState(() {
      _userFragments.add(newFragment);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        NewFragmentWidget(
          addFragment: _addNewFragment,
        ),
        FragmentListWidget(
          fragments: _userFragments,
        ),
      ],
    );
  }
}
