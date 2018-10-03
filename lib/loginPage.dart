import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:call_manager/api.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:async';
import 'package:groovin_material_icons/groovin_material_icons.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:call_manager/globals.dart' as globals;
import 'package:intl/intl.dart';

class LoginPage extends StatefulWidget {
  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {

  // gets called on button press
  Future _loginUser() async {
    final api = await FBApi.signInWithGoogle();
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
    } else {

    }
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
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
      statusBarIconBrightness: Brightness.dark,
      statusBarColor: Colors.white,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark));

    Future.delayed(
      Duration(milliseconds: 500),
          () => setState(() {
        _opacity = 1.0;
      }
      )
    );

    return Scaffold(
      backgroundColor: Colors.white,
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
                    padding: const EdgeInsets.only(bottom: 150.0, top: 25.0),
                    child: Text(
                      "Your Phone Call Organizer",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16.0),
                    ),
                  ),
                  _loggedIn
                      ? const Center(child: CircularProgressIndicator())
                      : RaisedButton.icon(
                    color: Colors.blue[700],
                    icon: Icon(
                      GroovinMaterialIcons.google,
                      color: Colors.white,
                    ),
                    label: Text("Sign in with Google",
                        style: TextStyle(color: Colors.white)),
                    onPressed: () async => await _loginUser().catchError((e) => print(e)),
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
