import 'package:cloud_firestore/cloud_firestore.dart';

extension FirestoreX on FirebaseFirestore {
  CollectionReference<Map<String, dynamic>> get users =>
      this.collection('Users');
  CollectionReference<Map<String, dynamic>> upcomingCalls(String uid) =>
      users.doc('$uid').collection('Calls');
  CollectionReference<Map<String, dynamic>> completedCalls(String uid) =>
      users.doc('$uid').collection('CompletedCalls');

  void initStorageForUser(String uid) {
    if (users.doc(uid).path.isEmpty) {
      users.doc(uid).set({});
    }
  }
}
