import 'package:call_manager/app.dart';
import 'package:call_manager/services/contacts_utility.dart';
import 'package:call_manager/services/notifications_service.dart';
import 'package:call_manager/services/phone_utility.dart';
import 'package:call_manager/services/prefs_service.dart';
import 'package:call_manager/utils/pass_notification.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  final prefsService = await PrefsService.init();
  final contactsUtility = await ContactsUtility.init();
  final phoneUtility = await PhoneUtility.init();
  final notificationService = await NotificationService.init();

  // launch app
  runApp(
    PassNotification(
      notificationService.notificationsPlugin,
      child: CallManagerApp(
        prefsService: prefsService,
        contactsUtility: contactsUtility,
        phoneUtility: phoneUtility,
        notificationService: notificationService,
      ),
    ),
  );
}
