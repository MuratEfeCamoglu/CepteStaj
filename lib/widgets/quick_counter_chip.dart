import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'motion.dart';

/// A one-tap counter (☕ 38). The number pops each time it goes up, so a
/// tap feels counted even when you're not looking at the digit.
class QuickCounterChip extends StatelessWidget {
  final String emoji;
  final String? label;
  final int count;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const QuickCounterChip({
    super.key,
    required this.emoji,
    this.label,
    required this.count,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      onLongPress: onLongPress,
      pressedScale: 0.92,
      child: Container(
        constraints: const BoxConstraints(minHeight: 44),
        padding: const EdgeInsets.fromLTRB(8, 6, 16, 6),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(999),
          boxShadow: AppColors.cardShadow,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: AppColors.sunkenBg, shape: BoxShape.circle),
              child: Text(emoji, style: const TextStyle(fontSize: 16)),
            ),
            const SizedBox(width: 10),
            if (label != null) ...[
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 120),
                child: Text(
                  label!,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.body(fontSize: 13, color: AppColors.textMuted, weight: FontWeight.w500),
                ),
              ),
              const SizedBox(width: 8),
            ],
            PopOnChange(
              trigger: count,
              child: Text(
                '$count',
                style: AppTextStyles.disp(fontSize: 18, weight: FontWeight.w700)
                    .copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class QuickCounterAddButton extends StatelessWidget {
  final VoidCallback? onTap;
  const QuickCounterAddButton({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      pressedScale: 0.9,
      child: Container(
        width: 44,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.inkLight,
        ),
        child: Icon(Icons.add_rounded, size: 22, color: AppColors.ink),
      ),
    );
  }
}
