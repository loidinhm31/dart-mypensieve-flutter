import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_pensieve/providers/fragments.dart';
import 'package:my_pensieve/widgets/fragment_expanded.dart';
import 'package:provider/provider.dart';

class ViewFragmentWidget extends StatefulWidget {
  const ViewFragmentWidget({
    super.key,
    required this.fragmentId,
  });
  final String fragmentId;

  @override
  State<ViewFragmentWidget> createState() => _ViewFragmentWidgetState();
}

class _ViewFragmentWidgetState extends State<ViewFragmentWidget> {
  var _expanded = false;

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
        Provider.of<Fragments>(context).findById(widget.fragmentId);

    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(15),
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
                    loadedFragment.category!,
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
                loadedFragment.title!,
                style: theme.textTheme.displayLarge,
              ),
            ),
            _buildFragmentItem(
              theme,
              mediaQuery,
              const Icon(
                Icons.description,
                color: Colors.white,
              ),
              Text(
                loadedFragment.description!,
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
            IconButton(
              icon: Icon(
                _expanded ? Icons.expand_more : Icons.chevron_right,
                color: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  _expanded = !_expanded;
                });
              },
            ),
            if (_expanded)
              Container(
                padding: const EdgeInsets.all(10.0),
                height: mediaQuery.size.height * 0.5,
                child: ExpandedFragmentWidget(
                  fragmentIds: loadedFragment.linkedItems!,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
