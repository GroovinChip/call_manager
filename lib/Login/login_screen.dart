import 'dart:async';
import 'dart:developer';

import 'package:call_manager/firebase/firebase_mixin.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginPage extends StatefulWidget {
  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> with FirebaseMixin {
  ThemeData theme;
  Brightness barBrightness;
  double _opacity = 0.0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _setBarBrightness();
    _verifyUser();
  }

  void _setBarBrightness() {
    theme = Theme.of(context);
    if (theme.brightness == Brightness.light) {
      barBrightness = Brightness.dark;
    } else {
      barBrightness = Brightness.light;
    }

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.dark.copyWith(
        statusBarIconBrightness: barBrightness,
        statusBarColor: theme.canvasColor,
        systemNavigationBarColor: theme.canvasColor,
        systemNavigationBarIconBrightness: barBrightness,
      ),
    );
  }

  // Gets called from initState to check whether there is a cached user
  Future<void> _verifyUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushNamedAndRemoveUntil(
            '/HomeScreen', (Route<dynamic> route) => false);
      });
    } else {
      await Future.delayed(
        Duration(milliseconds: 500),
      ).then((_) {
        setState(() => _opacity = 1.0);
      });
    }
  }

  // gets called on button press
  Future _loginUser() async {
    final googleUser = await GoogleSignIn().signIn();
    final googleAuth = await googleUser.authentication;

    final googleAuthCredential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    await auth.signInWithCredential(googleAuthCredential);

    if (currentUser != null) {
      final dbForUser = firestore.collection('Users');
      if (dbForUser.doc(currentUser.uid).path.isNotEmpty) {
        setState(() {
          Navigator.of(context).pushNamedAndRemoveUntil(
              '/HomeScreen', (Route<dynamic> route) => false);
        });
      } else {
        dbForUser.doc(currentUser.uid).set({});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: theme.canvasColor,
      body: SafeArea(
        child: Center(
          child: AnimatedOpacity(
            opacity: _opacity,
            duration: Duration(seconds: 1),
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
                        primary: theme.colorScheme.surface,
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
                      onPressed: () async {
                        await _loginUser().catchError((e) {
                          log('Error signing in with Google: $e',
                              name: 'Call Manager');
                        });
                      },
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
