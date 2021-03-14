import 'package:call_manager/firebase/firebase.dart';
import 'package:call_manager/theme/app_themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({Key key}) : super(key: key);

  static const routeName = '/login';

  static Route<dynamic> route({
    RouteSettings settings = const RouteSettings(name: routeName),
  }) {
    return MaterialPageRoute(
      settings: settings,
      builder: (BuildContext context) {
        return LoginScreen();
      },
    );
  }

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen>
    with FirebaseMixin, SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation<double> animation;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    animation = CurvedAnimation(
      parent: controller,
      curve: Curves.easeIn,
    );
    controller.forward();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppThemes.themedSystemNavigationBar(context),
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: FadeTransition(
              opacity: animation,
              child: Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Call Manager',
                      style: TextStyle(
                        fontSize: 48.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 25.0),
                    Text(
                      'Your Phone Call Organizer',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                      ),
                    ),
                    const SizedBox(height: 50.0),
                    Image.asset(
                      'assets/icon/call_manager_app_icon.png',
                      width: 92.0,
                      height: 92.0,
                    ),
                    const SizedBox(height: 50.0),
                    if (currentUser != null)
                      const Center(child: CircularProgressIndicator())
                    else
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          primary: theme.canvasColor,
                          onPrimary: theme.colorScheme.onSurface,
                          elevation: 2.0,
                        ),
                        icon: Image.asset(
                          'assets/glogo.png',
                          width: 32.0,
                          height: 32.0,
                        ),
                        label: Text(
                          'Sign in with Google',
                        ),
                        onPressed: () async => await auth.signInWithGoogle(),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
