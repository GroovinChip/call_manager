import 'package:call_manager/provided.dart';
import 'package:call_manager/screens/new_call_screen.dart';
import 'package:call_manager/theme/app_themes.dart';
import 'package:call_manager/widgets/call_card_list.dart';
import 'package:call_manager/widgets/menu_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key key}) : super(key: key);

  static const routeName = '/homeScreen';

  static Route<dynamic> route({
    RouteSettings settings = const RouteSettings(name: routeName),
  }) {
    return MaterialPageRoute(
      settings: settings,
      builder: (BuildContext context) {
        return HomeScreen();
      },
    );
  }

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with Provided {
  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  /// Checks for contacts and phone permissions and requests them if they
  /// are not yet given.
  Future<void> _checkPermissions() async {
    await [
      Permission.phone,
      Permission.contacts,
    ].request();

    /*if (contactsUtility.permissionStatus.isUndetermined ||
        contactsUtility.permissionStatus.isDenied) {
      contactsUtility.requestPermission();
    }

    if (phoneUtility.phonePermissionStatus.isUndetermined ||
        phoneUtility.phonePermissionStatus.isDenied) {
      phoneUtility.requestPhonePermission();
    }*/
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppThemes.themedSystemNavigationBar(context),
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: theme.canvasColor,
          elevation: 0,
          title: Text('Call Manager'),
          backwardsCompatibility: false,
        ),
        body: CallCardList(),
        floatingActionButton: FloatingActionButton.extended(
          icon: Icon(Icons.add),
          elevation: 2.0,
          label: Text('New Call'),
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => NewCallScreen(),
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: BottomAppBar(
          child: Row(
            children: [
              const SizedBox(width: 8.0),
              IconButton(
                icon: Icon(Icons.menu),
                onPressed: () {
                  showModalBottomSheet(
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
            ],
          ),
        ),
      ),
    );
  }
}
