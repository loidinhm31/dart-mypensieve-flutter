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
      color: theme.colorScheme.background,
      elevation: 5,
      child: Container(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Category',
                labelStyle: theme.textTheme.labelLarge,
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
              controller: _categoryController,
            ),
            TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Title',
                labelStyle: theme.textTheme.labelLarge,
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
              controller: _titleController,
            ),
            TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Value',
                labelStyle: theme.textTheme.labelLarge,
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
              controller: _valueController,
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    DateFormat("EEEE, yyyy/MM/dd").format(_selectedDate),
                    style: theme.textTheme.displayLarge,
                  ),
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
