import 'package:firebase_core/firebase_core.dart';

class MyFirebaseInitialization {
  static Future<FirebaseApp> firebaseInitialization() async {
    return await Firebase.initializeApp();
  }
}
