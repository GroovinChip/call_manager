import 'package:call_manager/aboutScreen.dart';
import 'package:call_manager/editCallScreen.dart';
import 'package:call_manager/lnp.dart';
import 'package:call_manager/loginPage.dart';
import 'package:call_number/call_number.dart';
import 'package:flutter/material.dart';
import 'package:call_manager/HomeScreen.dart';
import 'package:call_manager/AddNewCallScreen.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

void main() {
  // Initialize notification plugin
  var initializationSettingsAndroid = AndroidInitializationSettings('ic_notification');
  var initializationSettingsIOS = IOSInitializationSettings();
  var initializationSettings = InitializationSettings(
      initializationSettingsAndroid, initializationSettingsIOS);
  var flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
      selectNotification: (String payload) async {
        if (payload != null) {
          debugPrint('notification payload: ' + payload);
        }
        //launch("tel:"+payload);
        await CallNumber().callNumber(payload);
      }
    );

  // launch app
  runApp(
    LNP( // LNP is an inherited widget which passes on the notifications plugin
      flutterLocalNotificationsPlugin,
      child: CallManagerApp(),
    )
  );
}

class CallManagerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Call Manager',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        canvasColor: Colors.transparent,
        fontFamily: 'SourceSansPro-Bold',
      ),
      home: LoginPage(),
      routes: <String, WidgetBuilder>{
        "/HomeScreen": (BuildContext context) => HomeScreen(),
        "/AddNewCallScreen": (BuildContext context) => AddNewCallScreen(),
        "/EditCallScreen": (BuildContext context) => EditCallScreen(),
        "/AboutScreen": (BuildContext context) => AboutScreen()
      },
      debugShowCheckedModeBanner: false,
    );
  }
}