import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

mixin FirebaseMixin {
  FirebaseAuth get auth => FirebaseAuth.instance;
  FirebaseFirestore get firestore => FirebaseFirestore.instance;
  User? get currentUser => FirebaseAuth.instance.currentUser;
}