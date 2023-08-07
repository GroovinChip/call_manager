import 'package:call_manager/firebase/firebase.dart';
import 'package:flutter/material.dart';

class DeleteAllDialog extends StatefulWidget {
  const DeleteAllDialog({Key? key}) : super(key: key);

  @override
  State<DeleteAllDialog> createState() => _DeleteAllDialogState();
}

class _DeleteAllDialogState extends State<DeleteAllDialog> with FirebaseMixin {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: const Text(
        'Are you sure you want to delete all calls? This cannot be undone.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('CANCEL'),
        ),
        TextButton(
          onPressed: () async {
            Navigator.of(context).pop();

            final result = await firestore.deleteAllCalls();

            if (mounted && result == false) {
              final snackBar = SnackBar(
                content: const Text('There are no calls to delete'),
                action: SnackBarAction(
                  label: 'Dismiss',
                  // ignore: no-empty-block
                  onPressed: () {},
                ),
                duration: const Duration(seconds: 3),
              );
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            }
          },
          child: const Text('DELETE'),
        ),
      ],
    );
  }
}
