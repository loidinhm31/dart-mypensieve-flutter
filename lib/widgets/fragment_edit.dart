import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_pensieve/controller/controller.dart';
import 'package:my_pensieve/models/fragment.dart';
import 'package:my_pensieve/providers/fragments.dart';
import 'package:my_pensieve/providers/linked_fragments.dart';
import 'package:my_pensieve/screens/fragment_link_screen.dart';
import 'package:my_pensieve/screens/tabs_screen.dart';
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

  late Fragment _editedFragment;
  bool _isInit = true;

  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final _linkFragmentsController = TextEditingController();

  List<String?> _linkedIds = [];

  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    widget.customController.handleController = saveForm;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_isInit) {
      if (widget.fragmentId.isNotEmpty) {
        _editedFragment = Provider.of<Fragments>(context, listen: false)
            .findById(widget.fragmentId);

        _selectedDate = _editedFragment.date!;

        // Add selected linked fragments into list to keep checked state state
        final fragments = Provider.of<Fragments>(context, listen: false).items;
        for (String? id in _editedFragment.linkedItems!) {
          try {
            Fragment? f = fragments.firstWhere((element) => element.id == id,
                orElse: () => throw Exception());

            Provider.of<LinkedFragments>(context, listen: false)
                .addLinkedItem(f);
          } catch (error) {
            log('Linked fragment was deleted');
          }
        }

        // Init for linked items
        _linkedIds = _editedFragment.linkedItems!;
        _linkFragmentsController.text = _linkedIds.join(" - ");
      } else {
        _selectedDate = DateTime.now();
        _editedFragment = Fragment(
          category: '',
          title: '',
          description: '',
          date: _selectedDate,
        );
      }
      _dateController.text =
          DateFormat('EEEE, yyyy/MM/dd').format(_selectedDate);
      _timeController.text = '${_selectedDate.hour} : ${_selectedDate.minute}';
    }
    _isInit = false;
  }

  void _presentDatePicker(BuildContext context) {
    showDatePicker(
      context: context,
      initialDate: _selectedDate,
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

  void _presentTimePicker(BuildContext context) {
    showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDate),
    ).then((pickedTime) {
      if (pickedTime == null) {
        return;
      }

      setState(() {
        _selectedDate = _selectedDate.copyWith(
            hour: pickedTime.hour, minute: pickedTime.minute);
        _timeController.text =
            '${_selectedDate.hour} : ${_selectedDate.minute}';
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

  Future<void> saveForm() async {
    FormState formState = _fragmentForm.currentState as FormState;
    if (!formState.validate()) {
      return;
    }
    // Save value in the form
    formState.save();

    // Save the fragment
    if (_editedFragment.id != null) {
      await Provider.of<Fragments>(context, listen: false)
          .updateFragment(_editedFragment.id!, _editedFragment)
          .then((_) {
        Provider.of<LinkedFragments>(context, listen: false)
            .clearSelectedLinkedItem();

        Navigator.of(context).pop(true);
      });
    } else {
      try {
        await Provider.of<Fragments>(context, listen: false)
            .addFragment(_editedFragment)
            .then((_) {
          Provider.of<LinkedFragments>(context, listen: false)
              .clearSelectedLinkedItem();

          Navigator.of(context).pushNamed(TabScreenWidget.routeName);
        });
      } catch (error) {
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('An error occurred!'),
            content: Text(error.toString()),
            actions: <Widget>[
              TextButton(
                child: const Text('Okay'),
                onPressed: () {
                  Navigator.of(context).pushNamed(TabScreenWidget.routeName);
                },
              )
            ],
          ),
        );
      }
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
                    _editedFragment.category = newValue;
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
                    _editedFragment.title = newValue;
                  },
                ),
              ),
              _buildFragmentItem(
                theme,
                mediaQuery,
                const Icon(
                  Icons.description,
                  color: Colors.white,
                ),
                TextFormField(
                  initialValue: _editedFragment.description,
                  decoration: InputDecoration(
                    labelText: 'Description',
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
                    _editedFragment.description = newValue;
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
                  onSaved: (newValue) {
                    _editedFragment.note = newValue;
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(5.0),
                child: Row(
                  children: [
                    const Expanded(
                      flex: 1,
                      child: Icon(
                        Icons.date_range,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(
                      width: mediaQuery.size.width * 0.1,
                    ),
                    Expanded(
                      flex: 5,
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              readOnly: true,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                              ),
                              controller: _dateController,
                              onTap: () {
                                // Below line stops keyboard from appearing
                                FocusScope.of(context)
                                    .requestFocus(FocusNode());

                                // Show datepicker
                                _presentDatePicker(context);
                              },
                              onSaved: (_) {
                                _editedFragment.date = _selectedDate;
                              },
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              readOnly: true,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                              ),
                              controller: _timeController,
                              onTap: () {
                                // Below line stops keyboard from appearing
                                FocusScope.of(context)
                                    .requestFocus(FocusNode());

                                // Show datepicker
                                _presentTimePicker(context);
                              },
                              onSaved: (_) {
                                _editedFragment.date = _selectedDate;
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                  padding: const EdgeInsets.all(5.0),
                  child: Row(
                    children: [
                      const Expanded(
                        flex: 1,
                        child: Icon(
                          Icons.dataset_linked,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(
                        width: mediaQuery.size.width * 0.1,
                      ),
                      Expanded(
                          flex: 5,
                          child: TextFormField(
                            controller: _linkFragmentsController,
                            onTap: () => Navigator.of(context)
                                .pushNamed(LinkFragmentsScreenWidget.routeName,
                                    arguments: widget.fragmentId)
                                .then((value) {
                              if (value == true) {
                                setState(() {
                                  _linkedIds = Provider.of<LinkedFragments>(
                                          context,
                                          listen: false)
                                      .linkedItems
                                      .map((e) => e.id)
                                      .toList();
                                  _linkFragmentsController.text =
                                      _linkedIds.join(" - ");
                                });
                              }
                            }),
                            onSaved: (newValue) {
                              _editedFragment.linkedItems =
                                  Provider.of<LinkedFragments>(context,
                                          listen: false)
                                      .linkedItems
                                      .map((e) => e.id)
                                      .toList();
                            },
                          ))
                    ],
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
