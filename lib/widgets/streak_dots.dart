import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Row of small dots showing the last 7 days, plus a 🔥 streak count.
class StreakDots extends StatelessWidget {
  final List<bool> week;
  final int streak;

  const StreakDots({super.key, required this.week, required this.streak});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Row(
          children: [
            for (final filled in week)
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: filled ? AppColors.ink : Colors.transparent,
                    border: filled
                        ? null
                        : Border.all(color: AppColors.borderLight, width: 1.5),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: 6),
        Text('🔥 $streak gün', style: AppTextStyles.body(fontSize: 13, color: AppColors.textMuted)),
      ],
    );
  }
}
