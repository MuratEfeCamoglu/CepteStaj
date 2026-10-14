import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/holidays.dart';
import '../../core/i18n.dart';
import '../../core/tr_text.dart';
import '../../data/app_state.dart';
import '../../models/models.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_motion.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/motion.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/progress_ring.dart';
import '../../widgets/quick_counter_chip.dart';
import '../../widgets/responsive_content.dart';
import '../day_detail/day_detail_screen.dart';
import '../shell/app_shell.dart';
import '../wrapped/wrapped_screen.dart';

/// "Bugün" tab — the daily dashboard: where the internship stands, what
/// today still needs, and one tap into writing it.
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
        final missing = state.missingDays;
        final recent = state.recentEntries(3);
        var i = 0;
        return SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.xxl,
            ),
            children: [
              ResponsiveContent(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Entrance(index: i++, child: _Header(state: state)),
                    const SizedBox(height: AppSpacing.lg),
                    Entrance(index: i++, child: _HeroCard(state: state)),
                    const SizedBox(height: AppSpacing.lg),
                    Entrance(index: i++, child: _TodayCard(state: state)),
                    const SizedBox(height: AppSpacing.lg),
                    Entrance(index: i++, child: _StatsGrid(state: state)),
                    const SizedBox(height: AppSpacing.lg),
                    Entrance(index: i++, child: _WeekStrip(state: state)),
                    if (missing.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.xl),
                      Entrance(
                        index: i++,
                        child: _SectionLabel(
                          t('Eksik günler ({n})', {'n': missing.length}),
                          color: AppColors.warning,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Entrance(index: i++, child: _MissingDays(days: missing)),
                    ],
                    const SizedBox(height: AppSpacing.xl),
                    Entrance(
                      index: i++,
                      child: _SectionLabel(
                        t('Hızlı sayaçlar'),
                        trailing: t('uzun bas: kaldır'),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Entrance(
                      index: i++,
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (var c = 0; c < state.quickCounters.length; c++)
                            QuickCounterChip(
                              emoji: state.quickCounters[c].emoji,
                              label: tStored(state.quickCounters[c].label),
                              count: state.quickCounters[c].count,
                              onTap: () => state.incrementCounter(c),
                              onLongPress: () =>
                                  _confirmRemoveCounter(context, state, c),
                            ),
                          QuickCounterAddButton(
                            onTap: () => _showAddCounterSheet(context, state),
                          ),
                        ],
                      ),
                    ),
                    if (recent.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.xl),
                      Entrance(
                        index: i++,
                        child: _SectionLabel(t('Son kayıtlar')),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      for (final e in recent)
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: Entrance(
                            index: i++,
                            child: _RecentEntryTile(state: state, entry: e),
                          ),
                        ),
                    ],
                    const SizedBox(height: AppSpacing.lg),
                    Entrance(index: i++, child: _TipCard(day: today)),
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
      SnackBar(content: Text(t('{emoji} Yeni rozet: {label}', {'emoji': badge.emoji, 'label': badge.label}))),
    );
  }

  void _confirmRemoveCounter(BuildContext context, AppState state, int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t('Sayacı kaldır')),
        content: Text(
          t('"{label}" sayacını kaldırmak istiyor musun?', {'label': tStored(state.quickCounters[index].label)}),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(t('Vazgeç')),
          ),
          TextButton(
            onPressed: () {
              state.removeCounterAt(index);
              Navigator.of(ctx).pop();
            },
            child: Text(t('Kaldır')),
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
      ('🍽️', 'Öğle yemeği'),
      ('🚌', 'Yolda geçen süre'),
      ('📚', 'Okunan doküman'),
    ];
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(t('Yeni sayaç ekle'), style: AppTextStyles.head(fontSize: 18)),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final o in options)
                    Pressable(
                      onTap: () {
                        state.addCounter(o.$1, o.$2);
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.sunkenBg,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '${o.$1}  ${t(o.$2)}',
                          style: AppTextStyles.body(fontSize: 14, weight: FontWeight.w500),
                        ),
                      ),
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

