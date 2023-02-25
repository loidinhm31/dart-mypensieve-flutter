import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_pensieve/models/fragment.dart';

class FragmentItemWidget extends StatelessWidget {
  const FragmentItemWidget({
    required Key key,
    required this.fragment,
  }) : super(key: key);

  final Fragment fragment;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 5,
      margin: const EdgeInsets.symmetric(
        vertical: 8,
        horizontal: 5,
      ),
      child: ListTile(
        leading: Container(
          height: 60,
          width: 150,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: FittedBox(
              child: Text(fragment.category, style: theme.textTheme.labelLarge),
            ),
          ),
        ),
        title: Text(
          fragment.title,
          style: theme.textTheme.displayLarge,
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
                fragment.value,
                style: theme.textTheme.displayMedium,
              ),
            ),
          ],
        ),
        isThreeLine: true,
        trailing: IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () {},
        ),
      ),
    );
  }
}
