import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Full-width filled ink-colored CTA button ("Bugünü doldur", "Bitti", ...).
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final String? trailingArrow;
  final Color color;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onTap,
    this.trailingArrow,
    this.color = AppColors.ink,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: Container(
          constraints: const BoxConstraints(minHeight: 52),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.md),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: trailingArrow != null
                ? MainAxisAlignment.spaceBetween
                : MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: AppTextStyles.body(fontSize: 16, weight: FontWeight.w600, color: AppColors.onInk),
              ),
              if (trailingArrow != null)
                Text(trailingArrow!, style: AppTextStyles.body(fontSize: 16, color: AppColors.onInk)),
            ],
          ),
        ),
      ),
    );
  }
}
