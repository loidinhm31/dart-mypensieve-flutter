import 'package:flutter/material.dart';
import 'package:my_pensieve/providers/fragments.dart';
import 'package:my_pensieve/widgets/fragment_item.dart';
import 'package:provider/provider.dart';

class FragmentListWidget extends StatefulWidget {
  const FragmentListWidget({
    super.key,
  });

  @override
  State<FragmentListWidget> createState() => _FragmentListWidgetState();
}

class _FragmentListWidgetState extends State<FragmentListWidget> {
  Future<void> _refreshFragments(BuildContext context) async {
    await Provider.of<Fragments>(context, listen: false).fetchAndSetFragments();
  }

  @override
  void initState() {
    _refreshFragments(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);

    final fragmentsData = Provider.of<Fragments>(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
      height: mediaQuery.size.height,
      child: RefreshIndicator(
        onRefresh: () => _refreshFragments(context),
        child: ListView.builder(
          itemCount: fragmentsData.items.length,
          physics: const AlwaysScrollableScrollPhysics(),
          itemBuilder: (_, index) => FragmentItemWidget(
            key: ValueKey(fragmentsData.items[index].id),
            fragment: fragmentsData.items[index],
          ),
        ),
      ),
    );
  }
}
