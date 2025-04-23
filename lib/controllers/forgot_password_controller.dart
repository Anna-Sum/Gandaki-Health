import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Assuming you're using Firebase for reset

class ForgotPasswordController extends GetxController {
  var email = ''.obs;
  var isLoading = false.obs;

  // Method to send reset email
  void sendResetEmail() async {
    if (email.value.isEmpty) {
      Get.snackbar("Error", "Please enter an email address.");
      return;
    }

    // Simple email validation (you can improve this)
    if (!GetUtils.isEmail(email.value)) {
      Get.snackbar("Error", "Please enter a valid email address.");
      return;
    }

    isLoading.value = true;

    try {
      // Send password reset email using Firebase Auth
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email.value);
      Get.snackbar("Success", "Password reset link sent to ${email.value}");
    } catch (e) {
      if (e is FirebaseAuthException) {
        // Handling specific Firebase Auth exceptions
        switch (e.code) {
          case 'user-not-found':
            Get.snackbar("Error", "No user found for that email.");
            break;
          case 'invalid-email':
            Get.snackbar("Error", "Invalid email address format.");
            break;
          default:
            Get.snackbar(
                "Error", "Failed to send reset link. Please try again.");
        }
      } else {
        Get.snackbar("Error", "Something went wrong. Please try again.");
      }
    } finally {
      isLoading.value = false;
    }
  }
}
