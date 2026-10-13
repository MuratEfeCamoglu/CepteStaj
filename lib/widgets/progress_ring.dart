import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_motion.dart';
import '../theme/app_text_styles.dart';
import 'motion.dart';

/// The circular "N iş günü kaldı" indicator on the home screen. The arc
/// sweeps to its value and the number counts down into place; then the
/// highlighter strokes under it — the one moment of color on the screen.
class ProgressRing extends StatelessWidget {
  final double progress; // 0..1
  final int remainingDays;
  final double size;

  const ProgressRing({
    super.key,
    required this.progress,
    required this.remainingDays,
    this.size = 148,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: progress.clamp(0, 1)),
        duration: AppMotion.of(context, const Duration(milliseconds: 1000)),
        curve: AppMotion.emphasized,
        builder: (context, p, child) => CustomPaint(
          painter: _RingPainter(progress: p),
          child: child,
        ),
        child: Center(
          child: HighlighterMark(
            delay: const Duration(milliseconds: 650),
            coverage: 0.42,
            child: CountUpText(
              value: remainingDays,
              style: AppTextStyles.disp(
                fontSize: 52,
                height: 1.05,
                color: AppColors.isDark ? AppColors.highlighter : null,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  _RingPainter({required this.progress});

  /// Angle the gradient starts before the arc, covering the round cap.
  static const _capLead = 0.2;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    const strokeWidth = 12.0;
    final radius = (size.shortestSide - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = AppColors.sunkenBg
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );

    if (progress <= 0) return;
    final sweep = 2 * math.pi * progress;
    final fill = Paint()
      ..shader = SweepGradient(
        startAngle: 0,
        endAngle: sweep + _capLead,
        colors: const [AppColors.inkDark, AppColors.ink, Color(0xFF19A08F)],
        stops: const [0, 0.55, 1],
        transform: const GradientRotation(-math.pi / 2 - _capLead),
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, -math.pi / 2, sweep, false, fill);
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) => oldDelegate.progress != progress;
}
