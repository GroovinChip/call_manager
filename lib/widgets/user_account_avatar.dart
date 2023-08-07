import 'package:call_manager/firebase/firebase_mixin.dart';
import 'package:flutter/material.dart';

class UserAccountAvatar extends StatefulWidget {
  const UserAccountAvatar({Key? key}) : super(key: key);

  @override
  State<UserAccountAvatar> createState() => _UserAccountAvatarState();
}

class _UserAccountAvatarState extends State<UserAccountAvatar>
    with FirebaseMixin {
  @override
  Widget build(BuildContext context) {
    if (currentUser == null || currentUser!.photoURL == null) {
      return CircleAvatar(
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(
          Icons.person_outline,
          color: Colors.white,
        ),
      );
    }

    return CircleAvatar(
      backgroundImage: NetworkImage(currentUser!.photoURL!),
      backgroundColor: Theme.of(context).primaryColor,
    );
  }
}
