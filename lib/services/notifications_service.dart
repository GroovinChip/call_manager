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
    notificationsPlugin!.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('ic_stat_phone_in_talk'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        ),
      ),
      onDidReceiveNotificationResponse: (response) async {
        if (response.payload != null) {
          log(
            'notification payload: ${response.payload}',
            name: 'Call Manager',
          );
          final dialer = await DirectDialer.instance;
          await dialer.dial(response.payload!);
        }
        //await CallNumber.callNumber(payload);
      },
    );
  }

  FlutterLocalNotificationsPlugin? notificationsPlugin;

  static const _androidPlatformChannelSpecifics = AndroidNotificationDetails(
    '1',
    'Call Reminders',
    channelDescription:
        'Call Manager sends reminders about your calls through this channel.',
  );

  static const _iosPlatformChannelSpecifics = DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
  );

  static const _platformChannelSpecifics = NotificationDetails(
    android: _androidPlatformChannelSpecifics,
    iOS: _iosPlatformChannelSpecifics,
  );

  Future<void> scheduleNotification(Call call, DateTime scheduledDate) async {
    await notificationsPlugin!.zonedSchedule(
      0,
      'Reminder: call ${call.name}',
      'Tap to call ${call.name}',
      tz.TZDateTime.from(scheduledDate, tz.local),
      _platformChannelSpecifics,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.wallClockTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }
}
