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
        tileColor: theme.colorScheme.tertiary,
        title: Row(
          children: [
            Expanded(
              child: Container(
                height: mediaQuery.size.height * 0.05,
                width: mediaQuery.size.width * 0.05,
                decoration: BoxDecoration(
                  color: theme.colorScheme.background,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: FittedBox(
                    child: Text(fragment.categoryId!,
                        style: theme.textTheme.labelLarge),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Row(
                  children: [
                    const Icon(
                      Icons.title,
                      color: Colors.white,
                    ),
                    const SizedBox(
                      width: 5.0,
                    ),
                    Text(
                      fragment.title!,
                      style: theme.textTheme.displayLarge,
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Row(
                  children: [
                    const Icon(
                      Icons.date_range,
                      color: Colors.white,
                    ),
                    const SizedBox(
                      width: 5.0,
                    ),
                    Text(
                      DateFormat.yMMMd().format(fragment.date!),
                      style: theme.textTheme.displayLarge,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Row(
                children: [
                  const Icon(
                    Icons.description,
                    color: Colors.white,
                  ),
                  const SizedBox(
                    width: 5.0,
                  ),
                  Text(
                    fragment.description!,
                    style: theme.textTheme.displayLarge,
                  ),
                ],
              ),
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }
}
