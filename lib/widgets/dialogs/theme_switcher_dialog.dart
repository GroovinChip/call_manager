import 'package:call_manager/provided.dart';
import 'package:flutter/material.dart';

class ThemeSwitcherDialog extends StatefulWidget {
  @override
  _ThemeSwitcherDialogState createState() => _ThemeSwitcherDialogState();
}

class _ThemeSwitcherDialogState extends State<ThemeSwitcherDialog>
    with Provided {
  void _onThemeSelection(ThemeMode themeMode) {
    prefsService.setThemeModePref(themeMode);
    setState(() {});
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      backgroundColor: Theme.of(context).canvasColor,
      title: Text('Change app theme'),
      children: [
        RadioListTile(
          title: Text('System theme'),
          value: ThemeMode.system,
          selected:
              prefsService.currentThemeMode == ThemeMode.system ? true : false,
          activeColor: Theme.of(context).accentColor,
          groupValue: prefsService.currentThemeMode,
          onChanged: _onThemeSelection,
        ),
        RadioListTile(
          title: Text('Light theme'),
          value: ThemeMode.light,
          selected:
              prefsService.currentThemeMode == ThemeMode.light ? true : false,
          activeColor: Theme.of(context).accentColor,
          groupValue: prefsService.currentThemeMode,
          onChanged: _onThemeSelection,
        ),
        RadioListTile(
          title: Text('Dark theme'),
          value: ThemeMode.dark,
          selected:
              prefsService.currentThemeMode == ThemeMode.dark ? true : false,
          activeColor: Theme.of(context).accentColor,
          groupValue: prefsService.currentThemeMode,
          onChanged: _onThemeSelection,
        ),
      ],
    );
  }
}
