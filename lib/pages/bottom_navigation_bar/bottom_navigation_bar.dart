import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../constants/constant.dart';
import '../../controllers/new_alert_controller.dart';
import '../../route_manager/route_manager.dart';
import '../content_page.dart';
import '../drawer_pages/drawer.dart';
import '../home_page.dart';
import '../profile_page.dart';
import '../search_page.dart';
import '../hospital_list_page.dart';
import '../alert_page.dart';
import 'bottom_nav_bar_model.dart';

class MyBottomNavigationBar extends StatefulWidget {
  static const routeName = RouteNames.bottomNavigationBar;

  const MyBottomNavigationBar({super.key});

  @override
  State<MyBottomNavigationBar> createState() => _MyBottomNavigationBarState();
}

class _MyBottomNavigationBarState extends State<MyBottomNavigationBar> {
  int _selectedIndex = 0;
  String? _userRole;
  final NewAlertController _alertController =
      Get.put(NewAlertController(), permanent: true);

  final List<BottomNavigationBarModel> _navItems = [];

  @override
  void initState() {
    super.initState();
    _fetchUserRole();

    _navItems.addAll([
      BottomNavigationBarModel(
        selectedIcon: Icons.home,
        unSelectedIcon: Icons.home_outlined,
        label: 'Home',
        page: MyHomePage(),
      ),
      BottomNavigationBarModel(
        selectedIcon: Icons.bar_chart,
        unSelectedIcon: Icons.bar_chart_outlined,
        label: 'Statistics',
        page: MySearchPage(),
      ),
      BottomNavigationBarModel(
        selectedIcon: Icons.local_hospital,
        unSelectedIcon: Icons.local_hospital_outlined,
        label: 'Resources',
        page: HospitalListPage(),
      ),
      BottomNavigationBarModel(
        selectedIcon: Icons.book,
        unSelectedIcon: Icons.book_outlined,
        label: 'IECs',
        page: MyContentPage(),
      ),
      BottomNavigationBarModel(
        selectedIcon: Icons.notifications,
        unSelectedIcon: Icons.notifications_none,
        label: 'Alerts',
        page: AlertPage(),
      ),
      BottomNavigationBarModel(
        selectedIcon: Icons.person,
        unSelectedIcon: Icons.person_2_outlined,
        label: 'Profile',
        page: MyProfilePage(),
      ),
    ]);
  }

  Future<void> _fetchUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (doc.exists && doc.data() != null) {
        setState(() {
          _userRole = doc['role'] ?? 'user';
        });
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // If userRole hasn't loaded yet, show a loader
    if (_userRole == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final isUser = _userRole == 'user';

    return Scaffold(
      appBar: AppBar(
        title: Text(Constant.appName),
        automaticallyImplyLeading: !isUser, // Hide hamburger for 'user'
      ),
      drawer: isUser ? null : MyDrawer(), // Disable drawer for 'user'
      body: _navItems[_selectedIndex].page,
      bottomNavigationBar: Obx(() => BottomNavigationBar(
            items: _navItems.asMap().entries.map((entry) {
              int index = entry.key;
              var item = entry.value;

              if (item.label == 'Alerts') {
                return BottomNavigationBarItem(
                  icon: Stack(
                    children: [
                      Icon(
                        _selectedIndex == index
                            ? item.selectedIcon
                            : item.unSelectedIcon,
                      ),
                      if (_alertController.alertCount.value > 0)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              '${_alertController.alertCount}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                  label: item.label,
                );
              }

              return BottomNavigationBarItem(
                icon: Icon(
                  _selectedIndex == index
                      ? item.selectedIcon
                      : item.unSelectedIcon,
                ),
                label: item.label,
              );
            }).toList(),
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            type: BottomNavigationBarType.fixed,
          )),
    );
  }
}
