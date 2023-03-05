import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_pensieve/models/hive/fragment.dart';

class LinkFragmentEditItemWidget extends StatefulWidget {
  const LinkFragmentEditItemWidget({
    super.key,
    required this.theme,
    required this.mediaQuery,
    required this.fragment,
    required this.checked,
    required this.addLinkedItem,
    required this.removeLinkedItem,
  });
  final ThemeData theme;
  final MediaQueryData mediaQuery;
  final FragmentHive fragment;
  final bool checked;
  final Function addLinkedItem;
  final Function removeLinkedItem;

  @override
  State<LinkFragmentEditItemWidget> createState() =>
      _LinkFragmentEditItemWidgetState();
}

class _LinkFragmentEditItemWidgetState
    extends State<LinkFragmentEditItemWidget> {
  late bool _isSelected;

  @override
  void initState() {
    _isSelected = widget.checked;

    if (_isSelected) {
      widget.addLinkedItem(widget.fragment);
    }

    super.initState();
  }

  void _handleSelectCheckbox(bool newValue) {
    if (newValue) {
      widget.addLinkedItem(widget.fragment);
    } else {
      widget.removeLinkedItem(widget.fragment);
    }

    setState(() {
      _isSelected = newValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: ValueKey(widget.fragment.id),
      child: CheckboxListTile(
        tileColor: widget.theme.colorScheme.tertiary,
        title: Row(
          children: [
            Expanded(
              child: Container(
                height: widget.mediaQuery.size.height * 0.05,
                width: widget.mediaQuery.size.width * 0.05,
                decoration: BoxDecoration(
                  color: widget.theme.colorScheme.background,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: FittedBox(
                    child: Text(widget.fragment.category!,
                        style: widget.theme.textTheme.labelLarge),
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
                      widget.fragment.title!,
                      style: widget.theme.textTheme.displayLarge,
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
                      DateFormat.yMMMd().format(widget.fragment.date!),
                      style: widget.theme.textTheme.displayLarge,
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
                    widget.fragment.description!,
                    style: widget.theme.textTheme.displayLarge,
                  ),
                ],
              ),
            ),
          ],
        ),
        isThreeLine: true,
        value: _isSelected,
        onChanged: (bool? newValue) {
          _handleSelectCheckbox(newValue!);
        },
      ),
    );
  }
}
