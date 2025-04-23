import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class MyFirebase {
  static MyFirebase? _instance;

  MyFirebase._internal();

  static MyFirebase getInstance() {
    _instance ??= MyFirebase._internal();
    return _instance!;
  }

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
          "usertype": "general", // default
          "role": "user", // default
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

  Stream<int> countAlertStream() {
    try {
      return FirebaseFirestore.instance
          .collection("alert")
          .snapshots()
          .map((snapshot) => snapshot.docs.length);
    } catch (e) {
      if (kDebugMode) {
        log("Error: $e");
      }
    }
    return Stream.value(0);
  }

  Stream<int> countUsersByType(String type) {
    try {
      return FirebaseFirestore.instance
          .collection("users")
          .where("usertype", isEqualTo: type)
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
