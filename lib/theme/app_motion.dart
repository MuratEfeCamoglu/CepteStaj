import 'package:flutter/widgets.dart';

/// Motion tokens. One personality across the app: quick and calm —
/// things land softly, presses answer instantly, nothing loops forever.
///
/// Three durations, one signature curve for most motion ([emphasized]),
/// and a springy [settle] reserved for "you did something" feedback
/// (button release, counter pop).
class AppMotion {
  AppMotion._();

  static const quick = Duration(milliseconds: 120);
  static const standard = Duration(milliseconds: 280);
  static const slow = Duration(milliseconds: 600);

  /// Entrances and on-screen moves: fast start, gentle landing (MD3).
  static const emphasized = Cubic(0.05, 0.7, 0.1, 1);
  /// Small state changes (colors, pills).
  static const standardCurve = Cubic(0.2, 0, 0, 1);
  /// Release / pop: a little overshoot, then rest.
  static const settle = Cubic(0.175, 0.885, 0.32, 1.275);

  /// Stagger between sibling entrances (cards on a screen).
  static const stagger = Duration(milliseconds: 70);

  /// True when the user asked the OS to remove animations — every
  /// animated widget here then jumps straight to its end state.
  static bool reduced(BuildContext context) => MediaQuery.maybeDisableAnimationsOf(context) ?? false;

  static Duration of(BuildContext context, Duration d) => reduced(context) ? Duration.zero : d;
}
