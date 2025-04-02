import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../customs/text_form_field_custom.dart';
import '../firebase_services/firebase_database_services.dart';
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
    return Scaffold(
      appBar: AppBar(title: const Text('Hive Demo')),
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
                itemCount: userBox.length,
                itemBuilder: (context, index) {
                  final key = userBox.keyAt(index);
                  final auth = userBox.get(key) as AuthModel;
                  return ListTile(
                    title: Text(auth.userName),
                    subtitle: Text(auth.password),
                    trailing: IconButton(
                      icon: const Icon(Icons.info),
                      onPressed: () => showUserDataDialog(context),
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () => HiveFunction.fetch(),
              child: const Text('Fetch Data'),
            ),
            ElevatedButton(
              onPressed: () {
                FirebaseDatabaseServices.createCollectionWithCustomDocumentId(
                  collectionName: 'health',
                  documentId: 'hello',
                  data: {'name': 'health'},
                );
              },
              child: const Text('Add to Collection'),
            ),
          ],
        ),
      ),
    );
  }
}

class HiveFunction {
  static void fetch() {
    final userBox = Hive.box<AuthModel>('user_credential');
    if (userBox.isNotEmpty) {
      final firstUser = userBox.getAt(0);
      if (kDebugMode) {
        print('User at index 0: ${firstUser?.userName}');
      }
    } else {
      if (kDebugMode) {
        print('No users found in Hive.');
      }
    }
  }
}
