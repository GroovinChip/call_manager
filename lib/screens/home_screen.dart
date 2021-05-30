import 'package:call_manager/provided.dart';
import 'package:call_manager/screens/new_call_screen.dart';
import 'package:call_manager/theme/app_themes.dart';
import 'package:call_manager/widgets/calls_list.dart';
import 'package:call_manager/widgets/menu_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key}) : super(key: key);

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

class _HomeScreenState extends State<HomeScreen>
    with Provided, SingleTickerProviderStateMixin {
  late final tabController = TabController(length: 2, vsync: this);
  @override
  void initState() {
    super.initState();
    //_checkPermissions();
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
  // ignore: long-method
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppThemes.themedSystemNavigationBar(context),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Call Manager'),
          bottom: TabBar(
            controller: tabController,
            indicatorColor: Theme.of(context).indicatorColor.withOpacity(.40),
            labelColor: Theme.of(context).colorScheme.onSurface,
            tabs: [
              Tab(
                child: Text('Upcoming'),
              ),
              Tab(
                child: Text('Completed'),
              ),
            ],
          ),
        ),
        body: CallsList(
          tabController: tabController,
        ),
        floatingActionButton: FloatingActionButton.extended(
          icon: Icon(Icons.add),
          elevation: 2.0,
          label: Text('NEW CALL'),
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
