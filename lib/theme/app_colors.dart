import 'package:flutter/material.dart';

/// Color tokens for the modernist-minimalist visual design.
///
/// Neutral (near-white / near-black) base with a single accent — teal
/// "ink" for the official notebook side. The private journal side
/// (Günlüğüm) is told apart only by a quieter secondary tone ("clay"),
/// never by loud color blocking. Surfaces carry no borders: a card reads
/// as a card purely by sitting on a slightly different tone than the
/// page behind it, plus generous whitespace.
///
/// Surface/text/border tokens are getters driven by [setDark], flipped
/// once from [AppState] whenever the theme setting changes — every
/// screen reads them fresh on each rebuild, so no widget needs to know
/// which mode is active.
class AppColors {
  AppColors._();

  static bool _dark = false;
  static bool get isDark => _dark;
  static void setDark(bool value) => _dark = value;

  // ── Brand accents — same in both themes ──────────────────────────────
  static const ink = Color(0xFF0C6B66);
  static const inkDark = Color(0xFF094F4B);
  static const terra = Color(0xFFA8592E);
  static const onInk = Color(0xFFFFFFFF);
  static const warning = Color(0xFF8A6100);
  static const checkGreen = Color(0xFF3F7A2E);

  // ── Backgrounds ───────────────────────────────────────────────────────
  // Page background — flat, neutral, almost-white / almost-black.
  static Color get outerBg => _dark ? const Color(0xFF121212) : const Color(0xFFFAFAF8);
  static Color get screenBg => _dark ? const Color(0xFF121212) : const Color(0xFFFAFAF8);
  // Card/elevated surface — one tone lighter (dark) / whiter (light) than
  // the page, no border needed to read as a distinct surface.
  static Color get cardBg => _dark ? const Color(0xFF1C1C1B) : const Color(0xFFFFFFFF);
  // Sunken tonal fill — progress tracks, unselected pills, inline chips.
  static Color get sunkenBg => _dark ? const Color(0xFF242423) : const Color(0xFFF0F0EC);

  // ── Text ──────────────────────────────────────────────────────────────
  static Color get textPrimary => _dark ? const Color(0xFFF3F2EE) : const Color(0xFF1A1A18);
  static Color get textMuted => _dark ? const Color(0xFFA3A29B) : const Color(0xFF6C6B65);
  static Color get textFaint => _dark ? const Color(0xFF5C5B56) : const Color(0xFFA6A59D);

  // ── Borders ─────────────────────────────────────────────────────────
  // Reserved for hairline dividers and functional outlines only — never
  // used to box in a card.
  static Color get border => _dark ? const Color(0xFF2A2A28) : const Color(0xFFE9E8E3);
  static Color get borderLight => _dark ? const Color(0xFF3C3C38) : const Color(0xFFD4D3CB);

  // ── Terra tint (private-side tonal backgrounds/chips) ────────────────
  static Color get terraLight => _dark ? const Color(0xFF35271C) : const Color(0xFFF2E4D8);
}
