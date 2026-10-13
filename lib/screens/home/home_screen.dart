import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/tr_text.dart';
import '../../data/app_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/progress_ring.dart';
import '../../widgets/quick_counter_chip.dart';
import '../../widgets/responsive_content.dart';
import '../../widgets/motion.dart';
import '../../widgets/streak_dots.dart';
import '../day_detail/day_detail_screen.dart';
import '../shell/app_shell.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => _maybeShowBadgeToast(state),
        );
        final today = state.today;
        return SafeArea(
          bottom: false,
          child: Column(
            children: [
              ResponsiveContent(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.sm,
                    AppSpacing.sm,
                  ),
                  child: Entrance(
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${weekdayNameFor(today)}, ${shortDateFor(today)}'
                                    .toUpperTr(),
                                style: AppTextStyles.label(),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                state.internship?.name ?? 'Cepte Staj',
                                style: AppTextStyles.disp(fontSize: 30),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: 'Ayarlar',
                          onPressed: () => ShellNavigation.of(context)?.goTo(3),
                          icon: Icon(
                            Icons.tune_rounded,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.sm,
                    AppSpacing.lg,
                    AppSpacing.xxl,
                  ),
                  children: [
                    ResponsiveContent(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Entrance(
                            index: 1,
                            child: _ProgressCard(state: state),
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          Entrance(
                            index: 2,
                            child: StreakDots(
                              week: state.streakWeek,
                              streak: state.currentStreak,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          Entrance(
                            index: 3,
                            child: PrimaryButton(
                              label: 'Bugünü doldur',
                              trailingArrow: '→',
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => DayDetailScreen(date: today),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xxxl),
                          Entrance(
                            index: 4,
                            child: Text(
                              'HIZLI SAYAÇLAR',
                              style: AppTextStyles.label(),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Entrance(
                            index: 5,
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                for (
                                  var i = 0;
                                  i < state.quickCounters.length;
                                  i++
                                )
                                  QuickCounterChip(
                                    emoji: state.quickCounters[i].emoji,
                                    count: state.quickCounters[i].count,
                                    onTap: () => state.incrementCounter(i),
                                    onLongPress: () => _confirmRemoveCounter(
                                      context,
                                      state,
                                      i,
                                    ),
                                  ),
                                QuickCounterAddButton(
                                  onTap: () =>
                                      _showAddCounterSheet(context, state),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _maybeShowBadgeToast(AppState state) {
    final badge = state.consumeJustEarnedBadge();
    if (badge == null || !mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${badge.emoji} Yeni rozet: ${badge.label}'),
        backgroundColor: AppColors.ink,
      ),
    );
  }

  void _confirmRemoveCounter(BuildContext context, AppState state, int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sayacı kaldır'),
        content: Text(
          '"${state.quickCounters[index].label}" sayacını kaldırmak istiyor musun?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Vazgeç'),
          ),
          TextButton(
            onPressed: () {
              state.removeCounterAt(index);
              Navigator.of(ctx).pop();
            },
            child: const Text('Kaldır'),
          ),
        ],
      ),
    );
  }

  void _showAddCounterSheet(BuildContext context, AppState state) {
    const options = [
      ('☕', 'Kahve molası'),
      ('🐛', 'Bug çözüldü'),
      ('🙋', 'Soru soruldu'),
      ('📞', 'Toplantı'),
      ('💡', 'Fikir'),
    ];
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.cardLarge),
        ),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Yeni sayaç ekle', style: AppTextStyles.head(fontSize: 16)),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final o in options)
                    ActionChip(
                      backgroundColor: AppColors.sunkenBg,
                      side: BorderSide.none,
                      label: Text(
                        '${o.$1} ${o.$2}',
                        style: AppTextStyles.body(fontSize: 13),
                      ),
                      onPressed: () {
                        state.addCounter(o.$1, o.$2);
                        Navigator.of(context).pop();
                      },
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final AppState state;
  const _ProgressCard({required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.xxl,
        horizontal: AppSpacing.xl,
      ),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(AppRadius.cardLarge),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        children: [
          ProgressRing(
            progress: state.progress,
            remainingDays: state.remainingDays,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'iş günü kaldı',
            style: AppTextStyles.body(
              fontSize: 13,
              weight: FontWeight.w500,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${state.filledWorkdays} / ${state.totalWorkdays} gün · %${(state.progress * 100).round()}',
            style: AppTextStyles.body(
              fontSize: 14,
            ).copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
          ),
          if (state.emptyDaysBehind > 0) ...[
            const SizedBox(height: AppSpacing.sm),
            Pressable(
              onTap: () => ShellNavigation.of(context)?.goTo(1),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.edit_calendar_rounded,
                      size: 15,
                      color: AppColors.warning,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${state.emptyDaysBehind} gün boş kaldı →',
                      style: AppTextStyles.body(
                        fontSize: 13,
                        weight: FontWeight.w600,
                        color: AppColors.warning,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
