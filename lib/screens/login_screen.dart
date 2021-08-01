import 'dart:io';

import 'package:call_manager/firebase/firebase.dart';
import 'package:call_manager/screens/home_screen.dart';
import 'package:call_manager/theme/app_themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  static const routeName = '/login';

  static Route<dynamic> route({
    RouteSettings settings = const RouteSettings(name: routeName),
  }) {
    return MaterialPageRoute(
      settings: settings,
      builder: (BuildContext context) {
        return const LoginScreen();
      },
    );
  }

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen>
    with FirebaseMixin, SingleTickerProviderStateMixin {
  late Animation<double> animation;
  late AnimationController controller;

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
  // ignore: long-method
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppThemes.themedSystemNavigationBar(context),
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: FadeTransition(
              opacity: animation,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Call Manager',
                    style: TextStyle(
                      fontSize: 48.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 25.0),
                  const Text(
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
                  else ...[
                    if (Platform.isIOS) ...[
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          primary: theme.canvasColor,
                          onPrimary: theme.colorScheme.onSurface,
                          elevation: 2.0,
                        ),
                        icon: const Icon(MdiIcons.apple),
                        label: const Text(
                          'Sign in with Apple',
                        ),
                        onPressed: () async =>
                            await auth.signInWithApple().then((value) {
                          if (auth.currentUser != null) {
                            firestore.recordLoginWithApple(currentUser!.uid);
                            Navigator.of(context).pushAndRemoveUntil(
                              HomeScreen.route(),
                              (route) => false,
                            );
                          }
                        }),
                      ),
                    ],
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
                      label: const Text(
                        'Sign in with Google',
                      ),
                      onPressed: () async =>
                          await auth.signInWithGoogle().then((value) {
                        if (auth.currentUser != null) {
                          firestore.recordLoginWithGoogle(currentUser!.uid);
                          Navigator.of(context).pushAndRemoveUntil(
                            HomeScreen.route(),
                            (route) => false,
                          );
                        }
                      }),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
