import 'dart:io';

import 'package:call_manager/theme/app_colors.dart';
import 'package:call_manager/utils/extensions.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart' as mui;

class ContactAvatar extends StatelessWidget {
  const ContactAvatar({
    Key? key,
    this.contact,
  }) : super(key: key);

  final Contact? contact;
  @override
  Widget build(BuildContext context) {
    if (contact!.avatar == null || contact!.avatar!.isEmpty) {
      return CircleAvatar(
        child: Icon(Icons.person_outline),
      );
    } else {
      return ClipOval(
        child: CircleAvatar(
          child: Image.memory(
            contact!.avatar!,
            gaplessPlayback: true,
          ),
        ),
      );
    }
  }
}
