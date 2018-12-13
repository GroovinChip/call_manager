import 'package:call_manager/add_new_call_screen.dart';
import 'package:call_manager/cm_bottom_app_bar.dart';
import 'package:call_manager/call_card.dart';
import 'package:call_manager/utils/page_transitions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: Firestore.instance.collection("Users").document(globals.loggedInUser.uid).collection("Calls").snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData == false) {
              return Center(child: Text("Getting Calls..."));
            } else {
              return snapshot.data.documents.length > 0
                ? Column(
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            "Call Manager",
                            style: TextStyle(
                              fontSize: 22.0,
                              fontWeight: FontWeight.bold
                            ),
                          )
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 15,
                      child: ListView.builder(
                        itemCount: snapshot.data.documents.length,
                        itemBuilder: (context, index) {
                          DocumentSnapshot ds = snapshot.data.documents[index];
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: CallCard(callSnapshot: ds),
                          );
                        },
                      ),
                    )
                  ],
                )
                : Center(child: Text("No Calls"));
            }
          },
        ),
      ),
      floatingActionButton: Builder(
        builder: (context) => FloatingActionButton.extended(
          icon: Icon(Icons.add),
          elevation: 2.0,
          backgroundColor: Colors.blue[700],
          label: Text("New Call"),
          onPressed: () {
            //Navigator.of(context).pushNamed("/AddNewCallScreen");
            if(contactsPerm == PermissionStatus.granted) {
              Navigator.push(
                context,
                SlideLeftRoute(widget: AddNewCallScreen()),
              );
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