import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../customs/app_bar_custom.dart';
import '../customs/text_form_field_custom.dart';
import '../route_manager/route_manager.dart';

class AddVideoPage extends StatefulWidget {
  static const routeName = RouteNames.addVideoPage;
  const AddVideoPage({super.key});

  @override
  State<AddVideoPage> createState() => _AddVideoPageState();
}

class _AddVideoPageState extends State<AddVideoPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;

  Future<void> _addVideoToFirestore() async {
    if (_titleController.text.isEmpty ||
        _urlController.text.isEmpty ||
        _descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Center(child: Text('Please fill all fields.'))),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _firestore.collection('videos').add({
        'title': _titleController.text.trim(),
        'url': _urlController.text.trim(),
        'description': _descriptionController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Video added successfully')),
        );
      }

      _titleController.clear();
      _urlController.clear();
      _descriptionController.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding video: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _urlController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: CustomAppBar(title: 'Add Video'),
      body: Padding(
        padding: EdgeInsets.all(w * 0.02),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildColumn(context, 'Title', _titleController),
            SizedBox(height: w * 0.04),
            _buildColumn(context, 'Link', _urlController),
            SizedBox(height: w * 0.04),
            _buildColumn(context, 'Description', _descriptionController),
            SizedBox(height: w * 0.04),
            ElevatedButton(
              onPressed: _isLoading ? null : _addVideoToFirestore,
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  Column _buildColumn(
      BuildContext context, String title, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        CustomTextFormField(
          controller: controller,
        ),
      ],
    );
  }
}
