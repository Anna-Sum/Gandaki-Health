import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../constants/firebase_constant.dart';
import '../../route_manager/route_manager.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Drawer(
        child: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, authSnapshot) {
            if (authSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!authSnapshot.hasData) {
              return const Center(child: Text('Please log in'));
            }

            return StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection(FirebaseCollection.users)
                  .doc(authSnapshot.data!.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final String role = snapshot.data?['role'] ?? 'user';

                final filteredDrawerItems = drawerItems.where((item) {
                  if (item.routeName == RouteNames.myDashBoardPage) {
                    return role == UserRole.admin;
                  }
                  return true;
                }).toList();

                return ListView(
                  children: [
                    if (role == 'user')
                      const DrawerHeader(
                        child: Text(
                          'Admin features (view only)',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ...List.generate(filteredDrawerItems.length, (index) {
                      final item = filteredDrawerItems[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 4.0,
                        ),
                        child: ListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          tileColor: item.color?.withAlpha(40),
                          title: Row(
                            children: [
                              Icon(
                                item.icon,
                                size: MediaQuery.of(context).size.width * 0.04,
                                color:
                                    role == 'user' ? Colors.grey : item.color,
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.02,
                              ),
                              Text(
                                item.title,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: role == 'user'
                                          ? Colors.grey
                                          : item.color,
                                    ),
                              ),
                            ],
                          ),
                          onTap: role == 'user'
                              ? () {
                                  // Optionally show a toast/snackbar
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Admin access only'),
                                    ),
                                  );
                                }
                              : () {
                                  Navigator.pushNamed(context, item.routeName);
                                },
                        ),
                      );
                    }),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class DrawerModel {
  final IconData icon;
  final String title;
  final String routeName;
  final Color? color;

  DrawerModel({
    required this.icon,
    required this.title,
    required this.routeName,
    this.color,
  });
}

List<DrawerModel> drawerItems = [
  DrawerModel(
    icon: Icons.dashboard,
    title: 'Admin Console',
    routeName: RouteNames.myDashBoardPage,
    color: const Color.fromARGB(255, 175, 3, 218),
  ),
  DrawerModel(
    icon: Icons.notifications,
    title: 'Alerts Management',
    routeName: RouteNames.alertAddPage,
    color: Colors.red,
  ),
  DrawerModel(
    icon: Icons.book,
    title: 'IECs Management',
    routeName: RouteNames.addNewContentPage,
    color: Colors.blue,
  ),
  DrawerModel(
    icon: Icons.local_hospital,
    title: 'Resources Management',
    routeName: RouteNames.addHospitalPage,
    color: Colors.green,
  ),
  DrawerModel(
    icon: Icons.language,
    title: 'Webinks Management',
    routeName: RouteNames.addWebLinkPage,
    color: Colors.deepOrange,
  ),
  DrawerModel(
    icon: Icons.feedback,
    title: 'Feedback Management',
    routeName: RouteNames.feedbackListPage,
    color: Colors.deepPurple,
  ),
  DrawerModel(
      icon: Icons.bar_chart,
      title: 'Statistics Management',
      routeName: RouteNames.addStatisticsPage,
      color: const Color.fromARGB(255, 6, 6, 6)),
];
