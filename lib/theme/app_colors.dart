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
  /// Official side: ballpoint-teal, matches the launcher icon.
  static const ink = Color(0xFF0B7468);
  static const inkDark = Color(0xFF07554C);
  /// Private side (Günlüğüm): warm coral.
  static const coral = Color(0xFFEE6545);
  static const onInk = Color(0xFFFFFFFF);
  /// Fluorescent marker — signature accent. Always paired with dark text.
  static const highlighter = Color(0xFFE4F95B);
  static const onHighlighter = Color(0xFF1B2410);
  static const warning = Color(0xFFB4690E);
  static const checkGreen = Color(0xFF2E9457);

  // ── Backgrounds ───────────────────────────────────────────────────────
  // Page background — cool paper white / blue-black.
  static Color get outerBg => _dark ? const Color(0xFF0F1416) : const Color(0xFFF4F6F8);
  static Color get screenBg => _dark ? const Color(0xFF0F1416) : const Color(0xFFF4F6F8);
  // Card/elevated surface — reads as a card by tone + a soft shadow
  // ([cardShadow]), never by an outline.
  static Color get cardBg => _dark ? const Color(0xFF182024) : const Color(0xFFFFFFFF);
  // Sunken tonal fill — progress tracks, unselected pills, inline chips.
  static Color get sunkenBg => _dark ? const Color(0xFF222B30) : const Color(0xFFE9EDF0);

  // ── Text ──────────────────────────────────────────────────────────────
  static Color get textPrimary => _dark ? const Color(0xFFEEF2F3) : const Color(0xFF13191C);
  static Color get textMuted => _dark ? const Color(0xFF9AA8AE) : const Color(0xFF59666C);
  static Color get textFaint => _dark ? const Color(0xFF56656C) : const Color(0xFF9AA6AC);

  // ── Borders ─────────────────────────────────────────────────────────
  // Reserved for hairline dividers and functional outlines only — never
  // used to box in a card.
  static Color get border => _dark ? const Color(0xFF26313A) : const Color(0xFFE2E7EA);
  static Color get borderLight => _dark ? const Color(0xFF34424A) : const Color(0xFFC9D2D7);

  // ── Tints ─────────────────────────────────────────────────────────────
  static Color get inkLight => _dark ? const Color(0xFF12322F) : const Color(0xFFDDF0EC);
  /// Private-side tonal backgrounds/chips.
  static Color get coralLight => _dark ? const Color(0xFF3A231D) : const Color(0xFFFFE6DE);

  /// Soft, two-layer elevation for cards and the primary button — modern
  /// "floating paper" instead of flat tone-on-tone.
  static List<BoxShadow> get cardShadow => _dark
      ? const [BoxShadow(color: Color(0x66000000), blurRadius: 18, offset: Offset(0, 8))]
      : const [
          BoxShadow(color: Color(0x0D13191C), blurRadius: 2, offset: Offset(0, 1)),
          BoxShadow(color: Color(0x1413191C), blurRadius: 24, offset: Offset(0, 10)),
        ];
}
