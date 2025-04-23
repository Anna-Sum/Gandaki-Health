import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../customs/text_form_field_custom.dart'; // Assuming this is your custom TextFormField widget
import 'auth_model.dart';

class DemoHive extends StatefulWidget {
  const DemoHive({super.key});

  @override
  State<DemoHive> createState() => _DemoHiveState();
}

class _DemoHiveState extends State<DemoHive> {
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  late Box<AuthModel> userBox;

  @override
  void initState() {
    super.initState();
    _initializeHiveBox();
  }

  // Initialize the Hive box
  Future<void> _initializeHiveBox() async {
    userBox = await Hive.openBox<AuthModel>('user_credential');
    setState(() {}); // Update UI after box is opened
  }

  void addAuthData() {
    final username = userNameController.text.trim();
    final password = passwordController.text.trim();

    if (username.isNotEmpty && password.isNotEmpty) {
      userBox.put(username, AuthModel(username, password));
      userNameController.clear();
      passwordController.clear();
      setState(() {});
    }
  }

  void showUserDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Stored Users'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: userBox.keys.map((key) {
                final auth = userBox.get(key) as AuthModel;
                return ListTile(
                  title: Text(auth.userName),
                  subtitle: Text(auth.password),
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // If the box is not opened yet, show a loading indicator.
    if (!userBox.isOpen) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(title: Text('Hive Demo')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CustomTextFormField(controller: userNameController),
            TextField(controller: passwordController),
            ElevatedButton(
                onPressed: addAuthData, child: const Text('Add User')),
            Expanded(
              child: ListView.builder(
                itemCount: userBox.keys.length, // Length of keys in the box
                itemBuilder: (context, index) {
                  final key = userBox.keys
                      .toList()[index]; // Get the key at the given index
                  final auth = userBox.get(key)
                      as AuthModel; // Retrieve the AuthModel using the key
                  return ListTile(
                    title: Text(auth.userName),
                    subtitle: Text(auth.password),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
