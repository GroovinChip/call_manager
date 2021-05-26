import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:call_manager/apps/mac_app.dart';
import 'package:call_manager/apps/mobile_app.dart';
import 'package:call_manager/services/contacts_utility.dart';
import 'package:call_manager/services/notifications_service.dart';
import 'package:call_manager/services/phone_utility.dart';
import 'package:call_manager/services/prefs_service.dart';
import 'package:call_manager/utils/pass_notification.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in_dartio/google_sign_in_dartio.dart';

Future<void> main() async {
  if (Platform.isMacOS) {
    await GoogleSignInDart.register(
        clientId:
            '1053316160376-pnm7kudrjkav6ijoe221lj67a2ubsnf9.apps.googleusercontent.com');
  }
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  final prefsService = await PrefsService.init();
  final contactsUtility = await ContactsUtility.init();
  final phoneUtility = await PhoneUtility.init();
  final notificationService = await NotificationService.init();

  // launch app
  if (Platform.isMacOS) {
    // launch macosApp
    runApp(
      PassNotification(
        notificationService.notificationsPlugin,
        child: MacApp(
          notificationService: notificationService,
          prefsService: prefsService,
          phoneUtility: phoneUtility,
          contactsUtility: contactsUtility,
        ),
      ),
    );

    doWhenWindowReady(() {
      appWindow.show();
    });
  } else {
    runApp(
      PassNotification(
        notificationService.notificationsPlugin,
        child: MobileApp(
          prefsService: prefsService,
          contactsUtility: contactsUtility,
          phoneUtility: phoneUtility,
          notificationService: notificationService,
        ),
      ),
    );
  }
}
