import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;

import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_text_styles.dart';

/// Material theme built from the tokens in [AppColors] / [AppTextStyles],
/// so stock widgets (dialogs, text fields, switches, snackbars, sheets)
/// match the custom ones without per-screen styling.
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
        onPrimary: AppColors.onInk,
        secondary: AppColors.coral,
        surface: AppColors.cardBg,
        onSurface: AppColors.textPrimary,
        error: const Color(0xFFD64545),
      ),
      fontFamily: 'Inter',
    );

    final fieldRadius = BorderRadius.circular(AppRadius.card);
    final buttonShape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.pill));

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
        titleTextStyle: AppTextStyles.head(fontSize: 18),
      ),
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      dividerColor: AppColors.border,
      dividerTheme: DividerThemeData(color: AppColors.border, thickness: 1, space: 1),

      // ── Buttons ─────────────────────────────────────────────────────────
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.ink,
          foregroundColor: AppColors.onInk,
          minimumSize: const Size(64, 48),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
          shape: buttonShape,
          textStyle: AppTextStyles.body(fontSize: 15, weight: FontWeight.w600),
        ),
      ),
      // Borderless, tonal-fill outlined buttons — keeps the "no card
      // outlines" rule from leaking back in through Material's default
      // colored OutlinedButton side.
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.sunkenBg,
          foregroundColor: AppColors.textPrimary,
          side: BorderSide.none,
          minimumSize: const Size(64, 48),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: buttonShape,
          textStyle: AppTextStyles.body(fontSize: 14, weight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.ink,
          minimumSize: const Size(48, 44),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shape: buttonShape,
          textStyle: AppTextStyles.body(fontSize: 14, weight: FontWeight.w600),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(minimumSize: const Size(44, 44)),
      ),

      // ── Inputs ──────────────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.sunkenBg,
        hintStyle: AppTextStyles.body(color: AppColors.textFaint),
        labelStyle: AppTextStyles.body(color: AppColors.textMuted),
        floatingLabelStyle: AppTextStyles.body(color: AppColors.ink, weight: FontWeight.w600),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: fieldRadius, borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: fieldRadius, borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: fieldRadius,
          borderSide: const BorderSide(color: AppColors.ink, width: 1.6),
        ),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: AppColors.ink,
        selectionColor: AppColors.highlighter.withValues(alpha: 0.7),
        selectionHandleColor: AppColors.ink,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? AppColors.onInk : AppColors.textFaint,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? AppColors.ink : AppColors.sunkenBg,
        ),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.ink,
        inactiveTrackColor: AppColors.sunkenBg,
        thumbColor: AppColors.ink,
        trackHeight: 6,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: AppColors.ink,
        linearTrackColor: AppColors.sunkenBg,
        borderRadius: BorderRadius.circular(999),
      ),

      // ── Overlays ────────────────────────────────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.cardBg,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.cardLarge)),
        titleTextStyle: AppTextStyles.head(fontSize: 20),
        contentTextStyle: AppTextStyles.body(fontSize: 15, color: AppColors.textMuted, height: 1.4),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.cardBg,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        dragHandleColor: AppColors.borderLight,
        dragHandleSize: const Size(36, 4),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.cardLarge)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.isDark ? const Color(0xFFEEF2F3) : const Color(0xFF13191C),
        contentTextStyle: AppTextStyles.body(
          fontSize: 14,
          weight: FontWeight.w500,
          color: AppColors.isDark ? const Color(0xFF13191C) : const Color(0xFFEEF2F3),
        ),
        actionTextColor: AppColors.highlighter,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.card)),
        insetPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.sunkenBg,
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.pill)),
        labelStyle: AppTextStyles.body(fontSize: 13, weight: FontWeight.w500),
      ),
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.card)),
        iconColor: AppColors.textMuted,
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
