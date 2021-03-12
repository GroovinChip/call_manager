import 'package:call_manager/theme/app_themes.dart';
import 'package:flutter/material.dart';

class ThemeIcon extends StatefulWidget {
  ThemeIcon({Key key}) : super(key: key);

  @override
  _ThemeIconState createState() => _ThemeIconState();
}

class _ThemeIconState extends State<ThemeIcon> {
  IconData _themeIconData;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (AppThemes.isDarkTheme(context)) {
      setState(() => _themeIconData = Icons.wb_sunny_outlined);
    } else {
      setState(() => _themeIconData = Icons.nightlight_round);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Icon(
      _themeIconData,
      color: Theme.of(context).iconTheme.color,
    );
  }
}
