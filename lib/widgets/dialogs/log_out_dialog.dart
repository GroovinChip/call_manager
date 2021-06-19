import 'package:call_manager/firebase/firebase_mixin.dart';
import 'package:call_manager/screens/login_screen.dart';
import 'package:flutter/material.dart';

class LogOutDialog extends StatefulWidget {
  const LogOutDialog({Key? key}) : super(key: key);

  @override
  _LogOutDialogState createState() => _LogOutDialogState();
}

class _LogOutDialogState extends State<LogOutDialog> with FirebaseMixin {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      //title: Text('Log Out'),
      content: const Text('Are you sure you want to log out?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('NO'),
        ),
        TextButton(
          onPressed: () async {
            await auth.signOut();
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => const LoginScreen(),
              ),
              (route) => false,
            );
          },
          child: const Text('YES'),
        ),
      ],
    );
  }
}
