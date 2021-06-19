import 'dart:typed_data';

import 'package:call_manager/data_models/call.dart';
import 'package:flutter/material.dart';

class CallAvatar extends StatelessWidget {
  const CallAvatar({
    Key? key,
    required this.call,
  }) : super(key: key);

  final Call call;

  @override
  Widget build(BuildContext context) {
    if (call.hasAvatar) {
      return ClipOval(
        child: CircleAvatar(
          child: Image.memory(
            Uint8List.fromList(call.avatar!.codeUnits),
            gaplessPlayback: true,
          ),
        ),
      );
    } else {
      return CircleAvatar(
        child: const Icon(
          Icons.person_outline,
          color: Colors.white,
        ),
        backgroundColor: Theme.of(context).primaryColor,
      );
    }
  }
}
