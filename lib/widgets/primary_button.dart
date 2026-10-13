import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'motion.dart';

/// Full-width filled CTA ("Bugünü doldur", "Bitti", ...). A soft colored
/// glow lifts it off the page; pressing dips it (see [Pressable]). With
/// [trailingArrow] set, an arrow sits in its own round chip on the right.
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  /// Shows the trailing arrow chip when non-null (kept as a String for
  /// call-site compatibility; the value itself isn't drawn).
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
    final enabled = onTap != null;
    final radius = BorderRadius.circular(AppRadius.pill);
    return Pressable(
      onTap: onTap,
      borderRadius: radius,
      pressedScale: 0.97,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        constraints: const BoxConstraints(minHeight: 56),
        padding: EdgeInsets.fromLTRB(AppSpacing.xxl, AppSpacing.sm, trailingArrow != null ? AppSpacing.sm : AppSpacing.xxl, AppSpacing.sm),
        decoration: BoxDecoration(
          color: enabled ? color : color.withValues(alpha: 0.4),
          borderRadius: radius,
          boxShadow: enabled
              ? [BoxShadow(color: color.withValues(alpha: 0.32), blurRadius: 20, offset: const Offset(0, 8))]
              : null,
        ),
        child: Row(
          mainAxisAlignment: trailingArrow != null ? MainAxisAlignment.spaceBetween : MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.body(fontSize: 16, weight: FontWeight.w600, color: AppColors.onInk),
              ),
            ),
            if (trailingArrow != null)
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.onInk.withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_forward_rounded, color: AppColors.onInk, size: 20),
              ),
          ],
        ),
      ),
    );
  }
}
