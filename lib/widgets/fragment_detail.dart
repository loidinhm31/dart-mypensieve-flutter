import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_pensieve/providers/fragments.dart';
import 'package:provider/provider.dart';

class ViewFragmentWidget extends StatelessWidget {
  const ViewFragmentWidget({
    super.key,
    required this.fragmentId,
  });

  final String fragmentId;

  Widget _buildFragmentItem(theme, mediaQuery, Icon icon, Text text) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 25, 10, 10),
      child: Row(
        children: <Widget>[
          icon,
          SizedBox(
            width: mediaQuery.size.width * 0.1,
          ),
          text,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);

    final loadedFragment =
        Provider.of<Fragments>(context, listen: false).findById(fragmentId);

    // final loadedFragment = context.watch<Fragments>().findById(fragmentId);

    return Container(
      height: mediaQuery.size.height * 0.6,
      padding: const EdgeInsets.all(15),
      decoration: const BoxDecoration(
        shape: BoxShape.rectangle,
        border: BorderDirectional(
          bottom: BorderSide(width: 2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(5),
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
                child: Text(
                  loadedFragment.category,
                  style: theme.textTheme.labelLarge,
                ),
              ),
            ),
          ),
          _buildFragmentItem(
            theme,
            mediaQuery,
            const Icon(
              Icons.title,
              color: Colors.white,
            ),
            Text(
              loadedFragment.title,
              style: theme.textTheme.displayLarge,
            ),
          ),
          _buildFragmentItem(
            theme,
            mediaQuery,
            const Icon(
              Icons.info,
              color: Colors.white,
            ),
            Text(
              loadedFragment.value,
              style: theme.textTheme.displayLarge,
            ),
          ),
          if (loadedFragment.note != null)
            _buildFragmentItem(
              theme,
              mediaQuery,
              const Icon(
                Icons.notes,
                color: Colors.white,
              ),
              Text(
                loadedFragment.note!,
                style: theme.textTheme.displayLarge,
              ),
            ),
          _buildFragmentItem(
            theme,
            mediaQuery,
            const Icon(
              Icons.date_range,
              color: Colors.white,
            ),
            Text(
              DateFormat("EEEE, yyyy/MM/dd").format(loadedFragment.date!),
              style: theme.textTheme.displayLarge,
            ),
          ),
        ],
      ),
    );
  }
}