void _openDay(BuildContext context, DateTime date) {
  Navigator.of(context).push(MaterialPageRoute(builder: (_) => DayDetailScreen(date: date)));
}

String _greeting() {
  final h = DateTime.now().hour;
  if (h < 5) return t('İyi geceler');
  if (h < 12) return t('Günaydın');
  if (h < 18) return t('İyi günler');
  return t('İyi akşamlar');
}

class _Header extends StatelessWidget {
  final AppState state;
  const _Header({required this.state});

  @override
  Widget build(BuildContext context) {
    final today = state.today;
    final company = state.internship?.company ?? '';
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${weekdayNameFor(today)}, ${shortDateFor(today)}'.toUpperTr(),
                style: AppTextStyles.label(),
              ),
              const SizedBox(height: 6),
              Text(
                '${_greeting()} 👋',
                style: AppTextStyles.disp(fontSize: 30),
              ),
              const SizedBox(height: 2),
              Text(
                [tStored(state.internship?.name ?? 'Cepte Staj'), if (company.isNotEmpty) company].join(' · '),
                style: AppTextStyles.body(fontSize: 14, color: AppColors.textMuted, weight: FontWeight.w500),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        Pressable(
          onTap: () => ShellNavigation.of(context)?.goTo(3),
          child: Tooltip(
            message: t('Ayarlar'),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.cardBg,
                shape: BoxShape.circle,
                boxShadow: AppColors.cardShadow,
              ),
              child: Icon(Icons.tune_rounded, size: 20, color: AppColors.textPrimary),
            ),
          ),
        ),
      ],
    );
  }
}

/// Deep teal gradient card: the remaining-days ring plus where the
/// internship stands. Stays dark in both themes so the ring always glows.
class _HeroCard extends StatelessWidget {
  final AppState state;
  const _HeroCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final pct = (state.progress * 100).round();
    final white = AppColors.onDeep;
    final finished = state.internshipFinished;
    final notStarted = state.internshipNotStarted;

    Widget info;
    if (finished) {
      info = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(t('Staj tamamlandı'), style: AppTextStyles.disp(fontSize: 22, color: white)),
          const SizedBox(height: 4),
          Text(
            t('{filled} / {total} gün dolu', {'filled': state.filledWorkdays, 'total': state.totalWorkdays}),
            style: AppTextStyles.body(fontSize: 13, color: white.withValues(alpha: 0.75)),
          ),
          const SizedBox(height: AppSpacing.md),
          Pressable(
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const WrappedScreen())),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(color: AppColors.highlighter, borderRadius: BorderRadius.circular(999)),
              child: Text(
                t('Wrapped\'ı gör ✨'),
                style: AppTextStyles.body(fontSize: 13, weight: FontWeight.w700, color: AppColors.onHighlighter),
              ),
            ),
          ),
        ],
      );
    } else {
      info = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(t('İlerleme').toUpperTr(), style: AppTextStyles.label(color: white.withValues(alpha: 0.65))),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text('%', style: AppTextStyles.disp(fontSize: 20, color: white.withValues(alpha: 0.7))),
              CountUpText(value: pct, style: AppTextStyles.disp(fontSize: 40, color: white, height: 1)),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            t('{filled} / {total} gün dolu', {'filled': state.filledWorkdays, 'total': state.totalWorkdays}),
            style: AppTextStyles.body(fontSize: 13, color: white.withValues(alpha: 0.8), weight: FontWeight.w500),
          ),
          const SizedBox(height: AppSpacing.md),
          _HeroChip(
            icon: notStarted ? Icons.rocket_launch_outlined : Icons.flag_outlined,
            label: notStarted
                ? t('Başlangıç: {date}', {'date': compactDateFor(state.internship!.startDate)})
                : t('Bitiş: {date}', {'date': compactDateFor(state.endDate)}),
          ),
          const SizedBox(height: 6),
          _HeroChip(
            icon: Icons.hourglass_bottom_rounded,
            label: t('{n} takvim günü', {'n': state.remainingCalendarDays}),
          ),
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.circular(AppRadius.cardLarge + 4),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0B7A6D).withValues(alpha: AppColors.isDark ? 0.18 : 0.35),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Faint ruled lines — the notebook motif, kept subtle.
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(painter: _HeroLinesPainter()),
            ),
          ),
          Row(
            children: [
              ProgressRing(
                progress: state.progress,
                remainingDays: state.remainingDays,
                size: 132,
                caption: finished ? t('gün boş kaldı') : t('iş günü kaldı'),
              ),
              const SizedBox(width: AppSpacing.xl),
              Expanded(child: info),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..strokeWidth = 1;
    for (var y = 22.0; y < size.height; y += 22) {
      canvas.drawLine(Offset(-20, y), Offset(size.width + 20, y), p);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _HeroChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _HeroChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 5, 10, 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.highlighter),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.body(fontSize: 12, weight: FontWeight.w600, color: AppColors.onDeep),
            ),
          ),
        ],
      ),
    );
  }
}

