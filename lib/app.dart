import 'package:call_manager/firebase/firebase.dart';
import 'package:call_manager/screens/home_screen.dart';
import 'package:call_manager/screens/login_screen.dart';
import 'package:call_manager/services/contacts_utility.dart';
import 'package:call_manager/services/notifications_service.dart';
import 'package:call_manager/services/phone_utility.dart';
import 'package:call_manager/services/prefs_service.dart';
import 'package:call_manager/theme/app_themes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CallManagerApp extends StatefulWidget {
  const CallManagerApp({
    Key key,
    @required this.contactsUtility,
    @required this.notificationService,
    @required this.phoneUtility,
    @required this.prefsService,
  }) : super(key: key);

  final ContactsUtility contactsUtility;
  final NotificationService notificationService;
  final PhoneUtility phoneUtility;
  final PrefsService prefsService;

  @override
  _CallManagerAppState createState() => _CallManagerAppState();
}

class _CallManagerAppState extends State<CallManagerApp> with FirebaseMixin {
  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _onAuthStateChange();
  }

  void _onAuthStateChange() {
    auth.authStateChanges().listen((User user) {
      if (user == null) {
        _navigatorKey.currentState.pushAndRemoveUntil(
          LoginScreen.route(),
          (route) => false,
        );
      } else {
        firestore.initStorageForUser(currentUser.uid);
        _navigatorKey.currentState.pushAndRemoveUntil(
          HomeScreen.route(),
          (route) => false,
        );
      }
    });
  }

  Route<dynamic> _onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case HomeScreen.routeName:
        return HomeScreen.route(settings: settings);
      case LoginScreen.routeName:
        return LoginScreen.route(settings: settings);
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<PrefsService>.value(value: widget.prefsService),
        Provider<ContactsUtility>.value(value: widget.contactsUtility),
        Provider<PhoneUtility>.value(value: widget.phoneUtility),
        Provider<NotificationService>.value(value: widget.notificationService),
      ],
      child: StreamBuilder<ThemeMode>(
        stream: widget.prefsService.themeModeSubject,
        initialData: widget.prefsService.themeModeSubject.valueWrapper.value,
        builder: (context, snapshot) {
          return MaterialApp(
            navigatorKey: _navigatorKey,
            title: 'Call Manager',
            theme: AppThemes.lightTheme(),
            darkTheme: AppThemes.darkTheme(),
            themeMode: snapshot.data,
            initialRoute: currentUser != null
                ? HomeScreen.routeName
                : LoginScreen.routeName,
            onGenerateInitialRoutes: (String initialRoute) => [
              _onGenerateRoute(RouteSettings(name: initialRoute)),
            ],
            onGenerateRoute: _onGenerateRoute,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
