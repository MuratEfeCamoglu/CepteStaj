import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Typography tokens. Plus Jakarta Sans for display/headings, Inter for
/// body copy and tab labels — matches the design doc's `.disp` / `.head`
/// / `.tab` classes.
///
/// Colors default to the current theme's text tokens via `??` (not a
/// literal default value) because [AppColors.textPrimary] etc. are
/// theme-aware getters, not compile-time constants.
class AppTextStyles {
  AppTextStyles._();

  static TextStyle disp({
    double fontSize = 28,
    Color? color,
    double? height,
  }) =>
      GoogleFonts.plusJakartaSans(
        fontSize: fontSize,
        fontWeight: FontWeight.w700,
        color: color ?? AppColors.textPrimary,
        height: height,
        letterSpacing: -0.4,
      );

  static TextStyle head({
    double fontSize = 17,
    Color? color,
    double? height,
  }) =>
      GoogleFonts.plusJakartaSans(
        fontSize: fontSize,
        fontWeight: FontWeight.w600,
        color: color ?? AppColors.textPrimary,
        height: height,
        letterSpacing: -0.2,
      );

  static TextStyle body({
    double fontSize = 15,
    FontWeight weight = FontWeight.w400,
    Color? color,
    double? height,
  }) =>
      GoogleFonts.inter(
        fontSize: fontSize,
        fontWeight: weight,
        color: color ?? AppColors.textPrimary,
        height: height,
      );

  static TextStyle tab({
    Color? color,
    FontWeight weight = FontWeight.w400,
  }) =>
      GoogleFonts.inter(
        fontSize: 11,
        fontWeight: weight,
        color: color ?? AppColors.textMuted,
      );
}
