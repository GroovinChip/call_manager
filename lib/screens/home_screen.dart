import 'dart:io';

import 'package:call_manager/provided.dart';
import 'package:call_manager/screens/desktop_home_screen.dart';
import 'package:call_manager/screens/new_call_screen.dart';
import 'package:call_manager/theme/app_themes.dart';
import 'package:call_manager/widgets/calls_list.dart';
import 'package:call_manager/widgets/menu_bottom_sheet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeScreen extends StatelessWidget {
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
  // ignore: long-method
  Widget build(BuildContext context) {
    return HomeScreenAdapter();
  }
}

class HomeScreenAdapter extends StatelessWidget {
  const HomeScreenAdapter({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid || Platform.isIOS) {
      return MobileHomeScreen();
    } else {
      return DesktopHomeScreen();
    }
  }
}

class MobileHomeScreen extends StatefulWidget {
  const MobileHomeScreen({Key? key}) : super(key: key);

  @override
  _MobileHomeScreenState createState() => _MobileHomeScreenState();
}

class _MobileHomeScreenState extends State<MobileHomeScreen>
    with Provided, SingleTickerProviderStateMixin {
  late final tabController = TabController(length: 2, vsync: this);

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  /// Checks for contacts and phone permissions and requests them if they
  /// are not yet given.
  Future<void> _checkPermissions() async {
    if (Platform.isAndroid || Platform.isIOS) {
      await [
        Permission.phone,
        Permission.contacts,
      ].request();
    }
  }

  @override
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
