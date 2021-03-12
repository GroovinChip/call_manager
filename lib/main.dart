import 'package:call_manager/screens/home_screen.dart';
import 'package:call_manager/screens/login_screen.dart';
import 'package:call_manager/screens/new_call_screen.dart';
import 'package:call_manager/services/contacts_utility.dart';
import 'package:call_manager/services/phone_utility.dart';
import 'package:call_manager/services/prefs_service.dart';
import 'package:call_manager/theme/app_themes.dart';
import 'package:call_manager/utils/pass_notification.dart';
import 'package:call_number/call_number.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  final prefsService = await PrefsService.init();
  final contactsUtility = await ContactsUtility.init();
  final phoneUtility = await PhoneUtility.init();

  // Initialize notification plugin
  final androidInitializationSettings =
      AndroidInitializationSettings('ic_notification');
  final iosInitializationSettings = IOSInitializationSettings();
  final initializationSettings = InitializationSettings(
    android: androidInitializationSettings,
    iOS: iosInitializationSettings,
  );
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onSelectNotification: (String payload) async {
      if (payload != null) {
        debugPrint('notification payload: ' + payload);
      }
      await CallNumber().callNumber(payload);
    },
  );

  // launch app
  runApp(
    PassNotification(
      flutterLocalNotificationsPlugin,
      child: CallManagerApp(
        prefsService: prefsService,
        contactsUtility: contactsUtility,
        phoneUtility: phoneUtility,
      ),
    ),
  );
}

class CallManagerApp extends StatelessWidget {
  const CallManagerApp({
    Key key,
    @required this.prefsService,
    @required this.contactsUtility,
    @required this.phoneUtility,
  }) : super(key: key);

  final PrefsService prefsService;
  final ContactsUtility contactsUtility;
  final PhoneUtility phoneUtility;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<PrefsService>.value(value: prefsService),
        Provider<ContactsUtility>.value(value: contactsUtility),
        Provider<PhoneUtility>.value(value: phoneUtility),
      ],
      child: StreamBuilder<ThemeMode>(
        stream: prefsService.themeModeSubject,
        initialData: prefsService.themeModeSubject.valueWrapper.value,
        builder: (context, snapshot) {
          return MaterialApp(
            title: 'Call Manager',
            theme: AppThemes.lightTheme(),
            darkTheme: AppThemes.darkTheme(),
            themeMode: snapshot.data,
            home: LoginScreen(),
            routes: <String, WidgetBuilder>{
              '/HomeScreen': (BuildContext context) => HomeScreen(),
              '/AddNewCallScreen': (BuildContext context) => NewCallScreen(),
              //'/EditCallScreen': (BuildContext context) => EditCallScreen(),
            },
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
