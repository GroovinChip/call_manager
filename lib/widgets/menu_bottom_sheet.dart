import 'package:call_manager/firebase/firebase_mixin.dart';
import 'package:call_manager/provided.dart';
import 'package:call_manager/services/prefs_service.dart';
import 'package:call_manager/widgets/dialogs/delete_all_dialog.dart';
import 'package:call_manager/widgets/dialogs/log_out_dialog.dart';
import 'package:call_manager/widgets/dialogs/theme_switcher_dialog.dart';
import 'package:call_manager/widgets/theme_icon.dart';
import 'package:call_manager/widgets/user_account_avatar.dart';
import 'package:flutter/material.dart';
import 'package:groovin_widgets/groovin_widgets.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:call_manager/utils/extensions.dart';
import 'package:wiredash/wiredash.dart';

/// Represents the BottomSheet launched from the BottomAppBar
/// on the HomeScreen widget
class MenuBottomSheet extends StatefulWidget {
  @override
  _MenuBottomSheetState createState() => _MenuBottomSheetState();
}

class _MenuBottomSheetState extends State<MenuBottomSheet>
    with FirebaseMixin, Provided {
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

  @override
  // ignore: long-method
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: ModalDrawerHandle(),
          ),
          ListTile(
            leading: UserAccountAvatar(),
            title: currentUser!.displayName != null
                ? Text(currentUser!.displayName ?? 'user')
                : Text(currentUser!.email!),
            subtitle: currentUser!.displayName != null
                ? Text(currentUser!.email ?? 'email')
                : null,
            trailing: TextButton(
              child: Text('LOG OUT'),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => LogOutDialog(),
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
              MdiIcons.deleteSweepOutline,
              color: theme.brightness == Brightness.light
                  ? Colors.black
                  : Colors.white,
            ),
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => DeleteAllDialog(),
              );
            },
          ),
          StreamBuilder<Preferences>(
            stream: prefsService.preferencesSubject,
            initialData: prefsService.preferencesSubject.value,
            builder: (context, snapshot) {
              return ListTile(
                leading: ThemeIcon(),
                title: Text('Toggle app theme'),
                subtitle: Text(
                  snapshot.data!.themeMode.format(),
                ),
                onTap: () => showDialog(
                  context: context,
                  builder: (_) => ThemeSwitcherDialog(),
                ),
              );
            },
          ),
          Divider(
            color: Colors.grey,
            height: 0.0,
          ),
          ListTile(
            leading: Icon(
              MdiIcons.github,
              color: theme.brightness == Brightness.light
                  ? Colors.black
                  : Colors.white,
            ),
            title: Text('Call Manager v${_packageInfo.version}'),
            subtitle: Text('View source code'),
            onTap: () {
              launch('https:github.com/GroovinChip/CallManager');
            },
          ),
          ListTile(
            leading: Icon(MdiIcons.thoughtBubbleOutline),
            title: Text('Send Feedback'),
            onTap: () => Wiredash.of(context)!
              ..setBuildProperties(
                buildVersion: _packageInfo.version,
                buildNumber: _packageInfo.buildNumber,
              )
              ..show(),
          ),
        ],
      ),
    );
  }
}
