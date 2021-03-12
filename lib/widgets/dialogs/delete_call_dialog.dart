import 'package:call_manager/firebase/firebase.dart';
import 'package:flutter/material.dart';

class DeleteCallDialog extends StatefulWidget {
  const DeleteCallDialog({
    Key key,
    @required this.callId,
  }) : super(key: key);

  final String callId;
  @override
  _DeleteCallDialogState createState() => _DeleteCallDialogState();
}

class _DeleteCallDialogState extends State<DeleteCallDialog>
    with FirebaseMixin {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Text('Are you sure you want to delete this call?'),
      actions: [
        TextButton(
          child: Text('CANCEL'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          child: Text('DELETE'),
          onPressed: () {
            firestore.calls(currentUser.uid).doc(widget.callId).delete();
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
