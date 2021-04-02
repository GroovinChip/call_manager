import 'dart:async';

import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rxdart/rxdart.dart';

class ContactsUtility {
  ContactsUtility._();

  static Future<ContactsUtility> init() async {
    final service = ContactsUtility._();
    await service._init();

    return service;
  }

  // Get initial permission state, add to stream. There will always be
  // an initial permission state this way.
  Future<void> _init() async {
    var status = await Permission.contacts.status;
    contactsPermissionSubject.add(status);
    if (status.isGranted) {
      getContacts();
    }
  }

  // Used to determine whether to show a TypeAheadFormField or a TextFormField
  // for NewCallScreen and EditCallScreen
  Iterable<Contact> contacts;
  final contactsPermissionSubject = BehaviorSubject<PermissionStatus>();
  PermissionStatus get permissionStatus => contactsPermissionSubject.value;

  // Used to actually ask the user for permission
  void requestPermission() {
    Permission.contacts.status.then((status) {
      if (status.isDenied) {
        Permission.contacts.request().then((value) {
          if (value.isGranted) {
            contactsPermissionSubject.add(value);
            getContacts();
          }
        });
      }
    });
  }

  void getContacts() {
    ContactsService.getContacts().then((value) {
      contacts = value;
    });
  }

  FutureOr<Iterable> searchContactsWithQuery(query) {
    if (contacts != null) {
      return contacts
          .where((contact) =>
              contact.displayName != null &&
              contact.displayName.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }

    return [];
  }
}
