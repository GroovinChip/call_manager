import 'dart:io';

import 'package:call_manager/firebase/firebase_mixin.dart';
import 'package:call_manager/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';

class LogOutDialog extends StatefulWidget {
  LogOutDialog({Key? key}) : super(key: key);

  @override
  _LogOutDialogState createState() => _LogOutDialogState();
}

class _LogOutDialogState extends State<LogOutDialog> with FirebaseMixin {
  Color? backgroundColor;
  Color? textColor;

  @override
  Widget build(BuildContext context) {
    if (Platform.isMacOS) {
      backgroundColor = MacosTheme.of(context).canvasColor;
      textColor =
          MacosTheme.brightnessOf(context).isDark ? Colors.white : Colors.black;
    } else {
      backgroundColor = Theme.of(context).canvasColor;
      textColor = Theme.of(context).brightness == Brightness.dark
          ? Colors.white
          : Colors.black;
    }

    return AlertDialog(
      backgroundColor: backgroundColor,
      content: Text(
        'Are you sure you want to log out?',
        style: TextStyle(
          color: textColor,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('NO'),
        ),
        TextButton(
          onPressed: () async {
            await auth.signOut();
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => LoginScreen(),
              ),
              (route) => false,
            );
          },
          child: Text('YES'),
        ),
      ],
    );
  }
}
