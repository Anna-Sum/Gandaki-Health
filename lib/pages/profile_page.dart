import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sizer/sizer.dart';

import '../login/login_page.dart';

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(_getSavedTheme());

  static ThemeMode _getSavedTheme() {
    final box = Hive.box('settings');
    bool isDark = box.get('isDarkMode', defaultValue: false);
    return isDark ? ThemeMode.dark : ThemeMode.light;
  }

  void toggleTheme() {
    final box = Hive.box('settings');
    bool isDark = state == ThemeMode.dark;
    state = isDark ? ThemeMode.light : ThemeMode.dark;
    box.put('isDarkMode', !isDark);
  }
}

class MyProfilePage extends ConsumerStatefulWidget {
  const MyProfilePage({super.key});

  @override
  ConsumerState<MyProfilePage> createState() => _MyProfilePageState();
}

class _MyProfilePageState extends ConsumerState<MyProfilePage> {
  //alert dialog
  Future<void> _showMyDialog() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(child: const Text('Your Profile')),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Raj Karki'),
                Text('Nepal'),
                Text('Health Assistant'),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  //
  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();

    // Ensure the widget is still in the tree before navigating
    if (mounted) {
      Future.delayed(Duration.zero, () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MyLoginPage()),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = ref.read(themeProvider.notifier);
    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark;
    return Container(
      padding: EdgeInsets.all(8.0),
      child: Column(
        spacing: 0.3.h,
        children: [
          ListTile(
              title: Text('Profile'),
              onTap: () async {
                await _showMyDialog();
              }),
          SwitchListTile(
            title: Text(isDarkMode ? "Dark Mode" : "Light Mode"),
            value: isDarkMode,
            onChanged: (value) => themeNotifier.toggleTheme(),
          ),
          ListTile(
            title: Text(
              'Log Out',
              style: TextStyle(
                color: Colors.red,
              ),
            ),
            onTap: () async {
              // Future<void> signOut() async {
              //   await FirebaseAuth.instance.signOut();

              //   if (context.mounted) {
              //     Navigator.pushReplacement(context,
              //         MaterialPageRoute(builder: (context) => MyLoginPage()));
              //   }
              // }

              // await signOut();
              await signOut();
            },
          ),
        ],
      ),
    );
  }
}
