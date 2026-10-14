import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_motion.dart';
import '../theme/app_text_styles.dart';
import 'motion.dart';

/// The circular "N iş günü kaldı" indicator on the home hero card. The arc
/// sweeps to its value and the number counts down into place, in
/// highlighter ink — the one moment of loud color on the screen. Drawn for
/// the deep gradient hero, so it looks the same in both themes.
class ProgressRing extends StatelessWidget {
  final double progress; // 0..1
  final int remainingDays;
  final double size;
  final String? caption;

  const ProgressRing({
    super.key,
    required this.progress,
    required this.remainingDays,
    this.size = 148,
    this.caption,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: progress.clamp(0, 1)),
        duration: AppMotion.of(context, const Duration(milliseconds: 1200)),
        curve: AppMotion.emphasized,
        builder: (context, p, child) => CustomPaint(
          painter: _RingPainter(progress: p, strokeWidth: size * 0.075),
          child: child,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CountUpText(
                value: remainingDays,
                duration: const Duration(milliseconds: 1100),
                style: AppTextStyles.disp(fontSize: size * 0.32, height: 1.0, color: AppColors.highlighter),
              ),
              if (caption != null)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    caption!,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.body(
                      fontSize: 11,
                      weight: FontWeight.w600,
                      color: AppColors.onDeep.withValues(alpha: 0.75),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  _RingPainter({required this.progress, required this.strokeWidth});

  /// Angle the gradient starts before the arc, covering the round cap.
  static const _capLead = 0.2;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (size.shortestSide - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.14)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );

    if (progress <= 0) return;
    final sweep = 2 * math.pi * progress;
    final fill = Paint()
      ..shader = SweepGradient(
        startAngle: 0,
        endAngle: sweep + _capLead,
        colors: const [Color(0xFF5EE6C9), Color(0xFFB8F27A), AppColors.highlighter],
        stops: const [0, 0.6, 1],
        transform: const GradientRotation(-math.pi / 2 - _capLead),
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    // Soft glow under the arc so it reads as lit, not printed.
    canvas.drawArc(
      rect,
      -math.pi / 2,
      sweep,
      false,
      Paint()
        ..color = AppColors.highlighter.withValues(alpha: 0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth + 6
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
    canvas.drawArc(rect, -math.pi / 2, sweep, false, fill);
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.strokeWidth != strokeWidth;
}
