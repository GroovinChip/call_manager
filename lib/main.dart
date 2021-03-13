import 'package:call_manager/app.dart';
import 'package:call_manager/services/contacts_utility.dart';
import 'package:call_manager/services/phone_utility.dart';
import 'package:call_manager/services/prefs_service.dart';
import 'package:call_manager/utils/pass_notification.dart';
import 'package:call_number/call_number.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  final prefsService = await PrefsService.init();
  final contactsUtility = await ContactsUtility.init();
  final phoneUtility = await PhoneUtility.init();

  // Initialize notification plugin
  final androidInitializationSettings =
      AndroidInitializationSettings('ic_notification');
  final iosInitializationSettings = IOSInitializationSettings();
  final initializationSettings = InitializationSettings(
    android: androidInitializationSettings,
    iOS: iosInitializationSettings,
  );
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onSelectNotification: (String payload) async {
      if (payload != null) {
        debugPrint('notification payload: ' + payload);
      }
      await CallNumber.callNumber(payload);
    },
  );

  // launch app
  runApp(
    PassNotification(
      flutterLocalNotificationsPlugin,
      child: CallManagerApp(
        prefsService: prefsService,
        contactsUtility: contactsUtility,
        phoneUtility: phoneUtility,
      ),
    ),
  );
}
