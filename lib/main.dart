import 'package:call_manager/about_screen.dart';
import 'package:call_manager/edit_call_screen.dart';
import 'package:call_manager/pass_notification.dart';
import 'package:call_manager/login_screen.dart';
import 'package:call_number/call_number.dart';
import 'package:flutter/material.dart';
import 'package:call_manager/home_screen.dart';
import 'package:call_manager/add_new_call_screen.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:dynamic_theme/dynamic_theme.dart';

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
    PassNotification( // PassNotification is an inherited widget which passes on the notifications plugin
      flutterLocalNotificationsPlugin,
      child: CallManagerApp(),
    )
  );
}

class CallManagerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DynamicTheme(
      defaultBrightness: Brightness.light,
      data: (brightness) => ThemeData(
        brightness: brightness,
        primaryColor: Colors.blue[700],
        accentColor: Colors.blue[700],
        fontFamily: 'SourceSansPro-Bold',
      ),
      themedWidgetBuilder: (context, theme) {
        return MaterialApp(
          title: 'Call Manager',
          theme: theme,
          home: LoginPage(),
          routes: <String, WidgetBuilder>{
            "/HomeScreen": (BuildContext context) => HomeScreen(),
            "/AddNewCallScreen": (BuildContext context) => AddNewCallScreen(),
            "/EditCallScreen": (BuildContext context) => EditCallScreen(),
            "/AboutScreen": (BuildContext context) => AboutScreen()
          },
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}