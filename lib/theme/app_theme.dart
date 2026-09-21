import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_text_styles.dart';

class AppTheme {
  AppTheme._();

  static ThemeData _build(Brightness brightness) {
    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: AppColors.outerBg,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.ink,
        brightness: brightness,
        primary: AppColors.ink,
        surface: AppColors.cardBg,
      ),
      fontFamily: GoogleFonts.inter().fontFamily,
    );

    return base.copyWith(
      textTheme: base.textTheme.apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.screenBg,
        surfaceTintColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: AppTextStyles.head(fontSize: 17),
      ),
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      dividerColor: AppColors.border,
      dividerTheme: DividerThemeData(color: AppColors.border, thickness: 1, space: 1),
      // Borderless, tonal-fill outlined buttons — keeps the "no card
      // outlines" rule from leaking back in through Material's default
      // colored OutlinedButton side.
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.sunkenBg,
          foregroundColor: AppColors.textPrimary,
          side: BorderSide.none,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.card)),
          textStyle: AppTextStyles.body(fontSize: 14, weight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.pill)),
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(builders: {
        TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      }),
    );
  }

  /// Call [AppColors.setDark] with the desired mode *before* building the
  /// theme that matches it — the color tokens below read that flag.
  static ThemeData light() {
    AppColors.setDark(false);
    return _build(Brightness.light);
  }

  static ThemeData dark() {
    AppColors.setDark(true);
    return _build(Brightness.dark);
  }
}
