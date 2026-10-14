import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/i18n.dart';
import '../../data/app_state.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/lined_paper_background.dart';
import '../../widgets/motion.dart';
import '../shell/app_shell.dart';

/// Brand moment: the wordmark rises in and a highlighter stroke sweeps
/// under "Staj". Stays up at least [_minShow] so that sequence finishes,
/// then moves on as soon as the saved state has loaded. Tap to skip.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const _minShow = Duration(milliseconds: 900);
  bool _entered = false;
  bool _minElapsed = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(_minShow, () {
      _minElapsed = true;
      _maybeEnter();
    });
  }

  void _maybeEnter() {
    if (!mounted || !_minElapsed) return;
    final state = context.read<AppState>();
    if (state.loading) return;
    _enter();
  }

  void _enter() {
    if (!mounted || _entered) return;
    _entered = true;
    final state = context.read<AppState>();
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 380),
        pageBuilder: (_, __, ___) =>
            state.hasInternship ? const AppShell() : const OnboardingScreen(),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Entrance(
                        offsetY: 18,
                        child: FittedBox(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                'Cepte',
                                style: AppTextStyles.disp(fontSize: 44),
                              ),
                              const SizedBox(width: 4),
                              HighlighterMark(
                                delay: const Duration(milliseconds: 280),
                                child: Text(
                                  'Staj',
                                  style: AppTextStyles.disp(
                                    fontSize: 44,
                                    color: AppColors.isDark
                                        ? AppColors.highlighter
                                        : AppColors.ink,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Entrance(
                        index: 3,
                        child: Text(
                          t('Staj defterin, cebinde.'),
                          style: AppTextStyles.body(
                            fontSize: 15,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
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
