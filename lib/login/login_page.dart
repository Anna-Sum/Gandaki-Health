import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sizer/sizer.dart';
import '../route_manager/route_manager.dart';

import '../constants/constant.dart';
import '../customs/text_form_field_custom.dart';
import '../hive/hive_initialization.dart';
import '../hive/auth_model.dart'; // Make sure you import the AuthModel class

final authProvider = Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);
final googleSignInProvider = Provider<GoogleSignIn>((ref) => GoogleSignIn());

class MyLoginPage extends ConsumerStatefulWidget {
  static const routeName = '/MyLoginPage';
  const MyLoginPage({super.key});

  @override
  ConsumerState<MyLoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<MyLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final MyHiveService myHiveService = MyHiveService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscureText = true;

  Future<void> _login() async {
    setState(() => _isLoading = true);
    final auth = ref.read(authProvider);

    try {
      await auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      _handleSuccessfulLogin();

      // Create an AuthModel instance and store it
      AuthModel authModel = AuthModel(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      // Store the AuthModel object in Hive
      await myHiveService.putData(
        key: 'authModel',
        value: authModel, // Save AuthModel instead of just strings
      );
    } on FirebaseAuthException catch (e) {
      _handleLoginError('Login Failed: ${e.message}');
    } catch (e) {
      _handleLoginError('An unexpected error occurred: $e');
    }
    setState(() => _isLoading = false);
  }

  Future<void> _loginWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      final googleSignIn = ref.read(googleSignInProvider);
      final auth = ref.read(authProvider);

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        setState(() => _isLoading = false);
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in with the Google credential
      UserCredential userCredential =
          await auth.signInWithCredential(credential);

      // Check if user document exists
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user?.uid)
          .get();

      // If the user does not exist in Firestore, create a new document
      if (!userDoc.exists) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user?.uid)
            .set({
          'email': userCredential.user?.email,
          'role': 'user', // Default role as 'user'
          'userType': 'general', // Default userType as 'general'
          'firstName': userCredential.user?.displayName?.split(' ')[0],
          'lastName': userCredential.user?.displayName?.split(' ')[1] ?? '',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      _handleSuccessfulLogin();

      // Create an AuthModel instance and store it
      AuthModel authModel = AuthModel(
          googleUser.email, ''); // Password might be empty for Google login

      // Store the AuthModel object in Hive
      await myHiveService.putData(
        key: 'authModel',
        value: authModel,
      );
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'account-exists-with-different-credential':
          message = 'Account exists with different credentials';
          break;
        case 'invalid-credential':
          message = 'Invalid credentials';
          break;
        default:
          message = 'Google Login Failed: ${e.message}';
      }
      _handleLoginError(message);
    } catch (e) {
      _handleLoginError('An unexpected error occurred: $e');
    }
    setState(() => _isLoading = false);
  }

  void _handleSuccessfulLogin() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Center(child: Text('Welcome Back!'))),
      );
      Navigator.pushReplacementNamed(context, '/MyBottomNavigationBar');
    }
  }

  void _handleLoginError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    SizedBox verticalGap = SizedBox(height: 2.h);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 6.h),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Welcome Back!',
                    style: Theme.of(context).textTheme.displaySmall,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    'Login to continue...',
                    style: Theme.of(context)
                        .textTheme
                        .labelLarge
                        ?.copyWith(color: MyAppColors.primaryColor),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 4.h),
                  _labelText('Email', Theme.of(context).textTheme.labelLarge),
                  SizedBox(height: 1.h),
                  CustomTextFormField(
                    hintText: 'Email',
                    controller: _emailController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      return null;
                    },
                  ),
                  verticalGap,
                  _labelText(
                    'Password',
                    Theme.of(context).textTheme.labelLarge,
                  ),
                  SizedBox(height: 1.h),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscureText,
                    decoration: InputDecoration(
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureText
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                      ),
                      hintText: 'Password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushNamed(
                            context,
                            RouteNames
                                .forgotPasswordPage); // Corrected navigation route
                      },
                      child: Text(
                        'Forgot password?',
                        style: Theme.of(context)
                            .textTheme
                            .labelLarge
                            ?.copyWith(color: MyAppColors.primaryColor),
                      ),
                    ),
                  ),
                  verticalGap,
                  MaterialButton(
                    onPressed: _isLoading
                        ? null
                        : () async {
                            if (_formKey.currentState!.validate()) {
                              await _login();
                            }
                          },
                    color: MyAppColors.primaryColor,
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.035,
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.blue)
                          : Center(
                              child: Text(
                                'Log In',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelLarge
                                    ?.copyWith(color: Colors.white),
                              ),
                            ),
                    ),
                  ),
                  verticalGap,
                  Text(
                    'Or',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  SizedBox(height: 2.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 6.w,
                        width: 6.w,
                        child: Image.asset('assets/icons/google.png'),
                      ),
                      SizedBox(width: 2.w),
                      TextButton(
                        onPressed: _isLoading ? null : _loginWithGoogle,
                        child: Text(
                          'Login with Google',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Don\'t have an account?',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/MySignUpPage');
                        },
                        child: Text(
                          'Sign Up',
                          style: Theme.of(context)
                              .textTheme
                              .labelLarge
                              ?.copyWith(color: MyAppColors.primaryColor),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _labelText(String title, TextStyle? style) => Padding(
        padding: EdgeInsets.symmetric(horizontal: 2.w),
        child: Text(title, style: style),
      );

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
