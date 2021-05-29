import 'dart:io';

import 'package:call_manager/firebase/firebase.dart';
import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';

class DeleteAllDialog extends StatefulWidget {
  DeleteAllDialog({Key? key}) : super(key: key);

  @override
  _DeleteAllDialogState createState() => _DeleteAllDialogState();
}

class _DeleteAllDialogState extends State<DeleteAllDialog> with FirebaseMixin {
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
        'Are you sure you want to delete all calls? This cannot be undone.',
        style: TextStyle(
          color: textColor,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('CANCEL'),
        ),
        TextButton(
          onPressed: () async {
            Navigator.of(context).pop();

            final result = await firestore.deleteAllCalls();

            if (result == false) {
              final snackBar = SnackBar(
                content: Text('There are no calls to delete'),
                action: SnackBarAction(
                  label: 'Dismiss',
                  // ignore: no-empty-block
                  onPressed: () {},
                ),
                duration: Duration(seconds: 3),
              );
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            }
          },
          child: Text('DELETE'),
        ),
      ],
    );
  }
}
