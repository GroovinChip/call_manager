import 'package:call_manager/data_models/call.dart';
import 'package:call_manager/firebase/firebase.dart';
import 'package:flutter/material.dart';

class CompleteCallDialog extends StatefulWidget {
  const CompleteCallDialog({
    Key? key,
    required this.call,
  }) : super(key: key);

  final Call call;
  @override
  _CompleteCallDialogState createState() => _CompleteCallDialogState();
}

class _CompleteCallDialogState extends State<CompleteCallDialog>
    with FirebaseMixin {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Text('Mark this call as completed?'),
      actions: [
        TextButton(
          child: Text('CANCEL'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          child: Text('YES'),
          onPressed: () {
            firestore.completeCall(widget.call);
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
