import 'package:call_manager/about_screen.dart';
import 'package:call_manager/utils/page_transitions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:groovin_material_icons/groovin_material_icons.dart';
import 'package:modal_drawer_handle/modal_drawer_handle.dart';
import 'package:rounded_modal/rounded_modal.dart';
import 'package:call_manager/globals.dart' as globals;

class BottomSheets {
  BuildContext context;

  BottomSheets(this.context);

  void changeBrightness() {
    DynamicTheme.of(context).setBrightness(Theme.of(context).brightness == Brightness.dark? Brightness.light: Brightness.dark);
  }

  void showBottomAppBarSheet() {
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
  }
}