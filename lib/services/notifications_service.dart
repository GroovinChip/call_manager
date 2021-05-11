import 'dart:developer';

import 'package:call_manager/data_models/call.dart';
import 'package:direct_dialer/direct_dialer.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();

  static Future<NotificationService> init() async {
    final service = NotificationService._();
    await service._init();

    return service;
  }

  Future<void> _init() async {
    tz.initializeTimeZones();
    notificationsPlugin = FlutterLocalNotificationsPlugin();
    final androidInitializationSettings =
        AndroidInitializationSettings('ic_notification');
    final iosInitializationSettings = IOSInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    notificationsPlugin!.initialize(
      InitializationSettings(
        android: androidInitializationSettings,
        iOS: iosInitializationSettings,
      ),
      onSelectNotification: (String? payload) async {
        if (payload != null) {
          log('notification payload: ' + payload, name: 'Call Manager');
          final dialer = await DirectDialer.instance;
          await dialer.dial(payload);
        }
        //await CallNumber.callNumber(payload);
      },
    );
  }

  FlutterLocalNotificationsPlugin? notificationsPlugin;

  static const _androidPlatformChannelSpecifics = AndroidNotificationDetails(
    '1',
    'Call Reminders',
    'Call Manager sends reminders about your calls through this channel.',
  );

  static const _iosPlatformChannelSpecifics = IOSNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
  );

  static const _platformChannelSpecifics = NotificationDetails(
    android: _androidPlatformChannelSpecifics,
    iOS: _iosPlatformChannelSpecifics,
  );

  Future<void> scheduleNotification(Call call, DateTime scheduledDate) async {
    print(tz.local);
    await notificationsPlugin!.zonedSchedule(
      0,
      'Reminder: call ${call.name}',
      'Tap to call ${call.name}',
      tz.TZDateTime.from(scheduledDate, tz.local),
      _platformChannelSpecifics,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.wallClockTime,
      androidAllowWhileIdle: true,
    );
  }
}
