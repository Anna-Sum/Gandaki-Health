import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:health_portal/customs/app_bar_custom.dart';

import '../constants/firebase_constant.dart';

class AddWebLinkPage extends StatefulWidget {
  static const routeName = '/AddWebLinkPage';

  const AddWebLinkPage({super.key});
  @override
  State<AddWebLinkPage> createState() => _WebsiteFormState();
}

class _WebsiteFormState extends State<AddWebLinkPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _linkController = TextEditingController();
  final CollectionReference websites =
      FirebaseFirestore.instance.collection(FirebaseCollection.websites);

  Future<void> _addWebsite() async {
    if (_formKey.currentState!.validate()) {
      try {
        await websites.add({
          'title': _titleController.text,
          'link': _linkController.text,
          'timestamp': FieldValue.serverTimestamp(),
        });
        _titleController.clear();
        _linkController.clear();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Website added successfully!')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error adding website: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Add Website',
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                spacing: MediaQuery.of(context).size.height * 0.02,
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(labelText: 'Title'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _linkController,
                    decoration: InputDecoration(labelText: 'Link'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a link';
                      }
                      final url = value.trim();
                      if (!url.startsWith('http://') &&
                          !url.startsWith('https://')) {
                        return 'Please include http:// or https://';
                      }
                      if (!Uri.parse(url).isAbsolute) {
                        return 'Please enter a valid URL';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _addWebsite,
                    child: Text('Add Website'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _linkController.dispose();
    super.dispose();
  }
}
