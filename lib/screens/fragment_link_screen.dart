import 'package:flutter/material.dart';
import 'package:my_pensieve/models/fragment.dart';
import 'package:my_pensieve/providers/fragments.dart';
import 'package:my_pensieve/providers/linked_fragments.dart';
import 'package:my_pensieve/widgets/fragment_link_edit_item.dart';
import 'package:provider/provider.dart';

class LinkFragmentsScreenWidget extends StatefulWidget {
  const LinkFragmentsScreenWidget({super.key});

  static const routeName = '/fragment-link';

  @override
  State<LinkFragmentsScreenWidget> createState() =>
      _LinkFragmentsScreenWidgetState();
}

class _LinkFragmentsScreenWidgetState extends State<LinkFragmentsScreenWidget> {
  late List<Fragment> _fragments;

  final List<Fragment> _tempLinkedFragments = [];

  void addLinkedItem(Fragment fragment) {
    _tempLinkedFragments.add(fragment);
  }

  void removeLinkedItem(Fragment fragment) {
    _tempLinkedFragments.removeWhere((element) => element.id == fragment.id);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);

    _fragments = Provider.of<Fragments>(context, listen: false).items;

    final routeArg = ModalRoute.of(context)?.settings.arguments;
    final fragmentId = routeArg != null ? routeArg as String : '';

    if (fragmentId.isNotEmpty) {
      // Remove the current fragment to avoid circular referencing
      _fragments.removeWhere((element) => element.id == fragmentId);
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop(false);
          },
        ),
        actions: [
          TextButton(
            style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all(Colors.white)),
            onPressed: () {
              Provider.of<LinkedFragments>(context, listen: false)
                  .changeLinkedItems(_tempLinkedFragments);

              Navigator.of(context).pop(true);
            },
            child: const Text('Done'),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _fragments.length,
        itemBuilder: (_, index) {
          return LinkFragmentEditItemWidget(
            theme: theme,
            mediaQuery: mediaQuery,
            fragment: _fragments[index],
            checked: Provider.of<LinkedFragments>(context)
                .linkedItems
                .contains(_fragments[index]),
            addLinkedItem: addLinkedItem,
            removeLinkedItem: removeLinkedItem,
          );
        },
      ),
    );
  }
}
