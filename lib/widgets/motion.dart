import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import '../theme/app_motion.dart';

/// A tappable surface that dips slightly while pressed and springs back on
/// release — the app's one button feel. Uses [InkWell] underneath so focus,
/// keyboard activation and semantics behave like any Material button.
class Pressable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final BorderRadius borderRadius;
  final double pressedScale;
  final bool haptic;

  const Pressable({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.borderRadius = const BorderRadius.all(Radius.circular(999)),
    this.pressedScale = 0.96,
    this.haptic = true,
  });

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final reduced = AppMotion.reduced(context);
    return AnimatedScale(
      scale: _pressed && !reduced ? widget.pressedScale : 1,
      duration: _pressed ? AppMotion.quick : AppMotion.standard,
      curve: _pressed ? Curves.easeOut : AppMotion.settle,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: widget.borderRadius,
          splashFactory: NoSplash.splashFactory,
          highlightColor: Colors.transparent,
          onHighlightChanged: (v) => setState(() => _pressed = v),
          onTap: widget.onTap == null
              ? null
              : () {
                  if (widget.haptic) HapticFeedback.selectionClick();
                  widget.onTap!();
                },
          onLongPress: widget.onLongPress,
          child: widget.child,
        ),
      ),
    );
  }
}

/// Fades a child in while it rises a few pixels — the single entrance
/// pattern used across screens. [index] staggers siblings so a screen
/// assembles top-to-bottom instead of popping in at once. Plays once,
/// on first build; no timers, so tests can simply pumpAndSettle.
class Entrance extends StatelessWidget {
  final Widget child;
  final int index;
  final double offsetY;

  const Entrance({super.key, required this.child, this.index = 0, this.offsetY = 14});

  @override
  Widget build(BuildContext context) {
    if (AppMotion.reduced(context)) return child;
    final delay = AppMotion.stagger * index;
    final total = delay + const Duration(milliseconds: 460);
    final start = delay.inMilliseconds / total.inMilliseconds;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: total,
      curve: Interval(start, 1, curve: AppMotion.emphasized),
      builder: (context, t, child) => Opacity(
        opacity: t.clamp(0, 1),
        child: Transform.translate(offset: Offset(0, (1 - t) * offsetY), child: child),
      ),
      child: child,
    );
  }
}

/// The signature: a fluorescent-marker stroke swept under [child], the way
/// a student highlights the one line that matters. Draws itself in once,
/// after [delay]. On the dark theme the stroke is skipped (it reads as
/// muddy olive there) and callers color the text in highlighter ink.
class HighlighterMark extends StatelessWidget {
  final Widget child;
  final Duration delay;
  final Color color;
  /// How much of the child's height the stroke covers, from the bottom.
  final double coverage;

  const HighlighterMark({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.color = AppColors.highlighter,
    this.coverage = 0.55,
  });

  @override
  Widget build(BuildContext context) {
    final reduced = AppMotion.reduced(context);
    const sweep = Duration(milliseconds: 520);
    final total = reduced ? Duration.zero : delay + sweep;
    final start = total == Duration.zero ? 0.0 : delay.inMilliseconds / total.inMilliseconds;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: reduced ? 1 : 0, end: 1),
      duration: total,
      curve: Interval(start, 1, curve: Curves.easeOutCubic),
      builder: (context, t, child) => CustomPaint(
        painter: _MarkerPainter(progress: t, color: color, coverage: coverage),
        child: child,
      ),
      child: Padding(padding: const EdgeInsets.symmetric(horizontal: 6), child: child),
    );
  }
}

class _MarkerPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double coverage;

  _MarkerPainter({required this.progress, required this.color, required this.coverage});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0 || AppColors.isDark) return;
    final h = size.height * coverage;
    final top = size.height - h - size.height * 0.04;
    final w = size.width * progress;
    // Slightly slanted, with a chiselled start and a softer tail — reads as
    // a marker stroke rather than a rectangle.
    final path = Path()
      ..moveTo(2, top + 3)
      ..lineTo(w, top)
      ..quadraticBezierTo(w + 3, top + h / 2, w - 1, top + h)
      ..lineTo(0, top + h + 2)
      ..quadraticBezierTo(-2, top + h / 2, 2, top + 3)
      ..close();
    canvas.drawPath(path, Paint()..color = color.withValues(alpha: 0.85));
  }

  @override
  bool shouldRepaint(covariant _MarkerPainter old) =>
      old.progress != progress || old.color != color || old.coverage != coverage;
}

/// An integer that counts toward [value] — from 0 on first show, and from
/// the previous value whenever it changes.
class CountUpText extends StatelessWidget {
  final int value;
  final TextStyle style;
  final Duration duration;

  const CountUpText({super.key, required this.value, required this.style, this.duration = const Duration(milliseconds: 900)});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(end: value.toDouble()),
      duration: AppMotion.of(context, duration),
      curve: Curves.easeOutCubic,
      builder: (context, v, _) => Text(
        '${v.round()}',
        style: style.copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
      ),
    );
  }
}

/// Gives [child] a quick scale "pop" each time [trigger] changes — e.g. a
/// counter that just went up by one.
class PopOnChange extends StatefulWidget {
  final Object? trigger;
  final Widget child;
  final double amount;

  const PopOnChange({super.key, required this.trigger, required this.child, this.amount = 0.28});

  @override
  State<PopOnChange> createState() => _PopOnChangeState();
}

class _PopOnChangeState extends State<PopOnChange> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 360));

  @override
  void didUpdateWidget(covariant PopOnChange oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.trigger != widget.trigger && !AppMotion.reduced(context)) {
      _c.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) {
        // Up fast, settle back — a half sine shaped by an ease-out.
        final t = Curves.easeOut.transform(_c.value);
        return Transform.scale(scale: 1 + widget.amount * math.sin(t * math.pi), child: child);
      },
      child: widget.child,
    );
  }
}

/// Springs [child] in from a smaller scale the first time it's built — for
/// a badge or tick that appears as a reward ("Hedef tamam").
class PopIn extends StatelessWidget {
  final Widget child;
  const PopIn({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    if (AppMotion.reduced(context)) return child;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 420),
      curve: AppMotion.settle,
      builder: (context, t, child) => Opacity(
        opacity: t.clamp(0, 1),
        child: Transform.scale(scale: 0.6 + 0.4 * t, child: child),
      ),
      child: child,
    );
  }
}

/// Shakes [child] side to side each time [trigger] changes — a firm "no"
/// for a wrong PIN. Three damped oscillations, no overshoot.
class Shake extends StatefulWidget {
  final Object? trigger;
  final Widget child;
  const Shake({super.key, required this.trigger, required this.child});

  @override
  State<Shake> createState() => _ShakeState();
}

class _ShakeState extends State<Shake> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 380));

  @override
  void didUpdateWidget(covariant Shake oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.trigger != widget.trigger && !AppMotion.reduced(context)) {
      _c.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) {
        final t = _c.value;
        final dx = 12 * (1 - t) * math.sin(t * math.pi * 6);
        return Transform.translate(offset: Offset(dx, 0), child: child);
      },
      child: widget.child,
    );
  }
}
