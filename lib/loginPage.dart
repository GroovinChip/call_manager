import 'package:flutter/material.dart';
import 'package:flutter/animation.dart';
import 'package:call_manager/api.dart';
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
  Future<bool> _loginUser() async {
    final api = await FBApi.signInWithGoogle();
    if (api != null) {
      globals.loggedInUser = api.firebaseUser;
      CollectionReference dbForUser = Firestore.instance.collection("Users");
      if(dbForUser.document(globals.loggedInUser.uid).path.isNotEmpty){

      } else {
        dbForUser.document(globals.loggedInUser.uid).setData({});
      }
      return true;
    } else {
      return false;
    }
  }

  double _opacity = 0.0;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
        statusBarIconBrightness: Brightness.dark,
        statusBarColor: Colors.white,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark
    ));

    Future.delayed(Duration(milliseconds: 500),()=> setState((){
      _opacity = 1.0;
    }));

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
                    style: TextStyle(
                      fontSize: 48.0,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 150.0, top: 25.0),
                    child: Text(
                      "Your Phone Call Organizer",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0
                      ),
                    ),
                  ),
                  RaisedButton.icon(
                    color: Colors.blue,
                    icon: Icon(GroovinMaterialIcons.google, color: Colors.white,),
                    label: Text("Sign in with Google", style: TextStyle(color: Colors.white)),
                    onPressed: () async {
                      bool b = await _loginUser();
                      if(b){
                        Navigator.of(context).pushNamedAndRemoveUntil('/HomeScreen',(Route<dynamic> route) => false);
                      } else {
                        Scaffold.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Wrong Email!'),
                          ),
                        );
                      }
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
