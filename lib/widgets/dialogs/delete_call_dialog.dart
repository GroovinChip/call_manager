import 'package:call_manager/data_models/call.dart';
import 'package:call_manager/firebase/firebase.dart';
import 'package:flutter/material.dart';

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
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Text('Delete call?'),
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
