import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../customs/app_bar_custom.dart';

class AddNewContentPage extends StatefulWidget {
  static const routeName = '/AddNewContentPage';
  const AddNewContentPage({super.key});

  @override
  State<AddNewContentPage> createState() => _AddNewContentPageState();
}

class _AddNewContentPageState extends State<AddNewContentPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();
  String? _selectedCategory;

  final List<String> _categories = [
    'Nutrition',
    'Exercise',
    'Mental Health',
    'General Wellness'
  ];

  Future<void> _uploadContent() async {
    if (_titleController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('content').add({
        'title': _titleController.text,
        'description': _descriptionController.text,
        'category': _selectedCategory,
        'url': _urlController.text,
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Content added successfully!')),
        );
      }

      _titleController.clear();
      _descriptionController.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'New Content'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _urlController,
              decoration: const InputDecoration(labelText: 'Video Link'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              items: _categories.map((category) {
                return DropdownMenuItem(value: category, child: Text(category));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                });
              },
              decoration: const InputDecoration(labelText: 'Category'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _uploadContent,
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
