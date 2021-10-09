import 'package:call_manager/widgets/contact_avatar.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';

class ContactTile extends StatelessWidget {
  const ContactTile({
    Key? key,
    required this.contact,
  }) : super(key: key);

  final Contact contact;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: ContactAvatar(contact: contact),
      title: Text(contact.displayName!),
    );
  }
}

