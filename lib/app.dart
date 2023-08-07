import 'package:call_manager/firebase/firebase.dart';
import 'package:call_manager/screens/home_screen.dart';
import 'package:call_manager/screens/login_screen.dart';
import 'package:call_manager/services/contacts_utility.dart';
import 'package:call_manager/services/notifications_service.dart';
import 'package:call_manager/services/phone_utility.dart';
import 'package:call_manager/services/prefs_service.dart';
import 'package:call_manager/theme/app_colors.dart';
import 'package:call_manager/theme/app_themes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wiredash/wiredash.dart';

class CallManagerApp extends StatefulWidget {
  const CallManagerApp({
    Key? key,
    required this.contactsUtility,
    required this.notificationService,
    required this.phoneUtility,
    required this.prefsService,
  }) : super(key: key);

  final ContactsUtility contactsUtility;
  final NotificationService notificationService;
  final PhoneUtility phoneUtility;
  final PrefsService prefsService;

  @override
  State<CallManagerApp> createState() => _CallManagerAppState();
}

class _CallManagerAppState extends State<CallManagerApp> with FirebaseMixin {
  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _onAuthStateChange();
  }

  void _onAuthStateChange() {
    auth.authStateChanges().listen((User? user) {
      if (user != null) {
        firestore.initStorageForUser(currentUser!.uid);
        firestore.recordLoginDate(currentUser!.uid);
      }
    });
  }

  Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
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
      child: StreamBuilder<Preferences>(
        stream: widget.prefsService.preferencesSubject,
        initialData: widget.prefsService.preferencesSubject.value,
        builder: (context, snapshot) {
          return Wiredash(
            projectId: 'call-manager-bk2ikve',
            secret: '6p356wjo9kyupuj9se49pd0q2e41xa1x4m68nnky0hvkeva8',
            theme: WiredashThemeData(
              primaryColor: AppColors.primaryColor,
              //primaryBackgroundColor: AppColors.primaryColor,
              appBackgroundColor: AppColors.primaryColor,
              brightness: snapshot.data!.brightness,
            ),
            child: MaterialApp(
              navigatorKey: _navigatorKey,
              title: 'Call Manager',
              theme: AppThemes.lightTheme(),
              darkTheme: AppThemes.darkTheme(),
              themeMode: snapshot.data!.themeMode,
              initialRoute: currentUser != null
                  ? HomeScreen.routeName
                  : LoginScreen.routeName,
              onGenerateInitialRoutes: ((String initialRoute) => [
                    _onGenerateRoute(RouteSettings(name: initialRoute))!,
                  ]),
              onGenerateRoute: _onGenerateRoute,
              debugShowCheckedModeBanner: false,
            ),
          );
        },
      ),
    );
  }
}
