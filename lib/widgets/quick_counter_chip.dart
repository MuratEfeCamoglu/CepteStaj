import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class QuickCounterChip extends StatelessWidget {
  final String emoji;
  final int count;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const QuickCounterChip({
    super.key,
    required this.emoji,
    required this.count,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        constraints: const BoxConstraints(minHeight: 36),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.sunkenBg,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 6),
            Text('$count', style: AppTextStyles.body(fontSize: 14, weight: FontWeight.w600)),
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.sunkenBg,
          shape: BoxShape.circle,
        ),
        child: Text('+', style: AppTextStyles.body(fontSize: 16, color: AppColors.textMuted)),
      ),
    );
  }
}
