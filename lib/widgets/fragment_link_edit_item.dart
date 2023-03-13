import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_pensieve/models/fragment.dart';

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
  final Fragment fragment;
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
    final theme = Theme.of(context);
    return InkWell(
      key: ValueKey(widget.fragment.id),
      child: CheckboxListTile(
        tileColor: widget.theme.colorScheme.tertiary,
        title: Row(
          children: [
            Expanded(
              flex: 1,
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
                    child: Text(widget.fragment.categoryName!,
                        style: widget.theme.textTheme.labelLarge),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Container(
                alignment: Alignment.topLeft,
                padding: const EdgeInsets.all(5.0),
                child: Chip(
                  backgroundColor: theme.colorScheme.secondary,
                  padding: const EdgeInsets.all(5.0),
                  label: Text(
                    widget.fragment.title!,
                    style: widget.theme.textTheme.displayLarge,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Text(
                DateFormat.yMMMd().format(widget.fragment.date!),
                style: widget.theme.textTheme.displaySmall,
              ),
            ),
          ],
        ),
        subtitle: RichText(
          text: TextSpan(
            text: widget.fragment.description!,
            style: widget.theme.textTheme.displaySmall,
          ),
        ),
        value: _isSelected,
        onChanged: (bool? newValue) {
          _handleSelectCheckbox(newValue!);
        },
      ),
    );
  }
}
