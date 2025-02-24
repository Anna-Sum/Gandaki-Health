import 'package:flutter/material.dart';
import 'package:health_portal/customs/app_bar_custom.dart';

import '../../constants/constant.dart';
import '../../dashboard/dashboard_page.dart';
import '../home_page.dart';
import '../profile_page.dart';
import '../search_page.dart';
import 'bottom_nav_bar_model.dart';

class MyBottomNavigationBar extends StatefulWidget {
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
      page: SearchPage(),
    ),
    BottomNavigationBarModel(
      selectedIcon: Icons.dashboard,
      unSelectedIcon: Icons.dashboard_outlined,
      label: 'Dashboard',
      page: MyDashBoardPage(),
    ),
    BottomNavigationBarModel(
      selectedIcon: Icons.book,
      unSelectedIcon: Icons.book_outlined,
      label: 'Education',
      page: Container(),
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
      appBar: CustomAppBar(
        title: Constant.appName,
        showNotification: true,
      ),
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
