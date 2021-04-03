import 'package:flutter/material.dart';

// ignore_for_file: member-ordering
// ignore: avoid_classes_with_only_static_members
class AppColors {
  static Color primaryColor = Color(0xff2962ff);
  static Color accentColor = Color(0xff5784FF);
  static Color cardColorLight = Color(0xffD1DDFF);
  static Color cardColorDark = Color(0xff283C87);
  static Color canvasColorDark = Colors.grey.shade900;
  static Color bottomAppColorDark = Color.lerp(
    Colors.grey.shade900,
    Colors.grey.shade800,
    .10,
  );
  static Color outlinedButtonColorLight = Colors.grey.shade800;
  static Color iconColorLight = Colors.grey.shade800;
  static Color iconColorDark = Colors.white;
  static Color dividerColorLight = Colors.grey.shade800;
}
