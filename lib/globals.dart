library call_manager.globals;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// represents the current user
User loggedInUser;
// represents the call in the database that is being selected for editing
DocumentReference callToEdit;