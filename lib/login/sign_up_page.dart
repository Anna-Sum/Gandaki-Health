import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../constants/constant.dart';
import '../customs/app_bar_custom.dart';
import '../customs/text_form_field_custom.dart';
import 'login_services.dart';

class MySignUpPage extends StatefulWidget {
  const MySignUpPage({super.key});

  @override
  State<MySignUpPage> createState() => _MySignUpPageState();
}

class _MySignUpPageState extends State<MySignUpPage> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _midNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Future<void> _signUp() async {
  //   try {
  //     // Create user with email and password
  //     UserCredential userCredential =
  //         await FirebaseAuth.instance.createUserWithEmailAndPassword(
  //       email: _emailController.text.trim(),
  //       password: _passwordController.text.trim(),
  //     );

  //     // Get the user ID
  //     String userId = userCredential.user!.uid;

  //     // Add user details to Firestore
  //     await FirebaseFirestore.instance.collection('users').doc(userId).set({
  //       'firstName': _firstNameController.text.trim(),
  //       'midName': _midNameController.text.trim(),
  //       'lastName': _lastNameController.text.trim(),
  //       'email': _emailController.text.trim(),
  //       'createdAt': Timestamp.now(),
  //     });

  //     // Navigate to another screen or show a success message
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Sign up successful!')),
  //     );
  //   } on FirebaseAuthException catch (e) {
  //     // Handle errors
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Error: ${e.message}')),
  //     );
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Sign Up'),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text('First Name'),
            SizedBox(
              width: MediaQuery.of(context).size.width / 2,
              child: CustomTextFormField(
                hintText: 'First Name',
                controller: _firstNameController,
              ),
            ),
            const SizedBox(
              height: 30.0,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width / 2,
              child: CustomTextFormField(
                hintText: 'Mid Name',
                controller: _midNameController,
              ),
            ),
            const SizedBox(
              height: 30.0,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width / 2,
              child: CustomTextFormField(
                hintText: 'Last Name',
                controller: _lastNameController,
              ),
            ),
            const SizedBox(
              height: 30.0,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width / 2,
              child: CustomTextFormField(
                hintText: 'Email',
                controller: _emailController,
              ),
            ),
            const SizedBox(
              height: 30.0,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width / 2,
              child: CustomTextFormField(
                hintText: 'Password',
                controller: _passwordController,
              ),
            ),
            const SizedBox(
              height: 30.0,
            ),
            MaterialButton(
              // onPressed: _signUp,
              onPressed: () async {
                LoginSignInServices().signUp(
                  email: _emailController.text.trim(),
                  password: _passwordController.text.trim(),
                );
              },
              color: MyAppColors.primaryColor,
              padding: EdgeInsets.symmetric(vertical: 2.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'create',
                style: Theme.of(context)
                    .textTheme
                    .labelLarge
                    ?.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* 
class NewUserService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /* ...sign up with email and password... */
  Future<User?> signUpWithEmailAndPassword({
    required String firstName,
    required String midName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      log('Error Occured : $e');
    }
    return null;
  }

  /* ...sign in with email and password... */
  Future<User?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return userCredential.user;
    } catch (e) {
      log('Error occured : $e');
    }
    return null;
  }

  /* ...put new user's data inside 'users' collection ...
   data: [ firstName, midName, lastName, email ]
  */
  void putNewUserDetailsInUsersCollection({
    required String firstName,
    required String midName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    User? user = await signUpWithEmailAndPassword(
      firstName: firstName,
      midName: midName,
      lastName: lastName,
      email: email,
      password: password,
    );

    if (user != null) {
      log('Successfully Created New User Account.');
      try {
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'first_name': firstName,
          'mid_name': midName,
          'last_name': lastName,
          'email': email,
        });
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(builder: (context) => const MyHomePage()),
        // );
      } catch (e) {
        log("$e");
      }
    } else {
      log('New User Account Creation Failed.');
    }
  }

  /* ...extract uid of logged user... */
  Future<String?> getLoggedUserUid() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        return user.uid;
      }
    } catch (e) {
      log('Error occured : $e');
    }
    return null;
  }
} */
