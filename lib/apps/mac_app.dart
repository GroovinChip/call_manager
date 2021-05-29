import 'package:call_manager/firebase/firebase.dart';
import 'package:call_manager/screens/home_screen.dart';
import 'package:call_manager/screens/login_screen.dart';
import 'package:call_manager/services/contacts_utility.dart';
import 'package:call_manager/services/notifications_service.dart';
import 'package:call_manager/services/phone_utility.dart';
import 'package:call_manager/services/prefs_service.dart';
import 'package:call_manager/theme/app_colors.dart';
import 'package:flutter/widgets.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:provider/provider.dart';
import 'package:wiredash/wiredash.dart';

class MacApp extends StatefulWidget {
  MacApp({
    Key? key,
    required this.notificationService,
    required this.prefsService,
    required this.phoneUtility,
    required this.contactsUtility,
  }) : super(key: key);

  final NotificationService notificationService;
  final PrefsService prefsService;
  final PhoneUtility phoneUtility;
  final ContactsUtility contactsUtility;

  @override
  _MacAppState createState() => _MacAppState();
}

class _MacAppState extends State<MacApp> with FirebaseMixin {
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
        Provider<NotificationService>.value(value: widget.notificationService),
        Provider<PhoneUtility>.value(value: widget.phoneUtility),
        Provider<ContactsUtility>.value(value: widget.contactsUtility),
      ],
      child: StreamBuilder<Preferences>(
        stream: widget.prefsService.preferencesSubject,
        initialData: widget.prefsService.preferencesSubject.value,
        builder: (context, snapshot) {
          return Wiredash(
            projectId: 'call-manager-bk2ikve',
            secret: '6p356wjo9kyupuj9se49pd0q2e41xa1x4m68nnky0hvkeva8',
            navigatorKey: _navigatorKey,
            options: WiredashOptionsData(
              praiseButton: false,
            ),
            theme: WiredashThemeData(
              primaryColor: AppColors.primaryColor,
              //primaryBackgroundColor: AppColors.primaryColor,
              backgroundColor: AppColors.primaryColor,
              brightness: snapshot.data!.brightness,
            ),
            child: MacosApp(
              navigatorKey: _navigatorKey,
              title: 'Call Manager',
              theme: MacosThemeData.light(),
              darkTheme: MacosThemeData.dark().copyWith(
                pushButtonTheme: PushButtonThemeData(
                  color: AppColors.primaryColor,
                  disabledColor: Color.fromRGBO(255, 255, 255, 0.1),
                ),
              ),
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
