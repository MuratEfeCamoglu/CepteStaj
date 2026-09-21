import 'package:flutter/material.dart';

/// Faint repeating horizontal rule lines, evoking a paper notebook page.
class LinedPaperBackground extends StatelessWidget {
  final double lineHeight;
  final Color lineColor;
  final double opacity;

  const LinedPaperBackground({
    super.key,
    this.lineHeight = 32,
    this.lineColor = const Color(0xFF232019),
    this.opacity = 0.06,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: CustomPaint(
          painter: _LinedPaperPainter(
            lineHeight: lineHeight,
            color: lineColor.withValues(alpha: opacity),
          ),
        ),
      ),
    );
  }
}

class _LinedPaperPainter extends CustomPainter {
  final double lineHeight;
  final Color color;

  _LinedPaperPainter({required this.lineHeight, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    for (double y = lineHeight; y < size.height; y += lineHeight) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _LinedPaperPainter oldDelegate) =>
      oldDelegate.lineHeight != lineHeight || oldDelegate.color != color;
}
