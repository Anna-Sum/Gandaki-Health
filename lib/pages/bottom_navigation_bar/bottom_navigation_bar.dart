import 'package:flutter/material.dart';

import '../../constants/constant.dart';
import '../../route_manager/route_manager.dart';
import '../content_page.dart';
import '../drawer_pages/drawer.dart';
import '../home_page.dart';
import '../profile_page.dart';
import '../search_page.dart';
import '../video_list_page.dart';
import 'bottom_nav_bar_model.dart';

class MyBottomNavigationBar extends StatefulWidget {
  static const routeName = RouteNames.bottomNavigationBar;
  const MyBottomNavigationBar({super.key});

  @override
  State<MyBottomNavigationBar> createState() => _MyBottomNavigationBarState();
}

class _MyBottomNavigationBarState extends State<MyBottomNavigationBar> {
  int _selectedIndex = 0;

  final List<BottomNavigationBarModel> _navItems = [
    BottomNavigationBarModel(
      selectedIcon: Icons.home,
      unSelectedIcon: Icons.home_outlined,
      label: 'Home',
      page: MyHomePage(),
    ),
    BottomNavigationBarModel(
      selectedIcon: Icons.search,
      unSelectedIcon: Icons.search_outlined,
      label: 'Search',
      page: MySearchPage(),
    ),
    BottomNavigationBarModel(
      selectedIcon: Icons.play_circle_fill,
      unSelectedIcon: Icons.play_circle_filled_outlined,
      label: 'Videos',
      page: MyVideosListPage(),
    ),
    BottomNavigationBarModel(
      selectedIcon: Icons.book,
      unSelectedIcon: Icons.book_outlined,
      label: 'Content',
      page: MyContentPage(),
    ),
    BottomNavigationBarModel(
      selectedIcon: Icons.person,
      unSelectedIcon: Icons.person_2_outlined,
      label: 'Profile',
      page: MyProfilePage(),
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Constant.appName),
      ),
      drawer: MyDrawer(),
      body: Center(
        child: _navItems[_selectedIndex].page,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: _navItems.map((item) {
          int index = _navItems.indexOf(item);
          return BottomNavigationBarItem(
            icon: Icon(_selectedIndex == index
                ? item.selectedIcon
                : item.unSelectedIcon),
            label: item.label,
          );
        }).toList(),
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
