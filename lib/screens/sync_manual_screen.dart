import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:my_pensieve/models/device_sync.dart';
import 'package:my_pensieve/models/hive/local_sync.dart';
import 'package:my_pensieve/providers/fragments.dart';
import 'package:my_pensieve/services/category_service.dart';
import 'package:my_pensieve/services/local_sync_service.dart';
import 'package:provider/provider.dart';

class ManualSyncScreenWidget extends StatefulWidget {
  const ManualSyncScreenWidget({super.key});

  @override
  State<ManualSyncScreenWidget> createState() => _ManualSyncScreenWidgetState();
}

class _ManualSyncScreenWidgetState extends State<ManualSyncScreenWidget> {
  final LocalSyncService _localSyncService = LocalSyncService();

  final List<String> _dropdownList = <String>['CATEGORIES', 'FRAGMENTS'];

  String? _dropdownValue;

  LocalSyncHive? _localSyncHive;

  void _showMultiSelect(BuildContext context, String type) async {
    if (_dropdownValue != null && _dropdownValue!.isNotEmpty) {
      final theme = Theme.of(context);
      List<Data> items = [];

      if (_dropdownValue != null) {
        if (_dropdownValue == 'CATEGORIES') {
          final CategoryService categoryService = CategoryService();
          items = (await categoryService.getCategories())
              .map((e) => Data(e.id!, e.name!))
              .toList();
          ;
        } else if (_dropdownValue == 'FRAGMENTS') {
          items = Provider.of<Fragments>(context, listen: false)
              .items
              .map((e) => Data(e.id!, e.title!))
              .toList();
        }
      }

      // ignore: use_build_context_synchronously
      await showDialog(
        context: context,
        builder: (ctx) {
          return MultiSelectDialog(
            searchable: true,
            searchIcon: const Icon(
              Icons.search,
              color: Colors.white,
            ),
            searchHintStyle: theme.textTheme.displayMedium,
            backgroundColor: theme.colorScheme.primary,
            itemsTextStyle: theme.textTheme.displayLarge,
            unselectedColor: theme.colorScheme.secondary,
            selectedColor: theme.colorScheme.secondary,
            selectedItemsTextStyle: theme.textTheme.displayLarge,
            items: items.map((e) => MultiSelectItem(e, e.name)).toList(),
            onConfirm: (values) {
              setState(() {
                switch (type) {
                  case LocalSync.fAdded:
                    _localSyncHive!.added = values.map((e) => e.id).toList();
                    break;
                  case LocalSync.fUpdated:
                    _localSyncHive!.updated = values.map((e) => e.id).toList();
                    break;
                  case LocalSync.fDeleted:
                    _localSyncHive!.deleted = values.map((e) => e.id).toList();
                    break;
                }
              });
            },
            initialValue: items.where((element) {
              switch (type) {
                case LocalSync.fAdded:
                  return _localSyncHive!.added!.contains(element.id);
                case LocalSync.fUpdated:
                  return _localSyncHive!.updated!.contains(element.id);
                case LocalSync.fDeleted:
                  return _localSyncHive!.deleted!.contains(element.id);
                default:
                  return false;
              }
            }).toList(),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        actions: [
          TextButton(
            onPressed: () {
              _localSyncService.updateLocalSync(_localSyncHive!).then((value) {
                setState(() {
                  _dropdownValue = null;
                  _localSyncHive = null;
                });
              });
            },
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(10.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              DropdownButton<String>(
                value: _dropdownValue,
                elevation: 16,
                items:
                    _dropdownList.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? value) async {
                  _localSyncHive =
                      await _localSyncService.getData(value!.toLowerCase());
                  setState(() {
                    _dropdownValue = value;
                  });
                },
              ),
              Container(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Chip(
                            backgroundColor: theme.colorScheme.secondary,
                            padding: const EdgeInsets.all(5.0),
                            label: Text(
                              'Added',
                              style: theme.textTheme.displayLarge,
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.all(5.0),
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: theme.colorScheme.secondary,
                                  width: 1.0,
                                ),
                              ),
                              onPressed: () {
                                _showMultiSelect(context, LocalSync.fAdded);
                              },
                              child: const Text('Select'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 5,
                      child: Container(
                        padding: const EdgeInsets.all(10.0),
                        child: Wrap(
                          children: _localSyncHive != null &&
                                  _localSyncHive!.added != null
                              ? _localSyncHive!.added!
                                  .map((e) => Padding(
                                        padding: const EdgeInsets.all(2.0),
                                        child: Chip(
                                          label: Text(e,
                                              style: theme
                                                  .textTheme.displayMedium),
                                          backgroundColor:
                                              theme.colorScheme.background,
                                        ),
                                      ))
                                  .toList()
                              : <Widget>[],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Chip(
                            backgroundColor: theme.colorScheme.secondary,
                            padding: const EdgeInsets.all(5.0),
                            label: Text(
                              'Updated',
                              style: theme.textTheme.displayLarge,
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.all(5.0),
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: theme.colorScheme.secondary,
                                  width: 1.0,
                                ),
                              ),
                              onPressed: () {
                                _showMultiSelect(context, LocalSync.fUpdated);
                              },
                              child: const Text('Select'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 5,
                      child: Container(
                        padding: const EdgeInsets.all(10.0),
                        child: Wrap(
                          children: _localSyncHive != null &&
                                  _localSyncHive!.updated != null
                              ? _localSyncHive!.updated!
                                  .map((e) => Padding(
                                        padding: const EdgeInsets.all(2.0),
                                        child: Chip(
                                          label: Text(e,
                                              style: theme
                                                  .textTheme.displayMedium),
                                          backgroundColor:
                                              theme.colorScheme.background,
                                        ),
                                      ))
                                  .toList()
                              : <Widget>[],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Chip(
                            backgroundColor: theme.colorScheme.secondary,
                            padding: const EdgeInsets.all(5.0),
                            label: Text(
                              'Deleted',
                              style: theme.textTheme.displayLarge,
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.all(5.0),
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: theme.colorScheme.secondary,
                                  width: 1.0,
                                ),
                              ),
                              onPressed: () {
                                _showMultiSelect(context, LocalSync.fDeleted);
                              },
                              child: const Text('Select'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 5,
                      child: Container(
                        padding: const EdgeInsets.all(10.0),
                        child: Wrap(
                          children: _localSyncHive != null &&
                                  _localSyncHive!.deleted != null
                              ? _localSyncHive!.deleted!
                                  .map((e) => Padding(
                                        padding: const EdgeInsets.all(2.0),
                                        child: Chip(
                                          label: Text(e,
                                              style: theme
                                                  .textTheme.displayMedium),
                                          backgroundColor:
                                              theme.colorScheme.background,
                                        ),
                                      ))
                                  .toList()
                              : <Widget>[],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Data {
  final String id;
  final String name;

  Data(this.id, this.name);
}
