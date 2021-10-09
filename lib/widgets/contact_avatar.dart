import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';

class ContactAvatar extends StatelessWidget {
  const ContactAvatar({
    Key? key,
    this.contact,
  }) : super(key: key);

  final Contact? contact;
  @override
  Widget build(BuildContext context) {
    if (contact!.avatar == null || contact!.avatar!.isEmpty) {
      return const CircleAvatar(
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
