import 'package:flutter/material.dart';

// ignore_for_file: member-ordering
// ignore: avoid_classes_with_only_static_members
class AppColors {
  static const Color primaryColor = Color(0xff2962ff);
  static const Color accentColor = Color(0xff5784FF);
  static const Color cardColorLight = Color(0xffD1DDFF);
  static const Color cardColorDark = Color(0xff283C87);
  static Color canvasColorDark = Colors.grey.shade900;
  static Color? bottomAppColorDark = Color.lerp(
    Colors.grey.shade900,
    Colors.grey.shade800,
    .10,
  );
  static Color outlinedButtonColorLight = Colors.grey.shade800;
  static Color iconColorLight = Colors.grey.shade800;
  static Color iconColorDark = Colors.white;
  static Color dividerColorLight = Colors.grey.shade800;
}
