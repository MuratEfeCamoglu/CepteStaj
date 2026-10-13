import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import '../theme/app_motion.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

class NavTabSpec {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final Color activeColor;

  const NavTabSpec({
    required this.label,
    required this.icon,
    required this.activeIcon,
    this.activeColor = AppColors.ink,
  });
}

/// Bottom tab bar shared by all main screens. The active tab swaps to a
/// filled icon inside a tinted pill that grows in, and its accent flips to
/// coral on the Günlüğüm tab to signal the "private side" of the app.
class AppBottomNav extends StatelessWidget {
  static const tabs = [
    NavTabSpec(label: 'Bugün', icon: Icons.check_box_outlined, activeIcon: Icons.check_box_rounded),
    NavTabSpec(label: 'Takvim', icon: Icons.calendar_today_outlined, activeIcon: Icons.calendar_today_rounded),
    NavTabSpec(
      label: 'Günlüğüm',
      icon: Icons.auto_stories_outlined,
      activeIcon: Icons.auto_stories_rounded,
      activeColor: AppColors.coral,
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
                                color: i == currentIndex ? tabs[i].activeColor.withValues(alpha: 0.14) : Colors.transparent,
                                borderRadius: BorderRadius.circular(AppRadius.pill),
                              ),
                              child: AnimatedScale(
                                scale: i == currentIndex ? 1.08 : 1,
                                duration: duration,
                                curve: AppMotion.settle,
                                child: Icon(
                                  i == currentIndex ? tabs[i].activeIcon : tabs[i].icon,
                                  size: 22,
                                  color: i == currentIndex ? tabs[i].activeColor : AppColors.textFaint,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              tabs[i].label,
                              style: AppTextStyles.tab(
                                color: i == currentIndex ? tabs[i].activeColor : AppColors.textMuted,
                                weight: i == currentIndex ? FontWeight.w600 : FontWeight.w500,
                              ),
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
