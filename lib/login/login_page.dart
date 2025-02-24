import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';

import '../constants/constant.dart';
import '../customs/text_form_field_custom.dart';
import '../hive/hive_initialization.dart';
import '../pages/bottom_navigation_bar/bottom_navigation_bar.dart';
import 'sign_up_page.dart';

final authProvider = Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);

class MyLoginPage extends ConsumerStatefulWidget {
  const MyLoginPage({super.key});

  @override
  ConsumerState<MyLoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<MyLoginPage> {
  final _formKey = GlobalKey<FormState>();
  MyHiveService myHiveService = MyHiveService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailController.text = 'bishal@gmail.com';
    _passwordController.text = '123456';
  }

  Future<void> _login(context) async {
    setState(() => _isLoading = true);
    final auth = ref.read(authProvider);

    try {
      await auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Center(child: Text('Welcome Back!'))),
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MyBottomNavigationBar(),
        ),
      );

      myHiveService.putData(
          boxName: 'userCredential',
          key: 'email',
          value: _passwordController.text);
      myHiveService.putData(
          boxName: 'userCredential',
          key: 'password',
          value: _passwordController.text);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login Failed: $e')),
      );
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    SizedBox verticalGap = SizedBox(height: 2.h);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 6.w),
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
                labelText('Email', Theme.of(context).textTheme.labelLarge),
                SizedBox(height: 1.h),
                CustomTextFormField(
                  hintText: 'Email',
                  controller: _emailController,
                ),
                verticalGap,
                labelText('Password', Theme.of(context).textTheme.labelLarge),
                SizedBox(height: 1.h),
                CustomTextFormField(
                  hintText: 'password',
                  controller: _passwordController,
                  obscureText: true,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
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
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      _login(context);
                    }
                  },
                  color: MyAppColors.primaryColor,
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _isLoading ? '...' : 'Log In',
                    style: Theme.of(context)
                        .textTheme
                        .labelLarge
                        ?.copyWith(color: Colors.white),
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
                      child: Image.asset(
                        'assets/icons/google.png',
                      ),
                    ),
                    SizedBox(width: 2.w),
                    TextButton(
                      onPressed: () {},
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const MySignUpPage()),
                          );
                        },
                        child: Text(
                          'Sign Up',
                          style: Theme.of(context)
                              .textTheme
                              .labelLarge
                              ?.copyWith(color: MyAppColors.primaryColor),
                        ))
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget labelText(String title, TextStyle? style) => Padding(
        padding: EdgeInsets.symmetric(horizontal: 2.w),
        child: Text(
          title,
          style: style,
        ),
      );
}
