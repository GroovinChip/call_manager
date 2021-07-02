import 'firebase.dart';

mixin FirebaseMixin {
  FirebaseAuth get auth => FirebaseAuth.instance;
  FirebaseFirestore get firestore => FirebaseFirestore.instance;
  User? get currentUser => FirebaseAuth.instance.currentUser;
}
