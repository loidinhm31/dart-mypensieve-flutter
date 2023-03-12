import 'package:flutter/material.dart';
import 'package:my_pensieve/models/category.dart';
import 'package:my_pensieve/services/category_service.dart';

class EditCategoryScreenWidget extends StatefulWidget {
  const EditCategoryScreenWidget({super.key});

  static const routeName = '/category-edit';

  @override
  State<EditCategoryScreenWidget> createState() =>
      _EditCategoryScreenWidgetState();
}

class _EditCategoryScreenWidgetState extends State<EditCategoryScreenWidget> {
  final _categoryForm = GlobalKey<FormState>();

  late Category _editedCategory;
  bool _isInit = true;

  Future<void> _saveForm() async {
    FormState formState = _categoryForm.currentState as FormState;
    if (!formState.validate()) {
      return;
    }
    // Save value in the form
    formState.save();

    // Save the category
    final CategoryService categoryService = CategoryService();
    if (_editedCategory.id != null) {
      // TODO
    } else {
      await categoryService.addOne(_editedCategory);
      // ignore: use_build_context_synchronously
      Navigator.of(context).pop(true);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_isInit) {
      _editedCategory = Category();
    }
    _isInit = false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);

    final routeArg = ModalRoute.of(context)?.settings.arguments;
    final fragmentId = routeArg != null ? routeArg as String : '';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(false),
          icon: const Icon(
            Icons.cancel,
          ),
        ),
        title: Text(fragmentId.isEmpty ? 'Add Category' : 'Edit Category'),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () async => await _saveForm(),
            child: const Text('Save'),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2.0),
          child: Container(
            color: Colors.blueGrey,
            height: 1.0,
          ),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(5.0),
        child: Form(
          key: _categoryForm,
          child: Column(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(5.0),
                child: Row(
                  children: <Widget>[
                    const Expanded(
                      flex: 1,
                      child: Icon(
                        Icons.question_mark,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(
                      width: mediaQuery.size.width * 0.05,
                    ),
                    Expanded(
                      flex: 5,
                      child: TextFormField(
                        initialValue: _editedCategory.name,
                        decoration: InputDecoration(
                          labelText: 'Name',
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
                          _editedCategory.name = newValue;
                        },
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
