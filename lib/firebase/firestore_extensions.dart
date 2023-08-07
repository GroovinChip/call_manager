import 'package:call_manager/data_models/call.dart';
import 'package:call_manager/firebase/fb_type_aliases.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

extension FirestoreX on FirebaseFirestore {
  FirestoreCollection get users => collection('Users');
  FirestoreCollection get upcomingCalls =>
      users.doc(FirebaseAuth.instance.currentUser!.uid).collection('Calls');
  FirestoreCollection get completedCalls => users
      .doc(FirebaseAuth.instance.currentUser!.uid)
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

  /// Deletes one call
  Future<void> deleteCall(Call call) async {
    if (!call.isNotCompleted) {
      await completedCalls.doc(call.id).delete();
    } else {
      await upcomingCalls.doc(call.id).delete();
    }
  }

  /// Deletes all calls
  Future<dynamic> deleteAllCalls() async {
    final upcomingCallsResult = await upcomingCalls.get();
    final completedCallsResult = await completedCalls.get();
    if (upcomingCallsResult.docs.isEmpty && completedCallsResult.docs.isEmpty) {
      return false;
    }
    if (upcomingCallsResult.docs.isNotEmpty) {
      for (int i = 0; i < upcomingCallsResult.docs.length; i++) {
        upcomingCallsResult.docs[i].reference.delete();
      }
    }
    if (completedCallsResult.docs.isNotEmpty) {
      for (int i = 0; i < completedCallsResult.docs.length; i++) {
        completedCallsResult.docs[i].reference.delete();
      }
    }
  }

  void initStorageForUser(String uid) {
    if (users.doc(uid).path.isEmpty) {
      users.doc(uid).set({});
    }
  }

  void recordLoginDate(String uid) {
    users.doc(uid).update({
      'last login date': DateTime.now().toIso8601String(),
    });
  }

  void recordLoginWithGoogle(String uid) {
    users.doc(uid).update({
      'last login with Google': DateTime.now().toIso8601String(),
    });
  }

  void recordLoginWithApple(String uid) {
    users.doc(uid).update({
      'last login with Apple': DateTime.now().toIso8601String(),
    });
  }

  void recordLogout(String uid) {
    users.doc(uid).update({
      'last logout date': DateTime.now().toIso8601String(),
    });
  }
}