/// What today needs: its status, a preview of what's written, the word
/// goal, and the main "write today" action.
class _TodayCard extends StatelessWidget {
  final AppState state;
  const _TodayCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final today = state.today;
    final entry = state.existingEntry(today);
    final filled = entry?.hasOfficialContent ?? false;
    final workday = state.isWorkday(today) && state.isInInternship(today);
    final holiday = TrHolidays.nameFor(today);
    final goal = state.internship?.dailyWordGoal ?? 120;
    final words = entry?.wordCount ?? 0;
    final progress = goal == 0 ? 0.0 : (words / goal).clamp(0.0, 1.0);

    final (String statusLabel, Color statusColor, IconData statusIcon) = filled
        ? (t('Yazıldı'), AppColors.checkGreen, Icons.check_circle_rounded)
        : holiday != null
            ? (t(holiday), AppColors.sky, Icons.celebration_outlined)
            : workday
                ? (t('Henüz boş'), AppColors.warning, Icons.edit_note_rounded)
                : (t('İş günü değil'), AppColors.textMuted, Icons.weekend_outlined);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(AppRadius.cardLarge),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  t('Bugünün defteri'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.head(fontSize: 17),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              AnimatedSwitcher(
                duration: AppMotion.of(context, AppMotion.standard),
                transitionBuilder: (c, a) => ScaleTransition(scale: a, child: FadeTransition(opacity: a, child: c)),
                child: Container(
                  key: ValueKey(statusLabel),
                  padding: const EdgeInsets.fromLTRB(8, 4, 10, 4),
                  decoration: BoxDecoration(
                    color: AppColors.tint(statusColor),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 14, color: statusColor),
                      const SizedBox(width: 4),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 160),
                        child: Text(
                          statusLabel,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.body(fontSize: 12, weight: FontWeight.w600, color: statusColor),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (filled) ...[
            if (entry!.topic.trim().isNotEmpty)
              Text(
                entry.topic.trim(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.body(fontSize: 15, weight: FontWeight.w600),
              ),
            if (entry.body.trim().isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                entry.body.trim(),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.body(fontSize: 13, color: AppColors.textMuted, height: 1.4),
              ),
            ],
          ] else
            Text(
              workday
                  ? t('Bugün neler yaptın? Birkaç cümle yeter — akşam kendine teşekkür edeceksin.')
                  : t('Bugün yazman gerekmiyor, ama istersen yine de not alabilirsin.'),
              style: AppTextStyles.body(fontSize: 13, color: AppColors.textMuted, height: 1.4),
            ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: progress),
                  duration: AppMotion.of(context, AppMotion.slow),
                  curve: AppMotion.emphasized,
                  builder: (context, v, _) => ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: v,
                      minHeight: 8,
                      backgroundColor: AppColors.sunkenBg,
                      valueColor: AlwaysStoppedAnimation(progress >= 1 ? AppColors.checkGreen : AppColors.ink),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                t('{w} / {g} kelime', {'w': words, 'g': goal}),
                style: AppTextStyles.body(fontSize: 12, weight: FontWeight.w600, color: AppColors.textMuted)
                    .copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          PrimaryButton(
            label: filled ? t('Bugünü düzenle') : t('Bugünü doldur'),
            icon: filled ? Icons.edit_rounded : Icons.draw_rounded,
            trailingArrow: '→',
            onTap: () => _openDay(context, today),
          ),
          const SizedBox(height: AppSpacing.sm),
          _JournalNudge(state: state, entry: entry),
        ],
      ),
    );
  }
}

