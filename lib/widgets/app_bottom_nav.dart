import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

class NavTabSpec {
  final String label;
  final IconData icon;
  final Color activeColor;

  const NavTabSpec({required this.label, required this.icon, this.activeColor = AppColors.ink});
}

/// Bottom tab bar shared by all main screens. The active tab's accent color
/// flips to terra on the Günlüğüm tab to signal the "private side" of the
/// app, matching the design doc.
class AppBottomNav extends StatelessWidget {
  static const tabs = [
    NavTabSpec(label: 'Bugün', icon: Icons.check_box_outlined),
    NavTabSpec(label: 'Takvim', icon: Icons.calendar_today_outlined),
    NavTabSpec(label: 'Günlüğüm', icon: Icons.auto_stories_outlined, activeColor: AppColors.terra),
    NavTabSpec(label: 'Ayarlar', icon: Icons.settings_outlined),
  ];

  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNav({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: AppColors.cardBg),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              for (var i = 0; i < tabs.length; i++)
                Expanded(
                  child: InkWell(
                    onTap: () => onTap(i),
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 5),
                            decoration: BoxDecoration(
                              color: i == currentIndex ? tabs[i].activeColor.withValues(alpha: 0.12) : Colors.transparent,
                              borderRadius: BorderRadius.circular(AppRadius.pill),
                            ),
                            child: Icon(
                              tabs[i].icon,
                              size: 21,
                              color: i == currentIndex ? tabs[i].activeColor : AppColors.textFaint,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            tabs[i].label,
                            style: AppTextStyles.tab(
                              color: i == currentIndex ? tabs[i].activeColor : AppColors.textMuted,
                              weight: i == currentIndex ? FontWeight.w600 : FontWeight.w400,
                            ),
                          ),
                        ],
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
