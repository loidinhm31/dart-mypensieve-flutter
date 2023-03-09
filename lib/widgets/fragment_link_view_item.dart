import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_pensieve/models/hive/fragment.dart';
import 'package:my_pensieve/screens/fragment_detail_screen.dart';

class LinkFragmentViewItemWidget extends StatelessWidget {
  const LinkFragmentViewItemWidget({
    super.key,
    required this.theme,
    required this.mediaQuery,
    required this.fragment,
  });
  final ThemeData theme;
  final MediaQueryData mediaQuery;
  final FragmentHive fragment;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: ValueKey(fragment.id),
      child: ListTile(
        onLongPress: () {
          Navigator.of(context).pushReplacementNamed(
              DetailFragmentScreenWidget.routeName,
              arguments: fragment.id);
        },
        leading: Chip(
          label:
              Text(fragment.categoryName!, style: theme.textTheme.labelMedium),
        ),
        tileColor: theme.colorScheme.tertiary,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Container(
                alignment: Alignment.topLeft,
                padding: const EdgeInsets.all(5.0),
                child: Chip(
                  backgroundColor: theme.colorScheme.secondary,
                  padding: const EdgeInsets.all(5.0),
                  label: Text(
                    fragment.title!,
                    style: theme.textTheme.titleSmall,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Text(
                DateFormat.yMMMd().format(fragment.date!),
                style: theme.textTheme.displaySmall,
              ),
            ),
          ],
        ),
        subtitle: RichText(
          text: TextSpan(
            text: fragment.description!,
            style: theme.textTheme.displaySmall,
          ),
        ),
      ),
    );
  }
}
