import 'package:flutter/material.dart';
import 'package:my_pensieve/models/hive/category.dart';
import 'package:my_pensieve/screens/category_edit_screent.dart';
import 'package:my_pensieve/services/category_service.dart';

class CategorySelectScreenWidget extends StatefulWidget {
  const CategorySelectScreenWidget({super.key});

  static const routeName = '/category-select';

  @override
  State<CategorySelectScreenWidget> createState() =>
      _CategorySelectScreenWidgetState();
}

class _CategorySelectScreenWidgetState
    extends State<CategorySelectScreenWidget> {
  final CategoryService _categoryService = CategoryService();

  String _selectedCategoryId = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final routeArg = ModalRoute.of(context)?.settings.arguments;
    _selectedCategoryId = routeArg != null ? routeArg as String : '';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context)
                  .pushNamed(EditCategoryScreenWidget.routeName);
            },
            icon: const Icon(Icons.add),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(_selectedCategoryId);
            },
            child: Text('Done', style: theme.textTheme.displayLarge),
          ),
        ],
      ),
      body: FutureBuilder(
        future: _categoryService.getCategories(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else {
            if (snapshot.hasData) {
              return Container(
                padding: const EdgeInsets.all(5.0),
                child: ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (_, index) {
                    return InkWell(
                      key: ValueKey(snapshot.data![index].id),
                      child: RadioListTile<String>(
                        tileColor: theme.colorScheme.tertiary,
                        title: Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: mediaQuery.size.height * 0.05,
                                width: mediaQuery.size.width * 0.05,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.background,
                                  shape: BoxShape.rectangle,
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                padding: const EdgeInsets.all(5.0),
                                child: FittedBox(
                                  child: Text(snapshot.data![index].name!,
                                      style: theme.textTheme.labelLarge),
                                ),
                              ),
                            ),
                          ],
                        ),
                        value: snapshot.data![index].id!,
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedCategoryId = newValue!;
                          });
                        },
                        groupValue: _selectedCategoryId,
                      ),
                    );
                  },
                ),
              );
            } else {
              return Center(
                child: Text(
                  'Empty category',
                  style: theme.textTheme.displayLarge,
                ),
              );
            }
          }
        },
      ),
    );
  }
}
