import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_pensieve/models/hive/fragment.dart';
import 'package:my_pensieve/widgets/fragment_expanded.dart';

class ViewFragmentWidget extends StatefulWidget {
  const ViewFragmentWidget({
    super.key,
    required this.fragment,
  });
  final FragmentHive fragment;

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
                    widget.fragment.category!,
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
                widget.fragment.title!,
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
                widget.fragment.description!,
                style: theme.textTheme.displayLarge,
              ),
            ),
            if (widget.fragment.note != null)
              _buildFragmentItem(
                theme,
                mediaQuery,
                const Icon(
                  Icons.notes,
                  color: Colors.white,
                ),
                Text(
                  widget.fragment.note!,
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
                DateFormat("EEEE, yyyy/MM/dd").format(widget.fragment.date!),
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
                  fragmentIds: widget.fragment.linkedItems!,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
