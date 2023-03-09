import 'package:flutter/material.dart';
import 'package:my_pensieve/models/hive/fragment.dart';
import 'package:my_pensieve/services/fragment_service.dart';
import 'package:my_pensieve/widgets/fragment_link_view_item.dart';

class ExpandedFragmentWidget extends StatelessWidget {
  const ExpandedFragmentWidget({
    super.key,
    required this.fragmentIds,
  });

  final List<String?> fragmentIds;

  Future<List<FragmentHive>> _fetchLinkedFragments() async {
    final FragmentService fragmentService = FragmentService();

    List<FragmentHive> linkedFragments =
        await fragmentService.getLinkedFragments(fragmentIds);

    return linkedFragments;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);

    return FutureBuilder(
      future: _fetchLinkedFragments(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (_, index) {
                return Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(10.0),
                    border: const Border.fromBorderSide(
                      BorderSide(width: 2.0),
                    ),
                  ),
                  child: LinkFragmentViewItemWidget(
                    theme: theme,
                    mediaQuery: mediaQuery,
                    fragment: snapshot.data![index],
                  ),
                );
              },
            );
          } else {
            return Center(
              child: Text(
                'Empty link',
                style: theme.textTheme.displayLarge,
              ),
            );
          }
        }
      },
    );
  }
}
