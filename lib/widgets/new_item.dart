import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NewItemWidget extends StatefulWidget {
  final Function addItem;

  const NewItemWidget({
    super.key,
    required this.addItem,
  });

  @override
  State<NewItemWidget> createState() => _NewItemWidgetState();
}

class _NewItemWidgetState extends State<NewItemWidget> {
  final _categoryController = TextEditingController();

  final _titleController = TextEditingController();

  final _valueController = TextEditingController();

  DateTime _selectedDate = DateTime.now();

  void _submitData() {
    final String enteredCategory = _categoryController.text;
    final String enteredTitle = _titleController.text;
    final String enteredValue = _valueController.text;

    if (enteredCategory.isEmpty ||
        enteredTitle.isEmpty ||
        enteredValue.isEmpty) {
      return;
    }
    widget.addItem(enteredCategory, enteredTitle, enteredValue, _selectedDate);
  }

  void _presentDatePicker(BuildContext context) {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
    ).then((pickedDate) {
      if (pickedDate == null) {
        return;
      }

      setState(() {
        _selectedDate = pickedDate;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      child: Container(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            TextField(
              decoration: const InputDecoration(
                labelText: 'Category',
              ),
              controller: _categoryController,
            ),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Title',
              ),
              controller: _titleController,
            ),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Value',
              ),
              controller: _valueController,
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(DateFormat.yMd().format(_selectedDate)),
                ),
                TextButton(
                  style: ButtonStyle(
                    foregroundColor: MaterialStateProperty.all<Color>(
                        Theme.of(context).colorScheme.secondary),
                  ),
                  child: const Text('Choose Date'),
                  onPressed: () => _presentDatePicker(context),
                ),
              ],
            ),
            ElevatedButton(
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all<Color>(
                    Theme.of(context).colorScheme.secondary),
                shape: MaterialStateProperty.all<OutlinedBorder>(
                  const StadiumBorder(),
                ),
              ),
              onPressed: _submitData,
              child: const Text(
                'Add Item',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
