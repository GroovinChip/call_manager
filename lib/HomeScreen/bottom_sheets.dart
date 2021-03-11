import 'package:call_manager/globals.dart' as globals;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:groovin_material_icons/groovin_material_icons.dart';
import 'package:groovin_widgets/groovin_widgets.dart';
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart';

/// Represents the BottomSheet launched from the BottomAppBar
/// on the HomeScreen widget
class BottomAppBarSheet extends StatefulWidget {
  @override
  _BottomAppBarSheetState createState() => _BottomAppBarSheetState();
}

class _BottomAppBarSheetState extends State<BottomAppBarSheet> {
  // Set initial package info
  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
  );

  @override
  void initState() {
    super.initState();
    getPackageDetails();
  }

  // Get and set the package details
  Future<void> getPackageDetails() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() => _packageInfo = packageInfo);
  }

  void changeBrightness() {
    //DynamicTheme.of(context).setBrightness(Theme.of(context).brightness == Brightness.dark? Brightness.light: Brightness.dark);
    //Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: ModalDrawerHandle(),
        ),
        ListTile(
          leading: CircleAvatar(
            child: Text(
              globals.loggedInUser.displayName[0],
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.blue[700],
          ),
          title: Text(globals.loggedInUser.displayName),
          subtitle: Text(globals.loggedInUser.email),
          trailing: TextButton(
            child: Text('LOG OUT'),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  //title: Text('Log Out'),
                  content: Text('Are you sure you want to log out?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('NO'),
                    ),
                    TextButton(
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                        Navigator.of(context).pushNamedAndRemoveUntil(
                            '/', (Route<dynamic> route) => false);
                      },
                      child: Text('YES'),
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
        ListTile(
          title: Text('Delete All Calls'),
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
                //title: Text('Delete All Calls'),
                content: Text(
                    'Are you sure you want to delete all calls? This cannot be undone.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('CANCEL'),
                  ),
                  TextButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      CollectionReference ref = FirebaseFirestore.instance
                          .collection('Users')
                          .doc(globals.loggedInUser.uid)
                          .collection('Calls');
                      final snapshot = await ref.get();
                      if (snapshot.docs.length == 0) {
                        final snackBar = SnackBar(
                          content: Text('There are no calls to delete'),
                          action: SnackBarAction(
                            label: 'Dismiss',
                            onPressed: () {},
                          ),
                          duration: Duration(seconds: 3),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      } else {
                        for (int i = 0; i < snapshot.docs.length; i++) {
                          DocumentReference d = snapshot.docs[i].reference;
                          d.delete();
                        }
                      }
                    },
                    child: Text('DELETE'),
                  ),
                ],
              ),
            );
          },
        ),
        ListTile(
          leading: Icon(
            Theme.of(context).brightness == Brightness.light
                ? Icons.brightness_2
                : Icons.brightness_7,
            color: Theme.of(context).brightness == Brightness.light
                ? Colors.black
                : Colors.white,
          ),
          title: Theme.of(context).brightness == Brightness.light
              ? Text('Toggle Dark Theme')
              : Text('Toggle Light Theme'),
          onTap: changeBrightness,
        ),
        Divider(
          color: Colors.grey,
          height: 0.0,
        ),
        ListTile(
          leading: Icon(
            GroovinMaterialIcons.github_circle,
            color: Theme.of(context).brightness == Brightness.light
                ? Colors.black
                : Colors.white,
          ),
          title: Text('Call Manager v${_packageInfo.version}'),
          subtitle: Text('View source code'),
          onTap: () {
            launch('https:github.com/GroovinChip/CallManager');
          },
          /*trailing: TextButton(
            //textColor: Theme.of(context).primaryColor,
            child: Text('SOURCE CODE'),
            onPressed: () {
              launch('https:github.com/GroovinChip/CallManager');
            },
          ),*/
        ),
      ],
    );
  }
}
