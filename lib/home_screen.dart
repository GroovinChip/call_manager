import 'dart:async';
import 'package:call_manager/add_new_call_screen.dart';
import 'package:call_manager/about_screen.dart';
import 'package:call_manager/call_card.dart';
import 'package:call_manager/edit_call_screen.dart';
import 'package:call_manager/pass_notification.dart';
import 'package:call_manager/utils/page_transitions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:datetime_picker_formfield/time_picker_formfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:call_number/call_number.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:groovin_material_icons/groovin_material_icons.dart';
import 'package:call_manager/globals.dart' as globals;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:rounded_modal/rounded_modal.dart';
import 'package:modal_drawer_handle/modal_drawer_handle.dart';

void main() {
  runApp(HomeScreen());
}

/// This class represents the Home Screen of the app.
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  // Represents the current permission status
  PermissionStatus status;

  // Represents the Brightness of the statusbar and navigation bar
  Brightness barBrightness;

  @override
  void initState() {
    super.initState();
    permissions();
  }

  // Check current permissions. If phone permission not granted, prompt for it.
  void permissions() async {
    Map<PermissionGroup, PermissionStatus> permissions = await PermissionHandler.requestPermissions([PermissionGroup.phone]);
    PermissionStatus permission = await PermissionHandler.checkPermissionStatus(PermissionGroup.phone);
  }

  @override
  Widget build(BuildContext context) {

    if(Theme.of(context).brightness == Brightness.light){
      barBrightness = Brightness.dark;
    } else {
      barBrightness = Brightness.light;
    }

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
        statusBarIconBrightness: barBrightness,
        statusBarColor: Theme.of(context).canvasColor,
        systemNavigationBarColor: Theme.of(context).canvasColor,
        systemNavigationBarIconBrightness: barBrightness
    ));

    void changeBrightness() {
      DynamicTheme.of(context).setBrightness(Theme.of(context).brightness == Brightness.dark? Brightness.light: Brightness.dark);
    }

    return Scaffold(
      body: SafeArea(
        child: StreamBuilder <QuerySnapshot>(
          stream: Firestore.instance.collection("Users").document(globals.loggedInUser.uid).collection("Calls").snapshots(),
          builder: (context, snapshot) {
            if(snapshot.hasData == false) {
              return Center(child: Text("Getting Calls..."));
            } else {
              return snapshot.data.documents.length > 0 ? ListView.builder(
                itemCount: snapshot.data.documents.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot ds = snapshot.data.documents[index];
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CallCard(callSnapshot: ds),
                  );
                },
              )
              : Center(child: Text("No Calls"));
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: Icon(Icons.add),
        heroTag: "ANC",
        elevation: 2.0,
        backgroundColor: Colors.blue[700],
        label: Text("Add New Call"),
        onPressed: () {
          //Navigator.of(context).pushNamed("/AddNewCallScreen");
          Navigator.push(
            context,
            SlideLeftRoute(widget: AddNewCallScreen()),
          );
        }),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Container(
        child: BottomAppBar(
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: IconButton(
                  icon: Icon(Icons.more_vert),
                  onPressed: (){
                    showRoundedModalBottomSheet(
                      color: Theme.of(context).canvasColor,
                      context: context,
                      builder: (builder){
                        return Container(
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: ModalDrawerHandle(),
                                ),
                                ListTile(
                                  leading: CircleAvatar(
                                    child: Text(globals.loggedInUser.displayName[0], style: TextStyle(color: Colors.white),),
                                    backgroundColor: Colors.blue[700],
                                  ),
                                  title: Text(globals.loggedInUser.displayName),
                                  subtitle: Text(globals.loggedInUser.email),
                                  /*leading: Icon(Icons.account_circle, size: 45.0,),
                                  title: Text(globals.loggedInUser.displayName),
                                  subtitle: Text(globals.loggedInUser.email),*/
                                ),
                                Divider(
                                  color: Colors.grey,
                                  height: 0.0,
                                ),
                                Material(
                                  child: ListTile(
                                    title: Text("Delete All Calls"),
                                    leading: Icon(Icons.clear_all),
                                    onTap: () {
                                      Navigator.pop(context);
                                      showDialog(
                                        context: context,
                                        builder: (_) => AlertDialog(
                                          title: Text("Delete All Calls"),
                                          content: Text("Are you sure you want to delete all calls? This cannot be undone."),
                                          actions: <Widget>[
                                            FlatButton(
                                              onPressed: (){
                                                Navigator.pop(context);
                                              },
                                              child: Text("No"),
                                            ),
                                            FlatButton(
                                              onPressed: () async {
                                                Navigator.pop(context);
                                                CollectionReference ref = Firestore.instance.collection("Users").document(globals.loggedInUser.uid).collection("Calls");
                                                QuerySnapshot s = await ref.getDocuments();
                                                if(s.documents.length == 0){
                                                  final snackBar = SnackBar(
                                                    content: Text("There are no calls to delete"),
                                                    action: SnackBarAction(
                                                        label: 'Dismiss',
                                                        onPressed: () {

                                                        }
                                                    ),
                                                    duration: Duration(seconds: 3),
                                                  );
                                                  Scaffold.of(context).showSnackBar(snackBar);
                                                } else {
                                                  for(int i = 0; i < s.documents.length; i++) {
                                                    DocumentReference d = s.documents[i].reference;
                                                    d.delete();
                                                  }
                                                }
                                              },
                                              child: Text("Yes"),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                Material(
                                  child: ListTile(
                                    leading: Icon(Icons.brightness_6),
                                    title: Text("Toggle Dark Theme"),
                                    onTap: () {
                                      changeBrightness();
                                      Navigator.pop(context);
                                    },
                                  ),
                                ),
                                Material(
                                  child: ListTile(
                                    title: Text("Log Out"),
                                    leading: Icon(GroovinMaterialIcons.logout),
                                    onTap: (){
                                      Navigator.pop(context);
                                      showDialog(
                                        context: context,
                                        builder: (_) => AlertDialog(
                                          title: Text("Log Out"),
                                          content: Text("Are you sure you want to log out?"),
                                          actions: <Widget>[
                                            FlatButton(
                                              onPressed: (){
                                                Navigator.pop(context);
                                              },
                                              child: Text("No"),
                                            ),
                                            FlatButton(
                                              onPressed: (){
                                                FirebaseAuth.instance.signOut();
                                                Navigator.of(context).pushNamedAndRemoveUntil('/',(Route<dynamic> route) => false);
                                              },
                                              child: Text("Yes"),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                Divider(
                                  color: Colors.grey,
                                  height: 0.0,
                                ),
                                Material(
                                  child: ListTile(
                                    title: Text("About"),
                                    leading: Icon(Icons.info_outline),
                                    onTap: (){
                                      Navigator.pop(context);
                                      //Navigator.of(context).pushNamed("/AboutScreen");
                                      Navigator.push(
                                        context,
                                        SlideLeftRoute(widget: AboutScreen())
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}