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
  var initializationSettingsAndroid = new AndroidInitializationSettings('ic_notification');
  var initializationSettingsIOS = new IOSInitializationSettings();
  var initializationSettings = new InitializationSettings(
      initializationSettingsAndroid, initializationSettingsIOS);
  var flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
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



  runApp(
    LNP(
      flutterLocalNotificationsPlugin,
      child: CallManagerApp(),
    )
  );
}

class CallManagerApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Call Manager',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
        canvasColor: Colors.transparent,
        fontFamily: 'SourceSansPro-Bold',
      ),
      home: new LoginPage(),
      routes: <String, WidgetBuilder>{
        "/HomeScreen": (BuildContext context) => new HomeScreen(),
        "/AddNewCallScreen": (BuildContext context) => new AddNewCallScreen(),
        "/EditCallScreen": (BuildContext context) => new EditCallScreen(),
        "/AboutScreen": (BuildContext context) => new AboutScreen()
      },
      debugShowCheckedModeBanner: false,
    );
  }
}