import 'dart:io';

import 'package:call_manager/data_models/call.dart';
import 'package:call_manager/firebase/firebase.dart';
import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';

class DeleteCallDialog extends StatefulWidget {
  const DeleteCallDialog({
    Key? key,
    required this.call,
  }) : super(key: key);

  final Call call;
  @override
  _DeleteCallDialogState createState() => _DeleteCallDialogState();
}

class _DeleteCallDialogState extends State<DeleteCallDialog>
    with FirebaseMixin {
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
        'Delete call?',
        style: TextStyle(
          color: textColor,
        ),
      ),
      actions: [
        TextButton(
          child: Text('CANCEL'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          child: Text('YES'),
          onPressed: () {
            firestore.deleteCall(widget.call);
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
