import 'package:call_manager/firebase/firebase_mixin.dart';
import 'package:flutter/material.dart';
import 'package:groovin_material_icons/groovin_material_icons.dart';
import 'package:groovin_widgets/groovin_widgets.dart';
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart';

/// Represents the BottomSheet launched from the BottomAppBar
/// on the HomeScreen widget
class MenuBottomSheet extends StatefulWidget {
  @override
  _MenuBottomSheetState createState() => _MenuBottomSheetState();
}

class _MenuBottomSheetState extends State<MenuBottomSheet>
    with FirebaseMixin {
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
    final theme = Theme.of(context);
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
              currentUser.displayName[0],
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.blue[700],
          ),
          title: Text(currentUser.displayName),
          subtitle: Text(currentUser.email),
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
                        await auth.signOut();
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
            color: theme.brightness == Brightness.light
                ? Colors.black
                : Colors.white,
          ),
          onTap: () {
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                content: Text(
                    'Are you sure you want to delete all calls? This cannot be undone.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('CANCEL'),
                  ),
                  TextButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      final callsRef = firestore
                          .collection('Users')
                          .doc(currentUser.uid)
                          .collection('Calls');
                      final callSnapshots = await callsRef.get();
                      if (callSnapshots.docs.length == 0) {
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
                        for (int i = 0; i < callSnapshots.docs.length; i++) {
                          callSnapshots.docs[i].reference.delete();
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
            theme.brightness == Brightness.light
                ? Icons.brightness_2
                : Icons.brightness_7,
            color: theme.brightness == Brightness.light
                ? Colors.black
                : Colors.white,
          ),
          title: theme.brightness == Brightness.light
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
            color: theme.brightness == Brightness.light
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
