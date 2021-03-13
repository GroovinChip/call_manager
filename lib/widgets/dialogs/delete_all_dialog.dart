import 'package:call_manager/firebase/firebase_mixin.dart';
import 'package:flutter/material.dart';

class DeleteAllDialog extends StatefulWidget {
  DeleteAllDialog({Key key}) : super(key: key);

  @override
  _DeleteAllDialogState createState() => _DeleteAllDialogState();
}

class _DeleteAllDialogState extends State<DeleteAllDialog>
    with FirebaseMixin {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Text(
          'Are you sure you want to delete all calls? This cannot be undone.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('CANCEL'),
        ),
        TextButton(
          onPressed: () async {
            Navigator.of(context).pop();
            final callsRef = firestore
                .collection('Users')
                .doc(currentUser.uid)
                .collection('Calls');
            final callSnapshots = await callsRef.get();
            if (callSnapshots.docs.length == 0) {
              final snackBar = SnackBar(
                content: Text('There are no calls to delete'),
                action: SnackBarAction(
                  label: 'Dismiss',
                  onPressed: () {},
                ),
                duration: Duration(seconds: 3),
              );
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            } else {
              for (int i = 0; i < callSnapshots.docs.length; i++) {
                callSnapshots.docs[i].reference.delete();
              }
            }
          },
          child: Text('DELETE'),
        ),
      ],
    );
  }
}
