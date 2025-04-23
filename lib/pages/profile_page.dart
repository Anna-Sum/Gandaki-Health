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

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        setState(() {
          _userData = userDoc.data() as Map<String, dynamic>;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      log("Error fetching user data: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _signOut() async {
    bool confirm = await _showConfirmDialog();
    if (!confirm) return;

    setState(() {
      _isSigningOut = true;
    });

    try {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/MyLoginPage');
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

  Future<bool> _showConfirmDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Log Out'),
            content: const Text('Are you sure you want to log out?'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel')),
              TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Log Out')),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = ref.read(themeProvider.notifier);
    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark;

    return Scaffold(
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  _buildSectionTitle('Account'),
                  _buildListTile(
                    icon: Icons.person,
                    title: 'View Profile',
                    onTap: _showProfileDialog,
                  ),
                  const SizedBox(height: 16),
                  _buildSectionTitle('Settings'),
                  SwitchListTile(
                    secondary: const Icon(Icons.brightness_6),
                    title: Text(isDarkMode ? "Dark Mode" : "Light Mode"),
                    value: isDarkMode,
                    onChanged: (value) => themeNotifier.toggleTheme(),
                    dense: true,
                  ),
                  _buildListTile(
                    icon: Icons.language,
                    title: 'Language',
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => showDialog(
                      context: context,
                      builder: (context) => const AlertDialog(
                        title: Text('Language'),
                        content: Text('Coming Soon...'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSectionTitle('Others'),
                  _buildListTile(
                    icon: Icons.logout,
                    title: 'Log Out',
                    titleColor: Colors.red,
                    onTap: _isSigningOut ? null : _signOut,
                    trailing: _isSigningOut
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : null,
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey,
            ),
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    required VoidCallback? onTap,
    Widget? trailing,
    Color? titleColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: titleColor ?? Colors.blueAccent),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: titleColor ?? Theme.of(context).textTheme.bodyMedium?.color,
        ),
      ),
      onTap: onTap,
      trailing: trailing,
    );
  }

  void _showProfileDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Center(
          child: Text(
            'Your Profile',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
          ),
        ),
        content: _userData == null
            ? const Text("No user data found!")
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProfileInfo('First Name', _userData?['firstName']),
                    _buildProfileInfo('Middle Name', _userData?['middleName']),
                    _buildProfileInfo('Last Name', _userData?['lastName']),
                    _buildProfileInfo('Email', _userData?['email']),
                    _buildProfileInfo('User Type', _userData?['userType']),
                  ],
                ),
              ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInfo(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.blueAccent),
        ),
        child: Text(
          "$label: ${value ?? 'N/A'}",
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
