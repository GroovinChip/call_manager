import 'package:call_manager/data_models/call.dart';
import 'package:call_manager/firebase/firebase.dart';
import 'package:flutter/material.dart';

class MarkIncompleteDialog extends StatefulWidget {
  const MarkIncompleteDialog({
    Key? key,
    required this.call,
  }) : super(key: key);

  final Call call;
  @override
  _MarkIncompleteDialogState createState() => _MarkIncompleteDialogState();
}

class _MarkIncompleteDialogState extends State<MarkIncompleteDialog>
    with FirebaseMixin {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Text('Mark this call as incomplete?'),
      actions: [
        TextButton(
          child: Text('CANCEL'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          child: Text('YES'),
          onPressed: () {
            firestore.incompleteCall(widget.call);
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
