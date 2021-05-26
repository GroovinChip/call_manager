import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:call_manager/firebase/firebase.dart';
import 'package:call_manager/provided.dart';
import 'package:call_manager/screens/new_call_screen.dart';
import 'package:call_manager/theme/app_themes.dart';
import 'package:call_manager/widgets/calls_list.dart';
import 'package:call_manager/widgets/menu_bottom_sheet.dart';
import 'package:call_manager/widgets/user_account_avatar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:macos_ui/macos_ui.dart' as mui;

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

class DesktopHomeScreen extends StatefulWidget {
  const DesktopHomeScreen({Key? key}) : super(key: key);

  @override
  _DesktopHomeScreenState createState() => _DesktopHomeScreenState();
}

class _DesktopHomeScreenState extends State<DesktopHomeScreen> with Provided, FirebaseMixin {
  @override
  Widget build(BuildContext context) {
    final textColor = mui.MacosTheme.brightnessOf(context).isDark
        ? Colors.white
        : Colors.black;
    return WindowTitleBarBox(
      child: MoveWindow(
        child: mui.Scaffold(
          sidebar: mui.Sidebar(
            minWidth: 225,
            startWidth: 225,
            builder: (context, scrollController) {
              return Column(
                children: [
                  ListTileTheme(
                    textColor: textColor,
                    child: ListTile(
                      leading: Icon(
                        CupertinoIcons.calendar,
                        color: mui.MacosColors.systemBlueColor,
                      ),
                      title: Text('Upcoming Calls'),
                      onTap: () {},
                    ),
                  ),
                  Divider(
                    height: 0,
                    color: mui.MacosTheme.of(context).dividerColor,
                  ),
                  ListTileTheme(
                    textColor: textColor,
                    child: ListTile(
                      leading: Icon(
                        CupertinoIcons.checkmark_seal,
                        color: mui.MacosColors.systemBlueColor,
                      ),
                      title: Text('Completed Calls'),
                      onTap: () {},
                    ),
                  ),
                  Divider(
                    height: 0,
                    color: mui.MacosTheme.of(context).dividerColor,
                  ),
                  Spacer(),
                  ListTileTheme(
                    textColor: textColor,
                    child: ListTile(
                      leading: UserAccountAvatar(),
                      title: Text(currentUser?.displayName ?? 'User'),
                      onTap: () {},
                    ),
                  ),
                ],
              );
            },
          ),
          children: [
            mui.ContentArea(
              builder: (context, scrollController) => Container(),
            ),
          ],
        ),
      ),
    );
  }
}
