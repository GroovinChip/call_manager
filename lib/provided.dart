import 'package:call_manager/services/contacts_utility.dart';
import 'package:call_manager/services/notifications_service.dart';
import 'package:call_manager/services/phone_utility.dart';
import 'package:call_manager/services/prefs_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

mixin Provided<T extends StatefulWidget> on State<T> {
  PrefsService _prefsService;
  ContactsUtility _contactsUtility;
  PhoneUtility _phoneUtility;
  NotificationService _notificationService;

  PrefsService get prefsService =>
      _prefsService ??= Provider.of<PrefsService>(context, listen: false);
  ContactsUtility get contactsUtility =>
      _contactsUtility ??= Provider.of<ContactsUtility>(context, listen: false);
  PhoneUtility get phoneUtility =>
      _phoneUtility ??= Provider.of<PhoneUtility>(context, listen: false);
  NotificationService get notificationService => _notificationService ??=
      Provider.of<NotificationService>(context, listen: false);
}
