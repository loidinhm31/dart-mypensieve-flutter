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
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: theme.colorScheme.background,
                      ),
                      child: Text(
                        'Added',
                        style: theme.textTheme.displayLarge,
                      ),
                      onPressed: () async {
                        if (_localSyncHive != null) {
                          _localSyncHive!.added = [];
                          await _localSyncService.addData(_dropdownValue!,
                              {LocalSync.fAdded: _localSyncHive!.added});
                        }
                      },
                    ),
                    TextButton(
                      onPressed: () {
                        _showMultiSelect(context, LocalSync.fAdded);
                      },
                      child: const Text('Select'),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    _localSyncHive != null
                        ? _localSyncHive!.added!.join(' - ').toString()
                        : '',
                    style: theme.textTheme.displayMedium,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: theme.colorScheme.background,
                      ),
                      child: Text(
                        'Updated',
                        style: theme.textTheme.displayLarge,
                      ),
                      onPressed: () async {
                        if (_localSyncHive != null) {
                          _localSyncHive!.updated = [];
                          await _localSyncService.addData(_dropdownValue!,
                              {LocalSync.fUpdated: _localSyncHive!.updated});
                        }
                      },
                    ),
                    TextButton(
                      onPressed: () {
                        _showMultiSelect(context, LocalSync.fUpdated);
                      },
                      child: const Text('Select'),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    _localSyncHive != null
                        ? _localSyncHive!.updated!.join(' - ').toString()
                        : '',
                    style: theme.textTheme.displayMedium,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: theme.colorScheme.background,
                      ),
                      child: Text(
                        'Deleted',
                        style: theme.textTheme.displayLarge,
                      ),
                      onPressed: () async {
                        if (_localSyncHive != null) {
                          _localSyncHive!.deleted = [];
                          await _localSyncService.addData(_dropdownValue!,
                              {LocalSync.fDeleted: _localSyncHive!.deleted});
                        }
                      },
                    ),
                    TextButton(
                      onPressed: () {
                        _showMultiSelect(context, LocalSync.fDeleted);
                      },
                      child: const Text('Select'),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    _localSyncHive != null
                        ? _localSyncHive!.deleted!.join(' - ').toString()
                        : '',
                    style: theme.textTheme.displayMedium,
                  ),
                ),
              ],
            )
          ],
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
