import 'package:call_manager/EditCall/edit_call_screen.dart';
import 'package:call_manager/utils/pass_notification.dart';
import 'package:call_manager/Login/login_screen.dart';
import 'package:call_number/call_number.dart';
import 'package:flutter/material.dart';
import 'package:call_manager/HomeScreen/home_screen.dart';
import 'package:call_manager/NewCall/add_new_call_screen.dart';
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
      onSelectNotification: (String payload) async {
        if (payload != null) {
          debugPrint('notification payload: ' + payload);
        }
        await CallNumber().callNumber(payload);
      }
    );

  // launch app
  runApp(
    PassNotification(
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
        textSelectionHandleColor: Colors.blue[600],
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
          },
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}