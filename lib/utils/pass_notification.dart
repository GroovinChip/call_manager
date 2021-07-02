import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// This class is an InheritedWidget that passes along the
/// notification plugin to the rest of the app. The purpose of this is so that
/// when the notification is tapped, the payload from the notification runs.
class PassNotification extends InheritedWidget {
  const PassNotification(
    this.instance, {
    Key? key,
    required Widget child,
  }) : super(key: key, child: child);

  final FlutterLocalNotificationsPlugin? instance;

  static FlutterLocalNotificationsPlugin? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<PassNotification>()!
        .instance;
  }

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) {
    return false;
  }
}
