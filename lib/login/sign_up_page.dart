import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../constants/constant.dart';
import '../customs/app_bar_custom.dart';
import '../customs/text_form_field_custom.dart';

class MySignUpPage extends StatefulWidget {
  static const routeName = '/MySignUpPage';
  const MySignUpPage({super.key});

  @override
  State<MySignUpPage> createState() => _MySignUpPageState();
}

class _MySignUpPageState extends State<MySignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _midNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _isPasswordVisible = false; // Track password visibility
  String? _userType = 'general';

  String? _validateFirstName(String? value) {
    if (value == null || value.isEmpty) {
      return 'First name is required';
    }
    return null;
  }

  String? _validateLastName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Last name is required';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        String uid = userCredential.user!.uid;

        // Store user data including the selected user type
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'firstName': _firstNameController.text.trim(),
          'middleName': _midNameController.text.trim(),
          'lastName': _lastNameController.text.trim(),
          'email': _emailController.text.trim(),
          'createdAt': FieldValue.serverTimestamp(),
          'role': 'user', // Default role (you can leave this out if not needed)
          'userType': _userType, // New field to store user type
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sign-up successful!')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.toString()}')),
          );
        }
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Sign Up'),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextLabel('First Name'),
              CustomTextFormField(
                hintText: 'Enter your first name',
                controller: _firstNameController,
                validator: _validateFirstName,
              ),
              SizedBox(height: 3.h),
              _buildTextLabel('Middle Name'),
              CustomTextFormField(
                hintText: 'Enter your middle name (optional)',
                controller: _midNameController,
              ),
              SizedBox(height: 3.h),
              _buildTextLabel('Last Name'),
              CustomTextFormField(
                hintText: 'Enter your last name',
                controller: _lastNameController,
                validator: _validateLastName,
              ),
              SizedBox(height: 3.h),
              _buildTextLabel('Email'),
              CustomTextFormField(
                hintText: 'Enter your email',
                controller: _emailController,
                validator: _validateEmail,
              ),
              SizedBox(height: 3.h),
              _buildTextLabel('Password'),
              TextFormField(
                controller: _passwordController,
                validator: _validatePassword,
                obscureText: !_isPasswordVisible, // Toggle password visibility
                decoration: InputDecoration(
                  hintText: 'Enter your password',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ),
              ),
              SizedBox(height: 3.h),

              // New: User type dropdown
              _buildTextLabel('Select User Type'),
              DropdownButtonFormField<String>(
                value: _userType,
                items: const [
                  DropdownMenuItem(
                    value: 'general',
                    child: Text('General User'),
                  ),
                  DropdownMenuItem(
                    value: 'healthcare',
                    child: Text('Healthcare Provider'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _userType = value;
                  });
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),

              SizedBox(height: 5.h),
              Center(
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MyAppColors.primaryColor,
                      padding: EdgeInsets.symmetric(vertical: 2.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            'Create Account',
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextLabel(String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
    );
  }
}
