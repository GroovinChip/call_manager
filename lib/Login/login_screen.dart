import 'dart:async';
import 'dart:developer';

import 'package:call_manager/globals.dart' as globals;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginPage extends StatefulWidget {
  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  /// Represents the Brightness of the statusbar and navigation bar
  Brightness barBrightness;

  // gets called on button press
  Future _loginUser() async {
    final googleUser = await GoogleSignIn().signIn();
    final googleAuth = await googleUser.authentication;

    final googleAuthCredential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential =
        await FirebaseAuth.instance.signInWithCredential(googleAuthCredential);

    if (userCredential.user != null) {
      globals.loggedInUser = userCredential.user;
      CollectionReference dbForUser =
          FirebaseFirestore.instance.collection("Users");
      if (dbForUser.doc(globals.loggedInUser.uid).path.isNotEmpty) {
        setState(() {
          Navigator.of(context).pushNamedAndRemoveUntil(
              '/HomeScreen', (Route<dynamic> route) => false);
        });
      } else {
        dbForUser.doc(globals.loggedInUser.uid).set({});
      }
    } else {}
  }

  // initial animation opacity
  double _opacity = 0.0;

  // tracks whether the user is logged in
  bool _loggedIn = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    verifyUser();
  }

  // Gets called from initState to check whether there is a cached user
  Future<void> verifyUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      globals.loggedInUser = user;
      SchedulerBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushNamedAndRemoveUntil(
            '/HomeScreen', (Route<dynamic> route) => false);
      });

      if (mounted) {
        setState(() => _loggedIn = true);
      }
    } else {
      await Future.delayed(
        Duration(milliseconds: 500),
      ).then((_) {
        setState(() => _opacity = 1.0);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
                children: <Widget>[
                  Text(
                    'Call Manager',
                    style: TextStyle(
                      fontSize: 48.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 50.0, top: 25.0),
                    child: Text(
                      'Your Phone Call Organizer',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 50.0),
                    child: Image.asset(
                      'assets/icon/call_manager_app_icon.png',
                      width: 92.0,
                      height: 92.0,
                    ),
                  ),
                  if (_loggedIn)
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
                        return await _loginUser().catchError((e) {
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
