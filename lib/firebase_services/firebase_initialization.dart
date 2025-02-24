import 'package:firebase_core/firebase_core.dart';

class MyFirebaseInitialization {
  //initializating firebase...
  static Future<FirebaseApp> firebaseInitialization() async {
    return await Firebase.initializeApp();
  }
}
