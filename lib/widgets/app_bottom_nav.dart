import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/i18n.dart';
import '../theme/app_colors.dart';
import '../theme/app_motion.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

class NavTabSpec {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  /// The private Günlüğüm tab — accented coral instead of ink.
  final bool personal;

  const NavTabSpec({
    required this.label,
    required this.icon,
    required this.activeIcon,
    this.personal = false,
  });

  Color get activeColor => personal ? AppColors.coral : AppColors.ink;
}

/// Bottom tab bar shared by all main screens. The active tab swaps to a
/// filled icon inside a tinted pill that grows in, and its accent flips to
/// coral on the Günlüğüm tab to signal the "private side" of the app.
class AppBottomNav extends StatelessWidget {
  static const tabs = [
    NavTabSpec(label: 'Bugün', icon: Icons.wb_sunny_outlined, activeIcon: Icons.wb_sunny_rounded),
    NavTabSpec(label: 'Takvim', icon: Icons.calendar_month_outlined, activeIcon: Icons.calendar_month_rounded),
    NavTabSpec(
      label: 'Günlüğüm',
      icon: Icons.auto_stories_outlined,
      activeIcon: Icons.auto_stories_rounded,
      personal: true,
    ),
    NavTabSpec(label: 'Ayarlar', icon: Icons.settings_outlined, activeIcon: Icons.settings_rounded),
  ];

  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNav({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final duration = AppMotion.of(context, AppMotion.standard);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        border: Border(top: BorderSide(color: AppColors.border)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: AppColors.isDark ? 0.3 : 0.04),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              for (var i = 0; i < tabs.length; i++)
                Expanded(
                  child: Semantics(
                    selected: i == currentIndex,
                    button: true,
                    child: InkWell(
                      onTap: () {
                        if (i != currentIndex) HapticFeedback.selectionClick();
                        onTap(i);
                      },
                      splashFactory: NoSplash.splashFactory,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AnimatedContainer(
                              duration: duration,
                              curve: AppMotion.emphasized,
                              padding: EdgeInsets.symmetric(horizontal: i == currentIndex ? 20 : 12, vertical: 5),
                              decoration: BoxDecoration(
                                color: i == currentIndex ? AppColors.tint(tabs[i].activeColor) : Colors.transparent,
                                borderRadius: BorderRadius.circular(AppRadius.pill),
                              ),
                              child: AnimatedSwitcher(
                                duration: duration,
                                switchInCurve: AppMotion.settle,
                                transitionBuilder: (child, a) => ScaleTransition(scale: a, child: child),
                                child: Icon(
                                  i == currentIndex ? tabs[i].activeIcon : tabs[i].icon,
                                  key: ValueKey(i == currentIndex),
                                  size: 22,
                                  color: i == currentIndex ? tabs[i].activeColor : AppColors.textFaint,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            AnimatedDefaultTextStyle(
                              duration: duration,
                              style: AppTextStyles.tab(
                                color: i == currentIndex ? tabs[i].activeColor : AppColors.textMuted,
                                weight: i == currentIndex ? FontWeight.w700 : FontWeight.w500,
                              ),
                              child: Text(t(tabs[i].label)),
                            ),
                          ],
                        ),
                      ),
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
