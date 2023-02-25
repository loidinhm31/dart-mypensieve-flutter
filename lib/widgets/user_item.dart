import 'package:flutter/material.dart';
import 'package:my_pensieve/models/item.dart';
import 'package:my_pensieve/widgets/item_list.dart';
import 'package:my_pensieve/widgets/new_item.dart';

class UserItemsWidget extends StatefulWidget {
  const UserItemsWidget({super.key});

  @override
  State<StatefulWidget> createState() => _UserItemsWidgetState();
}

class _UserItemsWidgetState extends State<UserItemsWidget> {
  final List<Item> _userItems = [
    // Item(id: 't1', title: 'T1', category: 'C1', date: DateTime.now()),
    // Item(id: 't2', title: 'T2', category: 'C2', date: DateTime.now()),
    // Item(id: 't2', title: 'T2', category: 'C2', date: DateTime.now()),
    // Item(id: 't2', title: 'T2', category: 'C2', date: DateTime.now()),
    // Item(id: 't2', title: 'T2', category: 'C2', date: DateTime.now()),
    // Item(id: 't2', title: 'T2', category: 'C2', date: DateTime.now()),
  ];

  void _addNewItem(
      String iCategory, String iTitle, String iValue, DateTime iDate) {
    final newItem = Item(
      category: iCategory,
      title: iTitle,
      value: iValue,
      date: iDate,
    );

    setState(() {
      _userItems.add(newItem);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        NewItemWidget(
          addItem: _addNewItem,
        ),
        ItemListWidget(
          items: _userItems,
        ),
      ],
    );
  }
}
