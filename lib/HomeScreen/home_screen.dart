import 'package:call_manager/HomeScreen/CallCardList.dart';
import 'package:call_manager/HomeScreen/cm_bottom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:call_manager/globals.dart' as globals;
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(HomeScreen());
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  PermissionStatus status;
  Brightness barBrightness;
  PermissionStatus phonePerm;
  PermissionStatus contactsPerm;

  @override
  void initState() {
    super.initState();
    checkPermissions();
  }

  // Check current permissions. If phone permission not granted, prompt for it.
  void checkPermissions() async {
    Map<PermissionGroup, PermissionStatus> permissions =
      await PermissionHandler.requestPermissions([PermissionGroup.phone, PermissionGroup.contacts]);
    phonePerm =
      await PermissionHandler.checkPermissionStatus(PermissionGroup.phone);
    contactsPerm =
      await PermissionHandler.checkPermissionStatus(PermissionGroup.contacts);
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
        systemNavigationBarIconBrightness: barBrightness),
    );

    return Scaffold(
      body: CallCardList(),
      floatingActionButton: Builder(
        builder: (context) => FloatingActionButton.extended(
          icon: Icon(Icons.add),
          elevation: 2.0,
          backgroundColor: Colors.blue[700],
          label: Text("New Call"),
          onPressed: () {
            if(contactsPerm == PermissionStatus.granted) {
              Navigator.of(context).pushNamed("/AddNewCallScreen");
            } else {
              Scaffold.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Theme.of(context).primaryColor,
                  content: Wrap(
                    children: <Widget>[
                      Text("Please grant the Contacts permission to use this page."),
                    ],
                  ),
                  duration: Duration(seconds: 2),
                  action: SnackBarAction(
                    label: "Grant",
                    textColor: Colors.white,
                    onPressed: (){
                      checkPermissions();
                    },
                  ),
                ),
              );
            }
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: CMBottomAppBar(),
    );
  }
}