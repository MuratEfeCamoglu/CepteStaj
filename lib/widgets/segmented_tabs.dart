import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_motion.dart';
import '../theme/app_text_styles.dart';

/// Pill-shaped segmented control, e.g. Defter / Fotoğraf. A single thumb
/// slides between segments (rather than each pill fading on its own), so
/// the eye follows the selection.
class SegmentedTabs extends StatelessWidget {
  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final Color activeColor;

  const SegmentedTabs({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
    this.activeColor = AppColors.ink,
  });

  @override
  Widget build(BuildContext context) {
    final n = labels.length;
    final duration = AppMotion.of(context, AppMotion.standard);
    return Container(
      height: 44,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.sunkenBg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            alignment: Alignment(n == 1 ? 0 : -1 + 2 * selectedIndex / (n - 1), 0),
            duration: duration,
            curve: AppMotion.emphasized,
            child: FractionallySizedBox(
              widthFactor: 1 / n,
              heightFactor: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: activeColor,
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: [BoxShadow(color: activeColor.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 3))],
                ),
              ),
            ),
          ),
          Row(
            children: [
              for (var i = 0; i < n; i++)
                Expanded(
                  child: Semantics(
                    button: true,
                    selected: i == selectedIndex,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => onChanged(i),
                      child: Center(
                        child: AnimatedDefaultTextStyle(
                          duration: duration,
                          style: AppTextStyles.body(
                            fontSize: 13,
                            weight: FontWeight.w600,
                            color: i == selectedIndex ? AppColors.onInk : AppColors.textMuted,
                          ),
                          child: Text(labels[i]),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
