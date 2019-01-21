import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class PassNotification extends InheritedWidget {
  final FlutterLocalNotificationsPlugin instance;

  PassNotification(this.instance, {Widget child}) : super(child: child);

  static FlutterLocalNotificationsPlugin of(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(PassNotification) as PassNotification).instance;
  }

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) {
    return false;
  }
}