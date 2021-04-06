import 'package:call_manager/firebase/firebase_mixin.dart';
import 'package:flutter/material.dart';

class UserAccountAvatar extends StatefulWidget {
  @override
  _UserAccountAvatarState createState() => _UserAccountAvatarState();
}

class _UserAccountAvatarState extends State<UserAccountAvatar>
    with FirebaseMixin {
  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      CircleAvatar(
        child: Icon(Icons.person_outline),
        backgroundColor: Theme.of(context).primaryColor,
      );
    }

    return CircleAvatar(
      backgroundImage: NetworkImage(currentUser!.photoURL!),
      backgroundColor: Theme.of(context).primaryColor,
    );
  }
}
