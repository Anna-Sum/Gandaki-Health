import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginSignInServices {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Sign In with Email and Password
  Future<User?> signIn({required String email, required String password}) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return userCredential.user;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Sign Up with Email and Password
  Future<User?> signUp({required String email, required String password}) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Sign In with Google
  Future<User?> signInWithGoogle() async {
    try {
      // Start the Google Sign-In process
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // User canceled the sign-in
        return null;
      }

      // Get the authentication details
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential using the Google authentication details
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in with the Google credentials
      UserCredential userCredential = await _auth.signInWithCredential(credential);
      User? user = userCredential.user;

      // Check if the user data exists in Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();

      if (!userDoc.exists) {
        // If no document exists for the user, create a new document
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'firstName': user.displayName?.split(' ')[0] ?? 'First Name',  // Use first part of display name
          'lastName': user.displayName?.split(' ')[1] ?? 'Last Name',  // Use second part of display name
          'email': user.email,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      return user;
    } catch (e) {
      throw Exception('Google sign-in failed: $e');
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();  // Also sign out from Google
  }

  // Get the current authenticated user
  User? get currentUser => _auth.currentUser;

  // Reset Password
  Future<void> resetPassword({required String email}) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }
}
