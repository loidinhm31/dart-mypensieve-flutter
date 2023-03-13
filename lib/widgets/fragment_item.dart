import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_pensieve/models/fragment.dart';
import 'package:my_pensieve/screens/fragment_detail_screen.dart';

class FragmentItemWidget extends StatelessWidget {
  const FragmentItemWidget({
    required Key key,
    required this.fragment,
  }) : super(key: key);

  final Fragment fragment;

  void _selectFragment(BuildContext context) {
    Navigator.of(context).pushNamed(DetailFragmentScreenWidget.routeName,
        arguments: fragment.id);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);

    return InkWell(
      onTap: () => _selectFragment(context),
      splashColor: theme.colorScheme.secondary,
      child: ListTile(
        contentPadding: const EdgeInsets.all(5.0),
        tileColor: theme.colorScheme.tertiary,
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: theme.colorScheme.background,
            width: 0.5,
          ),
        ),
        leading: Container(
          height: mediaQuery.size.height * 0.065,
          width: mediaQuery.size.width * 0.3,
          decoration: BoxDecoration(
            color: theme.colorScheme.background,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: FittedBox(
              child: Text(fragment.categoryName ?? '',
                  style: theme.textTheme.labelLarge),
            ),
          ),
        ),
        title: Container(
          alignment: Alignment.topLeft,
          child: Chip(
            backgroundColor: theme.colorScheme.secondary,
            padding: const EdgeInsets.all(5.0),
            label: Text(
              fragment.title!,
              style: theme.textTheme.titleLarge,
            ),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              DateFormat.yMMMd().format(fragment.date!),
              style: theme.textTheme.displaySmall,
            ),
            Center(
              child: Text(
                fragment.description!,
                style: theme.textTheme.displaySmall,
              ),
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }
}
