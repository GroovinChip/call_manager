import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LNP extends InheritedWidget {
  final FlutterLocalNotificationsPlugin instance;

  LNP(this.instance, {Widget child}) : super(child: child);

  static FlutterLocalNotificationsPlugin of(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(LNP) as LNP).instance;
  }

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) {
    return false;
  }
}