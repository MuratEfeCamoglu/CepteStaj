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
  /// Fill color; defaults to the official-side [AppColors.ink].
  final Color? color;
  /// Label/icon color; defaults to [AppColors.onInk].
  final Color? foreground;
  final IconData? icon;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onTap,
    this.trailingArrow,
    this.color,
    this.foreground,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    final color = this.color ?? AppColors.ink;
    final fg = foreground ?? AppColors.onInk;
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
          gradient: enabled
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color.lerp(color, Colors.white, AppColors.isDark ? 0.08 : 0.12)!, color],
                )
              : null,
          color: enabled ? null : color.withValues(alpha: 0.4),
          borderRadius: radius,
          boxShadow: enabled
              ? [BoxShadow(color: color.withValues(alpha: AppColors.isDark ? 0.22 : 0.34), blurRadius: 22, offset: const Offset(0, 8))]
              : null,
        ),
        child: Row(
          mainAxisAlignment: trailingArrow != null ? MainAxisAlignment.spaceBetween : MainAxisAlignment.center,
          children: [
            Flexible(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20, color: fg),
                    const SizedBox(width: 8),
                  ],
                  Flexible(
                    child: Text(
                      label,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.body(fontSize: 16, weight: FontWeight.w600, color: fg),
                    ),
                  ),
                ],
              ),
            ),
            if (trailingArrow != null)
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: fg.withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.arrow_forward_rounded, color: fg, size: 20),
              ),
          ],
        ),
      ),
    );
  }
}
