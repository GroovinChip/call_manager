import 'package:call_manager/provided.dart';
import 'package:flutter/material.dart';

class ThemeSwitcherDialog extends StatefulWidget {
  const ThemeSwitcherDialog({Key? key}) : super(key: key);
  @override
  _ThemeSwitcherDialogState createState() => _ThemeSwitcherDialogState();
}

class _ThemeSwitcherDialogState extends State<ThemeSwitcherDialog>
    with Provided {
  void _onThemeSelection(ThemeMode themeMode) {
    prefsService.setThemeModePref(themeMode);
    if (themeMode == ThemeMode.system &&
        Theme.of(context).brightness == Brightness.light) {
      prefsService.setBrightnessPref(Brightness.light);
    }
    if (themeMode == ThemeMode.system &&
        Theme.of(context).brightness == Brightness.dark) {
      prefsService.setBrightnessPref(Brightness.light);
    }
    if (themeMode == ThemeMode.light) {
      prefsService.setBrightnessPref(Brightness.light);
    }

    if (themeMode == ThemeMode.dark) {
      prefsService.setBrightnessPref(Brightness.dark);
    }

    // ignore: no-empty-block
    setState(() {});

    Navigator.of(context).pop(themeMode);
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      backgroundColor: Theme.of(context).canvasColor,
      title: const Text('Change app theme'),
      children: [
        RadioListTile<ThemeMode>(
          title: const Text('System theme'),
          value: ThemeMode.system,
          selected:
              prefsService.currentThemeMode == ThemeMode.system ? true : false,
          activeColor: Theme.of(context).accentColor,
          groupValue: prefsService.currentThemeMode,
          onChanged: (value) => _onThemeSelection(value!),
        ),
        RadioListTile<ThemeMode>(
          title: const Text('Light theme'),
          value: ThemeMode.light,
          selected:
              prefsService.currentThemeMode == ThemeMode.light ? true : false,
          activeColor: Theme.of(context).accentColor,
          groupValue: prefsService.currentThemeMode,
          onChanged: (value) => _onThemeSelection(value!),
        ),
        RadioListTile<ThemeMode>(
          title: const Text('Dark theme'),
          value: ThemeMode.dark,
          selected:
              prefsService.currentThemeMode == ThemeMode.dark ? true : false,
          activeColor: Theme.of(context).accentColor,
          groupValue: prefsService.currentThemeMode,
          onChanged: (value) => _onThemeSelection(value!),
        ),
      ],
    );
  }
}
