import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

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
  static const routeName = '/MyProfilePage';
  const MyProfilePage({super.key});

  @override
  ConsumerState<MyProfilePage> createState() => _MyProfilePageState();
}

class _MyProfilePageState extends ConsumerState<MyProfilePage> {
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  bool _isSigningOut = false;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        log("No user is logged in.");
        return;
      }

      log("Fetching data for user ID: ${user.uid}");

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        log("User document found: ${userDoc.data()}");
        setState(() {
          _userData = userDoc.data() as Map<String, dynamic>;
          _isLoading = false;
        });
      } else {
        log("User document does not exist in Firestore.");
        setState(() => _isLoading = false);
      }
    } catch (e) {
      log("Error fetching user data: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _signOut() async {
    setState(() {
      _isSigningOut = true;
    });

    try {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/MyLoginPage');
        log("Signed out successfully.");
      }
    } catch (e) {
      log("Error signing out: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error signing out: $e")),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSigningOut = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = ref.read(themeProvider.notifier);
    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark;

    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          _buildListTile(
            title: 'Profile',
            onTap: _showProfileDialog,
          ),
          SwitchListTile(
            title: Text(
              isDarkMode ? "Dark Mode" : "Light Mode",
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            value: isDarkMode,
            onChanged: (value) => themeNotifier.toggleTheme(),
            visualDensity: VisualDensity(horizontal: 4, vertical: 2),
            dense: true,
            controlAffinity: ListTileControlAffinity.trailing,
          ),
          _buildListTile(
            title: 'Language',
            onTap: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text('Language'),
                    content: Text('Coming Soon'),
                  );
                },
              );
            },
            trailing: Icon(Icons.arrow_drop_down),
          ),
          _buildListTile(
            title: 'Log Out',
            onTap: _isSigningOut ? null : _signOut,
            titleColor: Colors.red,
            trailing: _isSigningOut
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : null,
          ),
        ],
      ),
    );
  }

  void _showProfileDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Center(
          child: Text(
            'Your Profile',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        content: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _userData != null
                    ? [
                        _buildProfileInfo(
                            'First Name', _userData?['firstName']),
                        _buildProfileInfo(
                            'Middle Name', _userData?['middleName']),
                        _buildProfileInfo('Last Name', _userData?['lastName']),
                        _buildProfileInfo('Email', _userData?['email']),
                      ]
                    : [const Text("No user data found!")],
              ),
        actions: [
          TextButton(
            child: const Text('Close'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInfo(String label, String? value) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      margin: const EdgeInsets.all(8),
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0x48607D8B),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0x489E9E9E)),
      ),
      child: Text(
        "$label: ${value ?? 'N/A'}",
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildListTile({
    required String title,
    required VoidCallback? onTap,
    Color? titleColor,
    Widget? trailing,
  }) {
    return ListTile(
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: titleColor,
            ),
      ),
      onTap: onTap,
      trailing: trailing,
    );
  }
}
