import 'package:flutter/material.dart';

/// Color tokens — "defter ve fosforlu kalem".
///
/// A cool paper-white page (not cream) with one ink color for the official
/// notebook side: the teal of the app icon. The private Günlüğüm side gets
/// its own warm coral, so the user can tell which layer they're in at a
/// glance (claude.md §5). The one loud color is [highlighter] — the
/// fluorescent marker a student drags over what matters — and it's spent
/// only on the few numbers/words that deserve it.
///
/// Every token that has to read well on both backgrounds is a getter driven
/// by [setDark], flipped once from [AppState] whenever the theme changes.
/// The accents brighten on the dark theme — the light-theme teal is too
/// dim to read as text or icons on a near-black page.
class AppColors {
  AppColors._();

  static bool _dark = false;
  static bool get isDark => _dark;
  static void setDark(bool value) => _dark = value;

  // ── Brand accents ─────────────────────────────────────────────────────
  /// Official side: ballpoint-teal, matches the launcher icon.
  static Color get ink => _dark ? const Color(0xFF34C6B0) : const Color(0xFF0B7A6D);
  static Color get inkDark => _dark ? const Color(0xFF1E9C8A) : const Color(0xFF075A50);
  /// Private side (Günlüğüm): warm coral.
  static Color get coral => _dark ? const Color(0xFFFF8566) : const Color(0xFFEC5F3F);
  /// Text/icons drawn on top of [ink] or [coral] fills.
  static Color get onInk => _dark ? const Color(0xFF06201C) : const Color(0xFFFFFFFF);
  static Color get onCoral => _dark ? const Color(0xFF2A0E06) : const Color(0xFFFFFFFF);
  /// Pure white for text on the deep gradient hero / Wrapped slides, which
  /// stay dark in both themes.
  static const onDeep = Color(0xFFFFFFFF);
  /// Fluorescent marker — signature accent. Always paired with dark text.
  static const highlighter = Color(0xFFE4F95B);
  static const onHighlighter = Color(0xFF1B2410);
  static Color get warning => _dark ? const Color(0xFFF2A945) : const Color(0xFFB8650A);
  static Color get checkGreen => _dark ? const Color(0xFF5ED38E) : const Color(0xFF2A8F52);
  static Color get danger => _dark ? const Color(0xFFFF6B6B) : const Color(0xFFD64545);

  // Secondary accents for stat tiles — each stat gets its own hue so the
  // home screen reads at a glance instead of as a wall of teal.
  static Color get violet => _dark ? const Color(0xFFA996FF) : const Color(0xFF6D4AE0);
  static Color get sky => _dark ? const Color(0xFF6CB8FF) : const Color(0xFF2F74D0);
  static Color get amber => _dark ? const Color(0xFFFFC857) : const Color(0xFFC98400);
  static Color get rose => _dark ? const Color(0xFFFF7DA5) : const Color(0xFFD63E72);

  /// Deep teal gradient behind the home hero card — dark in both themes so
  /// the progress ring and the highlighter number always pop.
  static LinearGradient get heroGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: _dark
            ? const [Color(0xFF0F4D45), Color(0xFF0B2F35), Color(0xFF14243A)]
            : const [Color(0xFF0B7A6D), Color(0xFF075A50), Color(0xFF123F57)],
      );

  // ── Backgrounds ───────────────────────────────────────────────────────
  static Color get outerBg => _dark ? const Color(0xFF0B1013) : const Color(0xFFF3F5F7);
  static Color get screenBg => _dark ? const Color(0xFF0B1013) : const Color(0xFFF3F5F7);
  // Card/elevated surface — reads as a card by tone + a soft shadow
  // ([cardShadow]), never by an outline.
  static Color get cardBg => _dark ? const Color(0xFF151C21) : const Color(0xFFFFFFFF);
  // Sunken tonal fill — progress tracks, unselected pills, inline chips.
  static Color get sunkenBg => _dark ? const Color(0xFF212A30) : const Color(0xFFE8ECEF);

  // ── Text ──────────────────────────────────────────────────────────────
  static Color get textPrimary => _dark ? const Color(0xFFECF1F3) : const Color(0xFF12181B);
  static Color get textMuted => _dark ? const Color(0xFFA2B0B6) : const Color(0xFF56636A);
  static Color get textFaint => _dark ? const Color(0xFF66767E) : const Color(0xFF98A4AA);

  // ── Borders ─────────────────────────────────────────────────────────
  // Reserved for hairline dividers and functional outlines only — never
  // used to box in a card.
  static Color get border => _dark ? const Color(0xFF253038) : const Color(0xFFE1E6E9);
  static Color get borderLight => _dark ? const Color(0xFF36444D) : const Color(0xFFC8D1D6);

  // ── Tints ─────────────────────────────────────────────────────────────
  static Color get inkLight => _dark ? const Color(0xFF113832) : const Color(0xFFDCF1EC);
  /// Private-side tonal backgrounds/chips.
  static Color get coralLight => _dark ? const Color(0xFF3B241D) : const Color(0xFFFFE5DC);

  /// A soft tinted background for [color] — stat tiles, icon wells.
  static Color tint(Color color) => color.withValues(alpha: _dark ? 0.18 : 0.11);

  /// Soft, two-layer elevation for cards and the primary button — modern
  /// "floating paper" instead of flat tone-on-tone. On the dark theme a
  /// shadow barely shows, so cards get a faint top highlight instead.
  static List<BoxShadow> get cardShadow => _dark
      ? const [BoxShadow(color: Color(0x59000000), blurRadius: 16, offset: Offset(0, 6))]
      : const [
          BoxShadow(color: Color(0x0A12181B), blurRadius: 2, offset: Offset(0, 1)),
          BoxShadow(color: Color(0x1212181B), blurRadius: 22, offset: Offset(0, 10)),
        ];
}
