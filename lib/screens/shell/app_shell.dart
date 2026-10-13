import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_motion.dart';
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
        body: IndexedStack(
          index: _index,
          children: [
            for (var i = 0; i < _screens.length; i++) _TabReveal(active: i == _index, child: _screens[i]),
          ],
        ),
        bottomNavigationBar: AppBottomNav(currentIndex: _index, onTap: goTo),
      ),
    );
  }
}

/// Replays a short fade-and-rise each time its tab becomes the visible one,
/// so switching tabs reads as a move rather than a cut. Tabs stay mounted
/// in the [IndexedStack], keeping scroll position and state.
class _TabReveal extends StatefulWidget {
  final bool active;
  final Widget child;
  const _TabReveal({required this.active, required this.child});

  @override
  State<_TabReveal> createState() => _TabRevealState();
}

class _TabRevealState extends State<_TabReveal> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: AppMotion.standard, value: 1);
  late final Animation<double> _t = CurvedAnimation(parent: _c, curve: AppMotion.emphasized);

  @override
  void didUpdateWidget(covariant _TabReveal oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !oldWidget.active && !AppMotion.reduced(context)) {
      _c.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _t,
      child: SlideTransition(
        position: Tween(begin: const Offset(0, 0.015), end: Offset.zero).animate(_t),
        child: widget.child,
      ),
    );
  }
}
