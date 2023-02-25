import 'package:flutter/material.dart';
import 'package:my_pensieve/models/fragment.dart';
import 'package:my_pensieve/widgets/fragment_item.dart';

class FragmentListWidget extends StatelessWidget {
  final List<Fragment> _fragments;

  const FragmentListWidget({
    super.key,
    required List<Fragment> fragments,
  }) : _fragments = fragments;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
      height: mediaQuery.size.height * 0.6,
      child: _fragments.isEmpty
          ? Center(
              child: Text(
                'No items added yet!',
                style: theme.textTheme.displayLarge,
              ),
            )
          : ListView.builder(
              itemBuilder: (ctx, index) {
                return FragmentItemWidget(
                  key: ValueKey(_fragments[index].id),
                  fragment: _fragments[index],
                );
              },
              itemCount: _fragments.length,
            ),
    );
  }
}
