import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_pensieve/controller/controller.dart';
import 'package:my_pensieve/models/fragment.dart';
import 'package:my_pensieve/providers/fragments.dart';
import 'package:provider/provider.dart';

class EditFragmentWidget extends StatefulWidget {
  const EditFragmentWidget({
    super.key,
    required this.fragmentId,
    required this.customController,
  });

  final String fragmentId;

  final CustomController customController;

  @override
  State<EditFragmentWidget> createState() => _EditFragmentWidgetState();
}

class _EditFragmentWidgetState extends State<EditFragmentWidget> {
  final _fragmentForm = GlobalKey<FormState>();

  var _editedFragment = Fragment(
    category: '',
    title: '',
    value: '',
    date: DateTime.now(),
  );
  bool _isInit = true;

  final _dateController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    widget.customController.handleController = saveForm;

    _dateController.text = DateFormat("EEEE, yyyy/MM/dd").format(_selectedDate);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      if (widget.fragmentId.isNotEmpty) {
        _editedFragment = Provider.of<Fragments>(context, listen: false)
            .findById(widget.fragmentId);
      }
    }
    _isInit = false;
    super.didChangeDependencies();
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

        _dateController.text =
            DateFormat("EEEE, yyyy/MM/dd").format(_selectedDate);
      });
    });
  }

  Widget _buildFragmentItem(
      theme, mediaQuery, Icon icon, TextFormField textFormField) {
    return Container(
      padding: const EdgeInsets.all(5.0),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: icon,
          ),
          SizedBox(
            width: mediaQuery.size.width * 0.1,
          ),
          Expanded(
            flex: 5,
            child: textFormField,
          ),
        ],
      ),
    );
  }

  void saveForm() {
    FormState formState = _fragmentForm.currentState as FormState;
    if (!formState.validate()) {
      return;
    }
    // Save value in the form
    formState.save();

    // Save the fragment
    if (_editedFragment.id != null) {
      Provider.of<Fragments>(context, listen: false)
          .updateFragment(_editedFragment.id!, _editedFragment);
      Navigator.of(context).pop();
    } else {
      Provider.of<Fragments>(context, listen: false)
          .addFragment(_editedFragment);
      Navigator.of(context).pushNamed('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);

    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(10.0),
        child: Form(
          key: _fragmentForm,
          child: Column(
            children: <Widget>[
              _buildFragmentItem(
                theme,
                mediaQuery,
                const Icon(
                  Icons.category,
                  color: Colors.white,
                ),
                TextFormField(
                  initialValue: _editedFragment.category,
                  decoration: InputDecoration(
                    labelText: 'Category',
                    labelStyle: theme.textTheme.labelLarge,
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    errorStyle: const TextStyle(
                      color: Colors.transparent,
                      fontSize: 0,
                    ),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'error';
                    }
                    return null;
                  },
                  onSaved: (newValue) {
                    _editedFragment.category = newValue!;
                  },
                ),
              ),
              _buildFragmentItem(
                theme,
                mediaQuery,
                const Icon(
                  Icons.title,
                  color: Colors.white,
                ),
                TextFormField(
                  initialValue: _editedFragment.title,
                  decoration: InputDecoration(
                    labelText: 'Title',
                    labelStyle: theme.textTheme.labelLarge,
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    errorStyle: const TextStyle(
                      color: Colors.transparent,
                      fontSize: 0,
                    ),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'error';
                    }
                    return null;
                  },
                  onSaved: (newValue) {
                    _editedFragment.title = newValue!;
                  },
                ),
              ),
              _buildFragmentItem(
                theme,
                mediaQuery,
                const Icon(
                  Icons.info,
                  color: Colors.white,
                ),
                TextFormField(
                  initialValue: _editedFragment.value,
                  decoration: InputDecoration(
                    labelText: 'Value',
                    labelStyle: theme.textTheme.labelLarge,
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    errorStyle: const TextStyle(
                      color: Colors.transparent,
                      fontSize: 0,
                    ),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'error';
                    }
                    return null;
                  },
                  onSaved: (newValue) {
                    _editedFragment.value = newValue!;
                  },
                ),
              ),
              _buildFragmentItem(
                theme,
                mediaQuery,
                const Icon(
                  Icons.notes,
                  color: Colors.white,
                ),
                TextFormField(
                  initialValue: _editedFragment.note,
                  decoration: InputDecoration(
                    labelText: 'Note',
                    labelStyle: theme.textTheme.labelLarge,
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                  maxLines: 3,
                ),
              ),
              _buildFragmentItem(
                theme,
                mediaQuery,
                const Icon(
                  Icons.date_range,
                  color: Colors.white,
                ),
                TextFormField(
                  readOnly: true,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                  ),
                  controller: _dateController,
                  onTap: () {
                    // Below line stops keyboard from appearing
                    FocusScope.of(context).requestFocus(FocusNode());

                    // Show datepicker
                    _presentDatePicker(context);
                  },
                  onSaved: (_) {
                    _editedFragment.date = _selectedDate;
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
