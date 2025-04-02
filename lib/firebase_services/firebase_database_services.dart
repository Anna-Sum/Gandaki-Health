import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseDatabaseServices {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static createCollection({
    required String collectionName,
    required Map<String, dynamic> data,
  }) async {
    await _firestore.collection(collectionName).add(data);
  }

  static createCollectionWithCustomDocumentId({
    required String collectionName,
    required String documentId,
    required Map<String, dynamic> data,
  }) async {
    await _firestore.collection(collectionName).doc(documentId).set(data);
  }
}
