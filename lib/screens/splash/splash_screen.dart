import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/app_state.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/lined_paper_background.dart';
import '../shell/app_shell.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _entered = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 900), _maybeEnter);
  }

  void _maybeEnter() {
    final state = context.read<AppState>();
    if (state.loading) return;
    _enter();
  }

  void _enter() {
    if (!mounted || _entered) return;
    _entered = true;
    final state = context.read<AppState>();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => state.hasInternship ? const AppShell() : const OnboardingScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        if (!state.loading) {
          WidgetsBinding.instance.addPostFrameCallback((_) => _maybeEnter());
        }
        return Scaffold(
          backgroundColor: AppColors.screenBg,
          body: GestureDetector(
            onTap: _enter,
            behavior: HitTestBehavior.opaque,
            child: Stack(
              children: [
                const LinedPaperBackground(lineHeight: 40, opacity: 0.05),
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Cepte', style: AppTextStyles.disp(fontSize: 32)),
                      Text('Staj', style: AppTextStyles.disp(fontSize: 32, color: AppColors.ink)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
