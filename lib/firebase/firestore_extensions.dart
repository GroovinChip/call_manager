import 'package:cloud_firestore/cloud_firestore.dart';

extension FirestoreX on FirebaseFirestore {
  CollectionReference users() => this.collection('Users');
  CollectionReference calls(String uid) =>
      users().doc('$uid').collection('Calls');

  void initStorageForUser(String uid) {
    if (users().doc(uid).path.isEmpty) {
      users().doc(uid).set({});
    }
  }
}
