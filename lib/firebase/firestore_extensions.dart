import 'package:call_manager/data_models/call.dart';
import 'package:call_manager/firebase/fb_type_aliases.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

extension FirestoreX on FirebaseFirestore {
  FirestoreCollection get users => this.collection('Users');
  FirestoreCollection get upcomingCalls => users
      .doc('${FirebaseAuth.instance.currentUser!.uid}')
      .collection('Calls');
  FirestoreCollection get completedCalls => users
      .doc('${FirebaseAuth.instance.currentUser!.uid}')
      .collection('CompletedCalls');

  /// Marks a call as complete and moves it to [completedCalls]
  Future<void> completeCall(Call call) async {
    final completedAt = DateTime.now().toString();
    call.completedAt = completedAt;
    await completedCalls.doc(call.id).set(call.toJson());
    await upcomingCalls.doc(call.id).delete();
  }

  /// Marks a call as incomplete and moves it to [upcomingCalls]
  Future<void> incompleteCall(Call call) async {
    call.completedAt = null;
    await upcomingCalls.doc(call.id).set(call.toJson());
    await completedCalls.doc(call.id).delete();
  }

  Future<void> deleteCall(Call call) async {
    if (call.isCompleted) {
      await completedCalls.doc(call.id).delete();
    } else {
      await upcomingCalls.doc(call.id).delete();
    }
  }

  void initStorageForUser(String uid) {
    if (users.doc(uid).path.isEmpty) {
      users.doc(uid).set({});
    }
  }
}
