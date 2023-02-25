import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NewFragmentWidget extends StatefulWidget {
  final Function addFragment;

  const NewFragmentWidget({
    super.key,
    required this.addFragment,
  });

  @override
  State<NewFragmentWidget> createState() => _NewFragmentWidgetState();
}

class _NewFragmentWidgetState extends State<NewFragmentWidget> {
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
    widget.addFragment(
        enteredCategory, enteredTitle, enteredValue, _selectedDate);
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
    final theme = Theme.of(context);

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
                  child: Text(
                      DateFormat("EEEE, yyyy/MM/dd").format(_selectedDate)),
                ),
                TextButton(
                  style: ButtonStyle(
                    foregroundColor: MaterialStateProperty.all<Color>(
                        theme.colorScheme.secondary),
                  ),
                  child: const Text('Choose Date'),
                  onPressed: () => _presentDatePicker(context),
                ),
              ],
            ),
            ElevatedButton(
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all<Color>(
                    theme.colorScheme.secondary),
                shape: MaterialStateProperty.all<OutlinedBorder>(
                  const StadiumBorder(),
                ),
              ),
              onPressed: _submitData,
              child: const Text(
                'Add Fragment',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
