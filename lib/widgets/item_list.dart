import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_pensieve/models/item.dart';

class ItemListWidget extends StatelessWidget {
  final List<Item> items;

  const ItemListWidget({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
      height: 350,
      child: items.isEmpty
          ? Center(
              child: Text(
                'No items added yet!',
                style: Theme.of(context).textTheme.displayLarge,
              ),
            )
          : ListView.builder(
              itemBuilder: (ctx, index) {
                return Card(
                  elevation: 5,
                  margin: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 5,
                  ),
                  child: ListTile(
                    leading: Container(
                      height: 60,
                      width: 150,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: FittedBox(
                          child: Text(items[index].category,
                              style: Theme.of(context).textTheme.labelLarge),
                        ),
                      ),
                    ),
                    title: Text(
                      items[index].title,
                      style: Theme.of(context).textTheme.displayLarge,
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          DateFormat.yMMMd().format(items[index].date!),
                          style: Theme.of(context).textTheme.displaySmall,
                        ),
                        Center(
                          child: Text(
                            items[index].value,
                            style: Theme.of(context).textTheme.displayMedium,
                          ),
                        ),
                      ],
                    ),
                    isThreeLine: true,
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {},
                    ),
                  ),
                );
              },
              itemCount: items.length,
            ),
    );
  }
}
