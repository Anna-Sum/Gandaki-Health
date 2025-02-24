import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class MyFirebase {
  /// *** Singleton  ***
  static MyFirebase? _instance;

  MyFirebase._internal();

  static MyFirebase getInstance() {
    _instance ??= MyFirebase._internal();
    return _instance!;
  }

  /// *** Firebase  ***
  /// Register a new user and store inside a 'users' collection
  Future<void> registerUser(String email, String password, String name) async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;

      if (user != null) {
        await FirebaseFirestore.instance.collection("users").doc(user.uid).set({
          "uid": user.uid,
          "name": name,
          "email": email,
          "createdAt": FieldValue.serverTimestamp(),
        });

        log("User registered and data stored successfully!");
      }
    } catch (e) {
      if (kDebugMode) {
        log("Error: $e");
      }
    }
  }

  /// count total users in the 'users' collection
  Stream<int> countUserStream() {
    try {
      return FirebaseFirestore.instance
          .collection("users")
          .snapshots()
          .map((snapshot) => snapshot.docs.length);
    } catch (e) {
      if (kDebugMode) {
        log("Error: $e");
      }
    }
    return Stream.value(0);
  }
}

MyFirebase myFirebase = MyFirebase.getInstance();
