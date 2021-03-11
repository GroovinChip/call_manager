import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:groovin_material_icons/groovin_material_icons.dart';
import 'package:groovin_widgets/groovin_widgets.dart';
import 'package:rounded_modal/rounded_modal.dart';
import 'package:call_manager/globals.dart' as globals;
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:bubble_tab_indicator/bubble_tab_indicator.dart';

/// This class launches BottomSheets used by the app.
class BottomSheets {
  BuildContext context;

  BottomSheets(this.context);

  /// Show the BottomSheet launched from the BottomAppBar
  /// on the HomeScreen widget
  void showBottomAppBarSheet() {
    showRoundedModalBottomSheet(
      color: Theme.of(context).canvasColor,
      context: context,
      dismissOnTap: false,
      builder: (builder){
        return BottomAppBarSheet();
      }
    );
  }
}

/// Represents the BottomSheet launched from the BottomAppBar
/// on the HomeScreen widget
class BottomAppBarSheet extends StatefulWidget {
  @override
  _BottomAppBarSheetState createState() => _BottomAppBarSheetState();
}

class _BottomAppBarSheetState extends State<BottomAppBarSheet> with SingleTickerProviderStateMixin{
  // Set initial package info
  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
  );

  // Get and set the package details
  Future getPackageDetails() async{
    final PackageInfo info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  TabController _tabController;

  void changeBrightness() {
    //DynamicTheme.of(context).setBrightness(Theme.of(context).brightness == Brightness.dark? Brightness.light: Brightness.dark);
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    getPackageDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
          ),
          Divider(
            color: Colors.grey,
            height: 0.0,
          ),
          Container(
            height: 50.0,
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.white,
              unselectedLabelColor: Theme.of(context).brightness == Brightness.light
                ? Colors.grey[600]
                : Colors.grey[400],
              indicatorColor: Theme.of(context).primaryColor,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BubbleTabIndicator(
                indicatorHeight: 25.0,
                indicatorColor: Theme.of(context).primaryColor,
                tabBarIndicatorSize: TabBarIndicatorSize.tab,
                insets: EdgeInsets.only(left: 40.0, right: 40.0)
              ),
              tabs: <Widget>[
                Tab(
                  child: Text("Options"),
                ),
                Tab(
                  child: Text("About"),
                ),
              ],
            ),
          ),
          Container(
            height: 175.0,
            child: TabBarView(
              controller: _tabController,
              children: <Widget>[
                ListView(
                  children: <Widget>[
                    Material(
                      child: ListTile(
                        title: Text("Delete All Calls"),
                        leading: Icon(
                          Icons.clear_all,
                          color: Theme.of(context).brightness == Brightness.light
                              ? Colors.black
                              : Colors.white,
                        ),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: Text("Delete All Calls"),
                              content: Text("Are you sure you want to delete all calls? This cannot be undone."),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: (){
                                    Navigator.pop(context);
                                  },
                                  child: Text("No"),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    Navigator.pop(context);
                                    CollectionReference ref = FirebaseFirestore.instance.collection("Users").doc(globals.loggedInUser.uid).collection("Calls");
                                    QuerySnapshot s = await ref.get();
                                    if(s.docs.length == 0){
                                      final snackBar = SnackBar(
                                        content: Text("There are no calls to delete"),
                                        action: SnackBarAction(
                                            label: 'Dismiss',
                                            onPressed: () {

                                            }
                                        ),
                                        duration: Duration(seconds: 3),
                                      );
                                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                    } else {
                                      for(int i = 0; i < s.docs.length; i++) {
                                        DocumentReference d = s.docs[i].reference;
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
                        leading: Icon(
                          Theme.of(context).brightness == Brightness.light
                              ? Icons.brightness_2
                              : Icons.brightness_7,
                          color: Theme.of(context).brightness == Brightness.light
                            ? Colors.black
                            : Colors.white,),
                        title: Theme.of(context).brightness == Brightness.light
                            ? Text("Toggle Dark Theme")
                            : Text("Toggle Light Theme"),
                        onTap: () {
                          changeBrightness();
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    Material(
                      child: ListTile(
                        title: Text("Log Out"),
                        leading: Icon(
                          GroovinMaterialIcons.logout,
                          color: Theme.of(context).brightness == Brightness.light
                            ? Colors.black
                            : Colors.white,),
                        onTap: (){
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: Text("Log Out"),
                              content: Text("Are you sure you want to log out?"),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: (){
                                    Navigator.pop(context);
                                  },
                                  child: Text("No"),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    await FirebaseAuth.instance.signOut();
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
                  ],
                ),
                ListView(
                  children: <Widget>[
                    Material(
                      child: ListTile(
                        leading: Icon(
                          Icons.info_outline,
                          color: Theme.of(context).brightness == Brightness.light
                              ? Colors.black
                              : Colors.white,
                        ),
                        title: Text(_packageInfo.appName),
                        subtitle: Text("Version " + _packageInfo.version),
                        trailing: TextButton(
                          //textColor: Theme.of(context).primaryColor,
                          child: Text("Source Code"),
                          onPressed: () {
                            launch("https:github.com/GroovinChip/CallManager");
                          },
                        ),
                      ),
                    ),
                    /*Padding(
                      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0, bottom: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text("Social:"),
                        ],
                      ),
                    ),*/
                    Material(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(left: 16.0),
                            child: Text("Contact: "),
                          ),
                          IconButton(
                            icon: Icon(GroovinMaterialIcons.twitter),
                            color: Colors.blue,
                            onPressed: (){
                              launch("https:twitter.com/GroovinChipDev");
                            },
                          ),
                          IconButton(
                            icon: Icon(GroovinMaterialIcons.discord),
                            color: Colors.deepPurple[300],
                            onPressed: (){
                              launch("https://discord.gg/CFnBRue");
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 16.0),
                            child: IconButton(
                              icon: Icon(GroovinMaterialIcons.gmail),
                              color: Colors.red,
                              onPressed: (){
                                launch("mailto:groovinchip@gmail.com");
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    /*Material(
                      child: ListTile(
                        leading: Icon(
                          GroovinMaterialIcons.flutter,
                          color: Theme.of(context).primaryColor,
                        ),
                        title: Text("This app was built with Flutter"),
                        trailing: FlatButton(
                          textColor: Theme.of(context).primaryColor,
                          child: Text("Get Started"),
                          onPressed: () {
                            launch("https:flutter.io");
                          },
                        ),
                      ),
                    ),*/
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
