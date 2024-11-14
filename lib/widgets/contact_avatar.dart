import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter/material.dart';

class ContactAvatar extends StatelessWidget {
  const ContactAvatar({
    super.key,
    this.contact,
  });

  final Contact? contact;
  
  @override
  Widget build(BuildContext context) {
    if (contact!.photo == null || contact!.photo!.isEmpty) {
      return const CircleAvatar(
        child: Icon(Icons.person_outline),
      );
    } else {
      return ClipOval(
        child: CircleAvatar(
          child: Image.memory(
            contact!.photo!,
            gaplessPlayback: true,
          ),
        ),
      );
    }
  }
}
