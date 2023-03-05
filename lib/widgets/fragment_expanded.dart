import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:my_pensieve/models/fragment.dart';
import 'package:my_pensieve/repository/mongo_repository.dart';
import 'package:my_pensieve/widgets/fragment_link_view_item.dart';

class ExpandedFragmentWidget extends StatelessWidget {
  const ExpandedFragmentWidget({
    super.key,
    required this.fragmentIds,
  });

  final List<String?> fragmentIds;

  Future<List<Fragment>> _fetchLinkedFragments() async {
    final MongoRepository mongoRepository = MongoRepository();
    await mongoRepository.open();

    List<Map<String, mongo.ObjectId>> idMaps = [];
    for (var id in fragmentIds) {
      idMaps.add({'_id': mongo.ObjectId.parse(id!)});
    }

    if (idMaps.isNotEmpty) {
      List<Map<String, dynamic>> results =
          await mongoRepository.find('fragments', {
        '\$or': idMaps,
      });

      return results.map((e) {
        return Fragment.fromMap(e);
      }).toList();
    } else {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);

    return FutureBuilder(
      future: _fetchLinkedFragments(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (_, index) {
                return Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(10.0),
                    border: const Border.fromBorderSide(
                      BorderSide(width: 2.0),
                    ),
                  ),
                  child: Column(
                    children: [
                      LinkFragmentViewItemWidget(
                        theme: theme,
                        mediaQuery: mediaQuery,
                        fragment: snapshot.data![index],
                      ),
                    ],
                  ),
                );
              },
            );
          } else {
            return Center(
              child: Text(
                'Empty link',
                style: theme.textTheme.displayLarge,
              ),
            );
          }
        }
      },
    );
  }
}
