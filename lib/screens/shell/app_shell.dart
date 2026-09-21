import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../widgets/app_bottom_nav.dart';
import '../calendar/calendar_screen.dart';
import '../home/home_screen.dart';
import '../journal/journal_screen.dart';
import '../settings/settings_screen.dart';

/// Lets any screen inside [AppShell] switch tabs, e.g. the ⚙️ icon on the
/// home screen jumping straight to the Ayarlar tab.
class ShellNavigation extends InheritedWidget {
  final ValueChanged<int> goTo;

  const ShellNavigation({super.key, required this.goTo, required super.child});

  static ShellNavigation? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ShellNavigation>();

  @override
  bool updateShouldNotify(ShellNavigation oldWidget) => goTo != oldWidget.goTo;
}

/// Hosts the four bottom-nav tabs (Bugün / Takvim / Günlüğüm / Ayarlar)
/// behind a single persistent nav bar, matching the device-frame mockups.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  static const _screens = [
    HomeScreen(),
    CalendarScreen(),
    JournalScreen(),
    SettingsScreen(),
  ];

  void goTo(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) {
    return ShellNavigation(
      goTo: goTo,
      child: Scaffold(
        backgroundColor: AppColors.screenBg,
        body: IndexedStack(index: _index, children: _screens),
        bottomNavigationBar: AppBottomNav(currentIndex: _index, onTap: goTo),
      ),
    );
  }
}