/// One line under the main action pointing at the private side — shows
/// today's mood if logged, otherwise invites a 15-second check-in.
class _JournalNudge extends StatelessWidget {
  final AppState state;
  final DayEntry? entry;
  const _JournalNudge({required this.state, required this.entry});

  @override
  Widget build(BuildContext context) {
    final mood = entry?.mood ?? 0;
    final label = mood > 0
        ? t('Bugünkü ruh halin {emoji}', {'emoji': moodEmojis[mood - 1]})
        : t('Günlüğüne 15 saniyelik not bırak');
    return Pressable(
      onTap: () => ShellNavigation.of(context)?.goTo(2),
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.coralLight,
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        child: Row(
          children: [
            Icon(Icons.auto_stories_rounded, size: 16, color: AppColors.coral),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.body(fontSize: 13, weight: FontWeight.w600, color: AppColors.coral),
              ),
            ),
            Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.coral),
          ],
        ),
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final AppState state;
  const _StatsGrid({required this.state});

  @override
  Widget build(BuildContext context) {
    final avg = state.averageMood();
    final earned = state.badges.where((b) => b.earned).length;
    final tiles = [
      _StatTile(
        emoji: '🔥',
        color: AppColors.amber,
        value: '${state.currentStreak}',
        label: t('gün seri'),
      ),
      _StatTile(
        emoji: '✍️',
        color: AppColors.violet,
        value: '${state.totalWordsWritten}',
        label: t('toplam kelime'),
      ),
      _StatTile(
        emoji: avg == null ? '🙂' : moodEmojis[(avg.round() - 1).clamp(0, 4)],
        color: AppColors.rose,
        value: avg == null ? '—' : avg.toStringAsFixed(1),
        label: t('ruh hali (7 gün)'),
        onTap: () => ShellNavigation.of(context)?.goTo(2),
      ),
      _StatTile(
        emoji: '🏅',
        color: AppColors.sky,
        value: '$earned/${state.badges.length}',
        label: t('rozet'),
        onTap: () => ShellNavigation.of(context)?.goTo(2),
      ),
    ];
    return Column(
      children: [
        Row(children: [Expanded(child: tiles[0]), const SizedBox(width: AppSpacing.md), Expanded(child: tiles[1])]),
        const SizedBox(height: AppSpacing.md),
        Row(children: [Expanded(child: tiles[2]), const SizedBox(width: AppSpacing.md), Expanded(child: tiles[3])]),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final String emoji;
  final Color color;
  final String value;
  final String label;
  final VoidCallback? onTap;

  const _StatTile({
    required this.emoji,
    required this.color,
    required this.value,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final n = int.tryParse(value);
    final valueStyle = AppTextStyles.disp(fontSize: 24, color: AppColors.textPrimary);
    return Pressable(
      onTap: onTap,
      pressedScale: 0.97,
      borderRadius: BorderRadius.circular(AppRadius.cardLarge),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(AppRadius.cardLarge),
          boxShadow: AppColors.cardShadow,
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.tint(color),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(emoji, style: const TextStyle(fontSize: 20)),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: n != null ? CountUpText(value: n, style: valueStyle) : Text(value, style: valueStyle),
                  ),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.body(fontSize: 12, color: AppColors.textMuted, weight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The current Monday–Sunday week as seven tappable day pills.
class _WeekStrip extends StatelessWidget {
  final AppState state;
  const _WeekStrip({required this.state});

  @override
  Widget build(BuildContext context) {
    final today = state.today;
    final monday = DateTime(today.year, today.month, today.day - (today.weekday - 1));
    final days = [for (var d = 0; d < 7; d++) DateTime(monday.year, monday.month, monday.day + d)];
    final filledCount = days.where((d) => state.existingEntry(d)?.hasOfficialContent ?? false).length;

    return Container(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(AppRadius.cardLarge),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: [
                Text(t('Bu hafta'), style: AppTextStyles.head(fontSize: 16)),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    state.currentStreak > 0
                        ? t('🔥 {n} gün seri', {'n': state.currentStreak})
                        : t('Yeni seri bugün başlıyor'),
                    textAlign: TextAlign.end,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.body(fontSize: 12, weight: FontWeight.w600, color: AppColors.textMuted),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              for (var d = 0; d < 7; d++)
                Expanded(child: _WeekDay(state: state, date: days[d], index: d)),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              t('Bu hafta {n} gün yazdın', {'n': filledCount}),
              style: AppTextStyles.body(fontSize: 12, color: AppColors.textFaint),
            ),
          ),
        ],
      ),
    );
  }
}

class _WeekDay extends StatelessWidget {
  final AppState state;
  final DateTime date;
  final int index;
  const _WeekDay({required this.state, required this.date, required this.index});

  @override
  Widget build(BuildContext context) {
    final today = state.today;
    final isToday = date == today;
    final filled = state.existingEntry(date)?.hasOfficialContent ?? false;
    final workday = state.isWorkday(date) && state.isInInternship(date);
    final past = date.isBefore(today);
    final missing = workday && past && !filled;

    final Color bg;
    final Color fg;
    if (filled) {
      bg = AppColors.ink;
      fg = AppColors.onInk;
    } else if (missing) {
      bg = AppColors.tint(AppColors.warning);
      fg = AppColors.warning;
    } else if (isToday) {
      bg = AppColors.highlighter;
      fg = AppColors.onHighlighter;
    } else {
      bg = Colors.transparent;
      fg = workday ? AppColors.textPrimary : AppColors.textFaint;
    }

    return Pressable(
      onTap: () => _openDay(context, date),
      pressedScale: 0.9,
      child: Column(
        children: [
          Text(
            weekdayLetters[index],
            style: AppTextStyles.body(
              fontSize: 11,
              weight: FontWeight.w600,
              color: isToday ? AppColors.textPrimary : AppColors.textFaint,
            ),
          ),
          const SizedBox(height: 6),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: AppMotion.reduced(context) ? 1 : 0, end: 1),
            duration: AppMotion.of(context, Duration(milliseconds: 380 + 45 * index)),
            curve: Interval(index / 14, 1, curve: AppMotion.settle),
            builder: (context, v, child) => Transform.scale(scale: 0.6 + 0.4 * v, child: Opacity(opacity: v.clamp(0, 1), child: child)),
            child: Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: bg,
                shape: BoxShape.circle,
                border: isToday && (filled || missing)
                    ? Border.all(color: AppColors.highlighter, width: 2.5)
                    : null,
              ),
              child: filled
                  ? Icon(Icons.check_rounded, size: 18, color: fg)
                  : Text(
                      '${date.day}',
                      style: AppTextStyles.body(fontSize: 13, weight: FontWeight.w700, color: fg)
                          .copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  final String? trailing;
  final Color? color;
  const _SectionLabel(this.text, {this.trailing, this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Expanded(child: Text(text.toUpperTr(), style: AppTextStyles.label(color: color))),
          if (trailing != null)
            Text(trailing!, style: AppTextStyles.body(fontSize: 11, color: AppColors.textFaint)),
        ],
      ),
    );
  }
}

class _MissingDays extends StatelessWidget {
  final List<DateTime> days;
  const _MissingDays({required this.days});

  @override
  Widget build(BuildContext context) {
    final shown = days.take(14).toList();
    return SizedBox(
      height: 64,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: shown.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, i) {
          final d = shown[i];
          return Pressable(
            onTap: () => _openDay(context, d),
            borderRadius: BorderRadius.circular(AppRadius.card),
            child: Container(
              width: 64,
              decoration: BoxDecoration(
                color: AppColors.tint(AppColors.warning),
                borderRadius: BorderRadius.circular(AppRadius.card),
                border: Border.all(color: AppColors.warning.withValues(alpha: 0.35)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${d.day}',
                    style: AppTextStyles.disp(fontSize: 20, color: AppColors.warning),
                  ),
                  Text(
                    '${weekdayShortFor(d)} · ${monthShort(d.month)}',
                    style: AppTextStyles.body(fontSize: 10, weight: FontWeight.w600, color: AppColors.warning),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _RecentEntryTile extends StatelessWidget {
  final AppState state;
  final DayEntry entry;
  const _RecentEntryTile({required this.state, required this.entry});

  @override
  Widget build(BuildContext context) {
    final d = parseDateKey(entry.date);
    final title = entry.topic.trim().isNotEmpty ? entry.topic.trim() : entry.body.trim();
    return Pressable(
      onTap: () => _openDay(context, d),
      pressedScale: 0.98,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(AppRadius.card),
          boxShadow: AppColors.cardShadow,
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.inkLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text('${d.day}', style: AppTextStyles.disp(fontSize: 18, color: AppColors.ink, height: 1.1)),
                  Text(
                    monthShort(d.month).toUpperTr(),
                    style: AppTextStyles.body(fontSize: 10, weight: FontWeight.w700, color: AppColors.ink),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.body(fontSize: 14, weight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${weekdayNameFor(d)} · ${t('{n} kelime', {'n': entry.wordCount})}',
                    style: AppTextStyles.body(fontSize: 12, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            if (entry.mood > 0)
              Padding(
                padding: const EdgeInsets.only(left: 6),
                child: Text(moodEmojis[entry.mood - 1], style: const TextStyle(fontSize: 18)),
              ),
            Icon(Icons.chevron_right_rounded, color: AppColors.textFaint),
          ],
        ),
      ),
    );
  }
}

/// One rotating tip a day — small, practical nudges for writing the
/// notebook and getting more out of the internship.
class _TipCard extends StatelessWidget {
  final DateTime day;
  const _TipCard({required this.day});

  static const _tips = [
    'Gün içinde 3 kelimelik notlar al; akşam onları cümleye çevirmek çok daha kolay.',
    'Defterde "ne yaptım" kadar "neden yaptım" da yaz — amirin bunu fark eder.',
    'Kullandığın araçların adını yaz: Git, Excel, AutoCAD… Sonra özgeçmişine lazım olacak.',
    'Anlamadığın bir şeyi sormak, yanlış yapmaktan iyidir. Bugün bir soru sor.',
    'Hafta sonu 10 dakika ayırıp eksik günlerini tamamla, birikmesin.',
    'Mentorundan aldığın bir geri bildirimi "Öğrendiklerim" alanına not et.',
    'Fotoğraf çekerken şirket gizliliğine dikkat et; ekranları ve belgeleri paylaşma.',
    'Ekipteki insanların adlarını ve rollerini not al — staj sonunda LinkedIn\'de eklersin.',
  ];

  @override
  Widget build(BuildContext context) {
    final dayOfYear = day.difference(DateTime(day.year)).inDays;
    final tip = _tips[dayOfYear % _tips.length];
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.tint(AppColors.amber),
        borderRadius: BorderRadius.circular(AppRadius.cardLarge),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('💡', style: TextStyle(fontSize: 22)),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t('Günün ipucu'),
                  style: AppTextStyles.body(fontSize: 13, weight: FontWeight.w700, color: AppColors.amber),
                ),
                const SizedBox(height: 4),
                Text(t(tip), style: AppTextStyles.body(fontSize: 13, height: 1.45)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
