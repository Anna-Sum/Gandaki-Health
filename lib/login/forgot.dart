import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Make sure this import is present

class ForgotPasswordPage extends StatelessWidget {
  static const routeName = '/forgot-password';

  // Controller setup using GetX dependency injection
  final ForgotPasswordController controller =
      Get.put(ForgotPasswordController());

  ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reset Password')),
      body: Padding(
        padding: EdgeInsets.all(6.w), // Padding from Sizer package
        child: Column(
          children: [
            Text(
              'Enter your email to receive a password reset link.',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 3.h), // Spacing using Sizer package
            TextField(
              onChanged: (value) =>
                  controller.email.value = value, // Update email in controller
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            SizedBox(height: 4.h), // Spacing using Sizer package
            Obx(() => ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : controller.sendResetEmail,
                  child: controller.isLoading.value
                      ? const CircularProgressIndicator() // Show progress while loading
                      : const Text('Send Reset Email'),
                )),
          ],
        ),
      ),
    );
  }
}

class ForgotPasswordController extends GetxController {
  var email = ''.obs;
  var isLoading = false.obs;

  // Method to send the password reset email
  Future<void> sendResetEmail() async {
    if (email.value.isEmpty) {
      // Show an error if the email field is empty
      Get.snackbar('Error', 'Please enter your email',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    // Simple email validation
    if (!GetUtils.isEmail(email.value)) {
      Get.snackbar('Error', 'Please enter a valid email address',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    try {
      isLoading.value = true; // Show loading indicator

      // Simulate sending a reset email (replace with actual Firebase logic)
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email.value);
      isLoading.value = false; // Hide loading indicator

      // Show confirmation message using Snackbar
      Get.snackbar('Success', 'Password reset link sent to your email',
          snackPosition: SnackPosition.BOTTOM);

      // Optionally, redirect the user to the login page after sending the email
      Get.offNamed('/MyLoginPage');
    } catch (e) {
      isLoading.value = false; // Hide loading indicator

      // Show error message
      Get.snackbar('Error', 'Failed to send password reset link. Try again.',
          snackPosition: SnackPosition.BOTTOM);
    }
  }
}
