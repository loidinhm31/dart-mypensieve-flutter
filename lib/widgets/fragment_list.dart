import 'package:flutter/material.dart';
import 'package:my_pensieve/models/fragment.dart';
import 'package:my_pensieve/models/pageable.dart';
import 'package:my_pensieve/providers/fragments.dart';
import 'package:my_pensieve/widgets/fragment_item.dart';
import 'package:provider/provider.dart';

class FragmentListWidget extends StatefulWidget {
  const FragmentListWidget({
    super.key,
  });

  @override
  State<FragmentListWidget> createState() => _FragmentListWidgetState();
}

class _FragmentListWidgetState extends State<FragmentListWidget> {
  late Pageable _pageable;
  late bool _isLastPage;
  late bool _error;
  late bool _loading;
  late List<Fragment> _fragments = [];
  late ScrollController _scrollController;

  Future<void> _refreshFragments(BuildContext context) async {
    _pageable.pageNumber = 0;
    await Provider.of<Fragments>(context, listen: false)
        .fetchAndSetFragments(_pageable);
    setState(() {
      _fragments = Provider.of<Fragments>(context, listen: false).items;
    });
  }

  @override
  void initState() {
    super.initState();
    _pageable = Pageable(pageNumber: 0);
    _isLastPage = false;
    _loading = true;
    _error = false;
    _scrollController = ScrollController();
    _refreshFragments(context);
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  Future<void> _fetchNewData() async {
    try {
      _pageable.pageNumber = _pageable.pageNumber + 1;
      List<Fragment> newFragments =
          await Provider.of<Fragments>(context, listen: false)
              .fetchFragments(_pageable);

      setState(() {
        _isLastPage = newFragments.isEmpty;
        _loading = false;
        _pageable;
        _fragments.addAll(newFragments);
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    _scrollController.addListener(() {
      // A value equivalent to 80% of the list size.
      var nextPageTrigger = 0.8 * _scrollController.position.maxScrollExtent;

      // Fetches the next paginated data when the current postion of the user on the screen has surpassed
      if (_scrollController.position.pixels > nextPageTrigger) {
        if (!_isLastPage) {
          _loading = true;
          _fetchNewData();
        }
      }
    });

    if (_fragments.isEmpty) {
      if (_loading) {
        return const Center(
            child: Padding(
          padding: EdgeInsets.all(8),
          child: CircularProgressIndicator(),
        ));
      }
    }
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
      height: mediaQuery.size.height,
      child: RefreshIndicator(
        onRefresh: () => _refreshFragments(context),
        child: ListView.builder(
          controller: _scrollController,
          itemCount: _fragments.length,
          physics: const AlwaysScrollableScrollPhysics(),
          itemBuilder: (_, index) => FragmentItemWidget(
            key: ValueKey(_fragments[index].id),
            fragment: _fragments[index],
          ),
        ),
      ),
    );
  }
}
