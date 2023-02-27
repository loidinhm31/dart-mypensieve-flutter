import 'package:flutter/material.dart';
import 'package:my_pensieve/screens/fragments_screen.dart';
import 'package:my_pensieve/screens/fragment_edit_screen.dart';

class TabScreenWidget extends StatefulWidget {
  const TabScreenWidget({super.key});

  @override
  State<TabScreenWidget> createState() => _TabScreenWidgetState();
}

class _TabScreenWidgetState extends State<TabScreenWidget>
    with SingleTickerProviderStateMixin {
  late List<Widget> _pages;

  late AnimationController animationController;

  int _selectedPageIndex = 0;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    animationController.forward();

    _pages = [
      const FragmentListScreenWidget(),
      EditFragmentScreenWidget(),
      Container(), // TODO
    ];
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  void _selectPage(int index) {
    setState(() {
      _selectedPageIndex = index;

      if (_selectedPageIndex == 1) {
        // Hide bottom bar for the middle page
        animationController.reverse();
      } else {
        animationController.forward();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);

    return DefaultTabController(
      length: 3,
      initialIndex: 0,
      child: Scaffold(
        // Preserve the state of pages
        body: IndexedStack(
          index: _selectedPageIndex,
          children: _pages,
        ),
        bottomNavigationBar: SizeTransition(
          axisAlignment: -1.0,
          sizeFactor: animationController,
          child: BottomNavigationBar(
            iconSize: mediaQuery.size.height * 0.035,
            backgroundColor: theme.colorScheme.background,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
            unselectedItemColor: Colors.blueGrey,
            showUnselectedLabels: false,
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.memory),
                label: 'Pensieve',
              ),
              BottomNavigationBarItem(
                  icon: Container(
                    height: mediaQuery.size.height * 0.075,
                    width: mediaQuery.size.width * 0.5,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.add,
                    ),
                  ),
                  label: ''),
              const BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                label: 'Setting',
              ),
            ],
            currentIndex: _selectedPageIndex,
            onTap: _selectPage,
          ),
        ),
      ),
    );
  }
}
