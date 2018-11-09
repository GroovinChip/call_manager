import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:call_manager/login_api.dart';
import 'dart:async';
import 'package:groovin_material_icons/groovin_material_icons.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:call_manager/globals.dart' as globals;

class LoginPage extends StatefulWidget {
  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  /// Represents the Brightness of the statusbar and navigation bar
  Brightness barBrightness;

  // gets called on button press
  Future _loginUser() async {
    final api = await FirebaseAPI.signInWithGoogle();
    if (api != null) {
      globals.loggedInUser = api.firebaseUser;
      CollectionReference dbForUser = Firestore.instance.collection("Users");
      if (dbForUser.document(globals.loggedInUser.uid).path.isNotEmpty) {
        setState(() {
          Navigator.of(context).pushNamedAndRemoveUntil(
              '/HomeScreen', (Route<dynamic> route) => false);
        });
      } else {
        dbForUser.document(globals.loggedInUser.uid).setData({});
      }
    } else {}
  }

  // initial animation opacity
  double _opacity = 0.0;

  // tracks whether the user is logged in
  bool _loggedIn = false;

  @override
  void initState() {
    super.initState();
    verifyUser();
  }

  // Gets called from initState to check whether there is a cached user
  verifyUser() async {
    final user = await FirebaseAuth.instance.currentUser();
    if (user != null) {
      globals.loggedInUser = user;
      setState(() {
        Navigator.of(context).pushNamedAndRemoveUntil(
            '/HomeScreen', (Route<dynamic> route) => false);
      });
      if (mounted) {
        setState(() {
          _loggedIn = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.light) {
      barBrightness = Brightness.dark;
    } else {
      barBrightness = Brightness.light;
    }

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
        statusBarIconBrightness: barBrightness,
        statusBarColor: Theme.of(context).canvasColor,
        systemNavigationBarColor: Theme.of(context).canvasColor,
        systemNavigationBarIconBrightness: barBrightness));

    Future.delayed(
        Duration(milliseconds: 500),
        () => setState(() {
              _opacity = 1.0;
            }));

    return Scaffold(
      backgroundColor: Theme.of(context).canvasColor,
      body: SafeArea(
        child: Center(
          child: AnimatedOpacity(
            opacity: _opacity,
            duration: Duration(seconds: 2),
            child: Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    "Call Manager",
                    style:
                        TextStyle(fontSize: 48.0, fontWeight: FontWeight.bold),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 50.0, top: 25.0),
                    child: Text(
                      "Your Phone Call Organizer",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 50.0),
                    child: Image.asset(
                      "assets/icon/call_manager_app_icon.png",
                      width: 92.0,
                      height: 92.0,
                    ),
                  ),
                  _loggedIn
                      ? const Center(child: CircularProgressIndicator())
                      : RaisedButton.icon(
                          color: Theme.of(context).canvasColor,
                          elevation: 2.0,
                          icon: Image.asset(
                            "assets/glogo.png",
                            width: 32.0,
                            height: 32.0,
                          ),
                          label: Text(
                            "Sign in with Google",
                          ),
                          onPressed: () async =>
                              await _loginUser().catchError((e) => print(e)),
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
