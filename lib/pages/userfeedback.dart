import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../customs/app_bar_custom.dart';

class CustomTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final IconData? prefixIcon;
  final String? Function(String?)? validator;
  final int? maxLines;
  final TextInputType? keyboardType;
  final bool obscureText;

  const CustomTextFormField({
    super.key,
    required this.controller,
    required this.labelText,
    this.prefixIcon,
    this.validator,
    this.maxLines = 1,
    this.keyboardType,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: TextFormField(
        controller: controller,
        validator: validator,
        maxLines: maxLines,
        keyboardType: keyboardType,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: labelText,
          prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.blue, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          filled: true,
          fillColor: Colors.grey[100],
          labelStyle: const TextStyle(color: Colors.grey),
        ),
      ),
    );
  }
}

class FeedbackPage extends StatefulWidget {
  static const routeName = '/FeedbackPage';
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _feedbackController = TextEditingController();
  final TextEditingController _healthIssueController = TextEditingController();

  String? _selectedFeedbackType;
  String? _userName;
  int _rating = 0;
  bool _isLoading = false;

  final List<String> _feedbackTypes = [
    'Bug Report',
    'Feature Request',
    'General Feedback',
    'Support Request'
  ];

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    _userName = user?.displayName ?? user?.email ?? 'Anonymous';
  }

  Future<void> _submitFeedback() async {
    if (_formKey.currentState!.validate() && _selectedFeedbackType != null) {
      setState(() {
        _isLoading = true;
      });

      try {
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser == null) {
          // If the user is not authenticated, show an error message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('You must be logged in to submit feedback.')),
          );
          return;
        }

        await FirebaseFirestore.instance.collection('feedback').add({
          'name': _userName ?? 'Anonymous',
          'feedback': _feedbackController.text,
          'health_concern': _healthIssueController.text,
          'feedback_type': _selectedFeedbackType,
          'rating': _rating,
          'timestamp': FieldValue.serverTimestamp(),
          'category': 'health_portal',
          'user_id': currentUser.uid, // Using currentUser.uid
        });

        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Success'),
              content:
                  const Text('Your feedback has been submitted successfully!'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );

          _feedbackController.clear();
          _healthIssueController.clear();
          setState(() {
            _rating = 0;
            _selectedFeedbackType = null;
          });
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error submitting feedback: $e')),
          );
        }
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } else if (_selectedFeedbackType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a feedback type.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: CustomAppBar(title: 'Feedback'),
      body: Container(
        padding: EdgeInsets.all(w * 0.02),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Display user name
                TextFormField(
                  readOnly: true,
                  initialValue: _userName,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                ),
                const SizedBox(height: 10),
                CustomTextFormField(
                  controller: _healthIssueController,
                  labelText: 'Health Concern (Optional)',
                  prefixIcon: Icons.medical_services,
                ),
                CustomTextFormField(
                  controller: _feedbackController,
                  labelText: 'Your Feedback',
                  prefixIcon: Icons.comment,
                  maxLines: 5,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your feedback';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedFeedbackType,
                  decoration: InputDecoration(
                    labelText: 'Feedback Type',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                  items: _feedbackTypes.map((String type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedFeedbackType = newValue;
                    });
                  },
                ),
                const SizedBox(height: 12),
                const Text(
                  'Rate your experience:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return IconButton(
                      icon: Icon(
                        index < _rating ? Icons.star : Icons.star_border,
                        color: Colors.yellow[700],
                      ),
                      onPressed: () {
                        setState(() {
                          _rating = index + 1;
                        });
                      },
                    );
                  }),
                ),
                const SizedBox(height: 16),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _submitFeedback,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Submit Feedback',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    _healthIssueController.dispose();
    super.dispose();
  }
}
