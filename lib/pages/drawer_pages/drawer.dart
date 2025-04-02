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

                return ListView.builder(
                  itemCount: filteredDrawerItems.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 4.0,
                      ),
                      child: ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        tileColor:
                            filteredDrawerItems[index].color?.withAlpha(40),
                        title: Row(
                          children: [
                            Icon(
                              filteredDrawerItems[index].icon,
                              size: MediaQuery.of(context).size.width * 0.04,
                              color: filteredDrawerItems[index].color,
                            ),
                            SizedBox(
                                width:
                                    MediaQuery.of(context).size.width * 0.02),
                            Text(
                              filteredDrawerItems[index].title,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                        onTap: () {
                          Navigator.pushNamed(
                              context, filteredDrawerItems[index].routeName);
                        },
                      ),
                    );
                  },
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
    title: 'Dashboard',
    routeName: RouteNames.myDashBoardPage,
    color: Colors.red,
  ),
  DrawerModel(
    icon: Icons.language,
    title: 'Websites',
    routeName: RouteNames.webListPage,
    color: Colors.green,
  ),
  DrawerModel(
    icon: Icons.health_and_safety,
    title: 'Hospitals',
    routeName: RouteNames.hospitalListPage,
    color: Colors.pink,
  ),
];
