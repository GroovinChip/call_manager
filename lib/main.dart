import 'package:call_manager/editCallScreen.dart';
import 'package:call_manager/loginPage.dart';
import 'package:flutter/material.dart';
import 'package:call_manager/HomeScreen.dart';
import 'package:call_manager/AddNewCallScreen.dart';

void main() => runApp(new CallManagerApp());

class CallManagerApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Call Manager',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
        canvasColor: Colors.transparent,
        fontFamily: 'SourceSansPro-Bold',
      ),
      home: new LoginPage(),
      routes: <String, WidgetBuilder>{
        "/HomeScreen": (BuildContext context) => new HomeScreen(),
        "/AddNewCallScreen": (BuildContext context) => new AddNewCallScreen(),
        "/EditCallScreen": (BuildContext context) => new EditCallScreen()
      },
      debugShowCheckedModeBanner: false,
    );
  }
}