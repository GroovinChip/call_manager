import 'package:call_manager/widgets/call_card_list.dart';
import 'package:call_manager/widgets/menu_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      await PermissionHandler().requestPermissions([PermissionGroup.phone, PermissionGroup.contacts]);
    phonePerm =
      await PermissionHandler().checkPermissionStatus(PermissionGroup.phone);
    contactsPerm =
      await PermissionHandler().checkPermissionStatus(PermissionGroup.contacts);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: theme.canvasColor,
        elevation: 0,
        title: Text('Call Manager'),
      ),
      body: CallCardList(),
      floatingActionButton: Builder(
        builder: (context) => FloatingActionButton.extended(
          icon: Icon(Icons.add),
          elevation: 2.0,
          backgroundColor: Colors.blue[700],
          label: Text('New Call'),
          onPressed: () {
            if(contactsPerm == PermissionStatus.granted) {
              Navigator.of(context).pushNamed('/AddNewCallScreen');
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Theme.of(context).primaryColor,
                  content: Wrap(
                    children: <Widget>[
                      Text('Please grant the Contacts permission to use this page.'),
                    ],
                  ),
                  duration: Duration(seconds: 2),
                  action: SnackBarAction(
                    label: 'Grant',
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
      bottomNavigationBar: BottomAppBar(
        child: Row(
          //mainAxisSize: MainAxisSize.max,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: IconButton(
                icon: Icon(Icons.menu),
                onPressed: (){
                  showModalBottomSheet(
                    backgroundColor: Theme.of(context).canvasColor,
                    context: context,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(8.0),
                      ),
                    ),
                    builder: (_) => MenuBottomSheet(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}