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
  State<DeleteCallDialog> createState() => _DeleteCallDialogState();
}

class _DeleteCallDialogState extends State<DeleteCallDialog>
    with FirebaseMixin {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: const Text('Delete call?'),
      actions: [
        TextButton(
          child: const Text('CANCEL'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          child: const Text('YES'),
          onPressed: () {
            firestore.deleteCall(widget.call);
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
