import 'package:flutter/material.dart';
import 'package:my_pensieve/providers/fragments.dart';
import 'package:my_pensieve/widgets/fragment_item.dart';
import 'package:provider/provider.dart';

class FragmentListWidget extends StatelessWidget {
  const FragmentListWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);

    final fragmentsData = context.watch<Fragments>();
    final fragments = fragmentsData.items;

    return Container(
      padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
      height: mediaQuery.size.height * 0.6,
      child: fragments.isEmpty
          ? Center(
              child: Text(
                'No items added yet!',
                style: theme.textTheme.displayLarge,
              ),
            )
          : ListView.builder(
              itemBuilder: (ctx, index) {
                return FragmentItemWidget(
                  key: ValueKey(fragments[index].id),
                  fragment: fragments[index],
                );
              },
              itemCount: fragments.length,
            ),
    );
  }
}
