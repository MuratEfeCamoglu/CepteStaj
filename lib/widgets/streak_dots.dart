import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_motion.dart';
import '../theme/app_text_styles.dart';

/// Last 7 days as small blocks (filled = written), plus the streak count.
/// Filled blocks grow in left to right, like ticking off a week.
class StreakDots extends StatelessWidget {
  final List<bool> week;
  final int streak;

  const StreakDots({super.key, required this.week, required this.streak});

  @override
  Widget build(BuildContext context) {
    final reduced = AppMotion.reduced(context);
    return Row(
      children: [
        for (var i = 0; i < week.length; i++)
          Padding(
            padding: const EdgeInsets.only(right: 5),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: reduced ? 1 : 0, end: 1),
              duration: reduced ? Duration.zero : Duration(milliseconds: 300 + 50 * i),
              curve: Interval(i / (week.length + 6), 1, curve: AppMotion.settle),
              builder: (context, t, _) => Container(
                width: 22,
                height: 8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: week[i]
                      ? Color.lerp(AppColors.sunkenBg, AppColors.ink, t.clamp(0, 1))
                      : AppColors.sunkenBg,
                ),
              ),
            ),
          ),
        const Spacer(),
        Text(
          streak > 0 ? '🔥 $streak gün seri' : 'Yeni seri bugün başlıyor',
          style: AppTextStyles.body(fontSize: 13, weight: FontWeight.w600, color: AppColors.textMuted),
        ),
      ],
    );
  }
}
