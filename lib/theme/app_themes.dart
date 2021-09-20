import 'package:call_manager/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

// ignore: avoid_classes_with_only_static_members
class AppThemes {
  static ThemeData lightTheme() {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: AppColors.primaryColor,
      accentColor: AppColors.accentColor,
      textTheme: GoogleFonts.sourceSansProTextTheme(
        ThemeData.light().textTheme,
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: ThemeData.light().canvasColor,
        //foregroundColor: Colors.black,
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        backwardsCompatibility: false,
      ),
      cardColor: AppColors.cardColorLight,
      buttonTheme: const ButtonThemeData(
        buttonColor: AppColors.primaryColor,
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: AppColors.outlinedButtonColorLight,
          ),
          shape: const StadiumBorder(),
          primary: AppColors.outlinedButtonColorLight,
        ),
      ),
      iconTheme: IconThemeData(
        color: AppColors.iconColorLight,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
      ),
      timePickerTheme: TimePickerThemeData(
        backgroundColor: ThemeData.light().canvasColor,
      ),
      dividerColor: AppColors.dividerColorLight,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }

  // ignore: long-method
  static ThemeData darkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      canvasColor: AppColors.canvasColorDark,
      primaryColor: AppColors.primaryColor,
      accentColor: AppColors.accentColor,
      textTheme: GoogleFonts.sourceSansProTextTheme(
        ThemeData.dark().textTheme,
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: AppColors.canvasColorDark,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        backwardsCompatibility: false,
      ),
      buttonTheme: const ButtonThemeData(
        buttonColor: AppColors.primaryColor,
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(
            color: Colors.white,
          ),
          shape: const StadiumBorder(),
          primary: Colors.white,
        ),
      ),
      cardColor: AppColors.cardColorDark,
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
      ),
      iconTheme: IconThemeData(
        color: AppColors.iconColorDark,
      ),
      dividerColor: Colors.white,
      bottomAppBarColor: AppColors.bottomAppColorDark,
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      timePickerTheme: TimePickerThemeData(
        backgroundColor: AppColors.canvasColorDark,
        hourMinuteColor: Colors.grey.shade800,
        //dayPeriodColor: Colors.grey.shade900,
      ),
      dialogBackgroundColor: AppColors.canvasColorDark,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }

  static bool isDarkTheme(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.dark) {
      return true;
    } else {
      return false;
    }
  }

  // lifted from Mike's flex_color_scheme package, slightly modified for my use
  static SystemUiOverlayStyle themedSystemNavigationBar(
    BuildContext context, {

    /// Opacity value for the system navigation bar.
    ///
    /// Use and support for this opacity value is EXPERIMENTAL, it ONLY
    /// works on Android API 30 (=Android 11) or higher. For more information
    /// and complete example of how it can be used, please see:
    /// https://github.com/rydmike/sysnavbar
    double opacity = 1,

    /// Brightness used if context is null, mostly used for testing.
    Brightness nullContextBrightness = Brightness.light,

    /// Background used if context is null, mostly used for testing. If null,
    /// then black for dark brightness, and white for light brightness.
    Color? nullContextBackground,
  }) {
    // ignore: parameter_assignments
    if (opacity < 0) opacity = 0;
    // ignore: parameter_assignments
    if (opacity > 1) opacity = 1;

    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    // If nullContextBackground is null use black for dark, and white for light.
    nullContextBackground ??= isDark ? Colors.black : Colors.white;

    final Color background = Theme.of(context).canvasColor;

    // The used system navigation bar divider colors below were tuned to
    // fit well with most color schemes and possible surface branding.
    // Using the theme divider color does not work as the system call does
    // not use the alpha channel value in the passed in color, default divider
    // color of the theme uses alpha, using it will thus not look good.
    //
    // A future modification could expose the divider color, but then you
    // could just as well just copy and use this overlay style directly in your
    // AnnotatedRegion if this does not produce the desired result.
    return SystemUiOverlayStyle(
      systemNavigationBarColor: background.withOpacity(opacity),
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness:
          isDark ? Brightness.light : Brightness.dark,
      statusBarColor: Colors.transparent,
      statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
    );
  }
}
