import 'package:call_manager/firebase/firebase_mixin.dart';
import 'package:call_manager/provided.dart';
import 'package:call_manager/widgets/delete_calls_dialog.dart';
import 'package:call_manager/widgets/log_out_dialog.dart';
import 'package:call_manager/widgets/theme_icon.dart';
import 'package:call_manager/widgets/theme_switcher_dialog.dart';
import 'package:flutter/material.dart';
import 'package:groovin_material_icons/groovin_material_icons.dart';
import 'package:groovin_widgets/groovin_widgets.dart';
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:call_manager/utils/extensions.dart';

/// Represents the BottomSheet launched from the BottomAppBar
/// on the HomeScreen widget
class MenuBottomSheet extends StatefulWidget {
  @override
  _MenuBottomSheetState createState() => _MenuBottomSheetState();
}

class _MenuBottomSheetState extends State<MenuBottomSheet> with FirebaseMixin, Provided {
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
            Icons.clear_all,
            color: theme.brightness == Brightness.light
                ? Colors.black
                : Colors.white,
          ),
          onTap: () {
            showDialog(
              context: context,
              builder: (_) => DeleteCallsDialog(),
            );
          },
        ),
        StreamBuilder<ThemeMode>(
          stream: prefsService.themeModeSubject,
          initialData: prefsService.currentThemeMode,
          builder: (context, snapshot) {
            return ListTile(
              leading: ThemeIcon(),
              title: Text('Toggle app theme'),
              subtitle: Text(
                snapshot.data.format(),
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
        ),
      ],
    );
  }
}
