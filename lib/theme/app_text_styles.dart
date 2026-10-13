import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Typography tokens.
///
/// - [disp] / [head]: Bricolage Grotesque — a grotesk with a bit of ink-trap
///   character, set tight and heavy for numbers and screen titles.
/// - [body] / [tab] / [label]: Inter — neutral, highly legible body copy.
/// - [hand]: Caveat handwriting — only on the private Günlüğüm side, where
///   the app should feel like your own diary rather than a form.
///
/// Colors default to the current theme's text tokens via `??` (not a
/// literal default value) because [AppColors.textPrimary] etc. are
/// theme-aware getters, not compile-time constants.
class AppTextStyles {
  AppTextStyles._();

  static TextStyle disp({
    double fontSize = 30,
    Color? color,
    double? height,
    FontWeight weight = FontWeight.w800,
  }) =>
      TextStyle(
        fontFamily: 'BricolageGrotesque',
        fontSize: fontSize,
        fontWeight: weight,
        color: color ?? AppColors.textPrimary,
        height: height ?? 1.1,
        letterSpacing: -0.03 * fontSize,
      );

  static TextStyle head({
    double fontSize = 17,
    Color? color,
    double? height,
  }) =>
      TextStyle(
        fontFamily: 'BricolageGrotesque',
        fontSize: fontSize,
        fontWeight: FontWeight.w700,
        color: color ?? AppColors.textPrimary,
        height: height,
        letterSpacing: -0.02 * fontSize,
      );

  static TextStyle body({
    double fontSize = 15,
    FontWeight weight = FontWeight.w400,
    Color? color,
    double? height,
  }) =>
      TextStyle(
        fontFamily: 'Inter',
        fontSize: fontSize,
        fontWeight: weight,
        color: color ?? AppColors.textPrimary,
        height: height,
        letterSpacing: -0.1,
      );

  /// Small uppercase section label ("HIZLI SAYAÇLAR"), tracked out.
  static TextStyle label({Color? color}) => TextStyle(
        fontFamily: 'Inter',
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: color ?? AppColors.textMuted,
        letterSpacing: 1.1,
      );

  /// Handwriting — personal (Günlüğüm) headings and prompts only.
  static TextStyle hand({
    double fontSize = 24,
    Color? color,
    FontWeight weight = FontWeight.w700,
  }) =>
      TextStyle(
        fontFamily: 'Caveat',
        fontSize: fontSize,
        fontWeight: weight,
        color: color ?? AppColors.textPrimary,
        height: 1.05,
      );

  static TextStyle tab({
    Color? color,
    FontWeight weight = FontWeight.w400,
  }) =>
      TextStyle(
        fontFamily: 'Inter',
        fontSize: 11,
        fontWeight: weight,
        color: color ?? AppColors.textMuted,
      );
}
