import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseDatabaseServices {
  //create new collection with default document id...
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static createCollection({
    required String collectionName,
    required Map<String, dynamic> data,
  }) async {
    await _firestore.collection(collectionName).add(data);
  }

  //create new collection with custom document id...
  static createCollectionWithCustomDocumentId({
    required String collectionName,
    required String documentId,
    required Map<String, dynamic> data,
  }) async {
    await _firestore.collection(collectionName).doc(documentId).set(data);
  }
}

// class FirebaseAuthService {
//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   Future<User?> signInWithEmailAndPassword(
//       {required String email, required String password}) async {
//     try {
//       UserCredential userCredential = await _auth.signInWithEmailAndPassword(
//           email: email, password: password);

//       return userCredential.user;
//     } catch (e) {
//       log('Error: $e');
//       return null;
//     }
//   }
// }
