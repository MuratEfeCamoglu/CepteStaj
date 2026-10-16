import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/i18n.dart';
import '../../data/app_state.dart';
import '../../models/models.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_motion.dart';
import '../../widgets/motion.dart';
import '../../widgets/responsive_content.dart';
import '../lock/pin_lock_screen.dart';

/// "Günlüğüm" tab — the private side of the app. Never syncs to the
/// official Defter notebook. This is also the *only* place a day's
/// personal reflection (ruh hali, Günün Olayı, ...) is entered — always
/// for today, not buried inside a specific calendar day's detail view.
class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  late final ConfettiController _confetti;
  bool _prevHasLine = false;

  /// The day the "Bugün nasıldı?" card is currently editing — defaults to
  /// today, but the user can step back to catch up on a missed day.
  DateTime? _selectedDate;

  DateTime? _controllersFor;
  final _incidentCtrl = TextEditingController();
  final _winCtrl = TextEditingController();
  final _songCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 1));
  }

  @override
  void dispose() {
    _confetti.dispose();
    _incidentCtrl.dispose();
    _winCtrl.dispose();
    _songCtrl.dispose();
    super.dispose();
  }

  /// Loads the chosen day's text into the (long-lived) controllers. The
  /// controllers are never recreated/disposed while a TextField is bound to
  /// them — that used to throw when stepping between days.
  void _syncControllers(AppState state, DateTime date) {
    if (_controllersFor == date) return;
    _controllersFor = date;
    final entry = state.entryFor(date);
    _incidentCtrl.text = entry.incident;
    _winCtrl.text = entry.dailyWin;
    _songCtrl.text = entry.song;
  }

  void _changeDate(AppState state, DateTime date) {
    _syncControllers(state, date);
    setState(() => _selectedDate = date);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        if (!state.hasInternship) return const SizedBox.shrink();
        final selectedDate = _selectedDate ?? state.today;
        if (_controllersFor == null) {
          _syncControllers(state, selectedDate);
        } else if (_controllersFor != selectedDate) {
          // The calendar day rolled over while the tab was alive.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _syncControllers(state, selectedDate);
          });
        }
        // A song shared in from Spotify lands in the entry while this tab's
        // controller still holds the old text.
        final song = state.entryFor(selectedDate).song;
        if (_controllersFor == selectedDate && _songCtrl.text != song) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && _songCtrl.text != song) _songCtrl.text = song;
          });
        }
        if (state.bingoHasLine && !_prevHasLine) {
          WidgetsBinding.instance.addPostFrameCallback((_) => _confetti.play());
        }
        _prevHasLine = state.bingoHasLine;

        final locked = state.personalLocked;

        return SafeArea(
          bottom: false,
          child: Stack(
            children: [
              Column(
                children: [
                  ResponsiveContent(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              t('Günlüğüm'),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.hand(fontSize: 44, color: AppColors.coral),
                            ),
                          ),
                          if (state.hasPinLock)
                            InkWell(
                              onTap: state.lockPersonalNow,
                              borderRadius: BorderRadius.circular(999),
                              child: Padding(
                                padding: const EdgeInsets.all(4),
                                child: Icon(Icons.lock_outline, size: 18, color: AppColors.textPrimary),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  if (locked)
                    const Expanded(child: PersonalLockView())
                  else ...[
                    ResponsiveContent(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.sm),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppColors.coralLight,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.lock_rounded, size: 12, color: AppColors.coral),
                                const SizedBox(width: 6),
                                Text(t('Deftere gitmez'),
                                    style: AppTextStyles.body(fontSize: 11, weight: FontWeight.w600, color: AppColors.coral)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.xxl),
                        children: [
                          ResponsiveContent(
                            child: Column(
                              children: [
                                _JournalCard(
                                  index: 0,
                                  child: _TodayCard(
                                    state: state,
                                    date: selectedDate,
                                    onDateChanged: (d) => _changeDate(state, d),
                                    incidentCtrl: _incidentCtrl,
                                    winCtrl: _winCtrl,
                                    songCtrl: _songCtrl,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.md),
                                _JournalCard(index: 1, child: _MoodHistoryCard(state: state)),
                                const SizedBox(height: AppSpacing.md),
                                Row(
                                  children: [
                                    Expanded(child: _JournalCard(index: 2, height: 160, child: _BingoCard(state: state))),
                                    const SizedBox(width: AppSpacing.md),
                                    Expanded(child: _JournalCard(index: 3, height: 160, child: _BadgesCard(state: state))),
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.md),
                                _JournalCard(index: 4, child: _MentorCard(state: state)),
                                const SizedBox(height: AppSpacing.md),
                                _JournalCard(index: 5, child: _CapsuleCard(state: state)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              Align(
                alignment: Alignment.topCenter,
                child: ConfettiWidget(
                  confettiController: _confetti,
                  blastDirectionality: BlastDirectionality.explosive,
                  shouldLoop: false,
                  numberOfParticles: 24,
                  colors: [AppColors.coral, AppColors.ink, AppColors.checkGreen, AppColors.highlighter, AppColors.violet],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _JournalCard extends StatelessWidget {
  final Widget child;
  final double? height;
  final int index;
  const _JournalCard({required this.child, this.height, this.index = 0});

  @override
  Widget build(BuildContext context) {
    return Entrance(
      index: index,
      child: Container(
        width: double.infinity,
        height: height,
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(AppRadius.cardLarge),
          boxShadow: AppColors.cardShadow,
        ),
        child: child,
      ),
    );
  }
}

/// The interactive heart of the Günlüğüm tab — a chosen day's mood, Günün
/// Olayı and Günün küçük zaferi. Defaults to today but [onDateChanged] lets
/// the user step back to catch up on a missed day — this is the *only*
/// place any of this is entered (see day_detail_screen.dart, which no
/// longer has a personal tab at all).
class _TodayCard extends StatelessWidget {
  final AppState state;
  final DateTime date;
  final ValueChanged<DateTime> onDateChanged;
  final TextEditingController incidentCtrl;
  final TextEditingController winCtrl;
  final TextEditingController songCtrl;

  const _TodayCard({
    required this.state,
    required this.date,
    required this.onDateChanged,
    required this.incidentCtrl,
    required this.winCtrl,
    required this.songCtrl,
  });

  bool get _isToday => _sameDay(date, state.today);
  bool get _canGoBack => state.internship == null || date.isAfter(state.internship!.startDate);
  bool get _canGoForward => !_isToday;

  static bool _sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    final entry = state.entryFor(date);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                _isToday ? t('Bugün nasıldı?') : t('{date} nasıldı?', {'date': compactDateFor(date)}),
                style: AppTextStyles.hand(fontSize: 30),
              ),
            ),
            _DateStepButton(
              icon: Icons.chevron_left,
              tooltip: t('Önceki gün'),
              enabled: _canGoBack,
              onTap: () => onDateChanged(date.subtract(const Duration(days: 1))),
            ),
            _DateStepButton(
              icon: Icons.chevron_right,
              tooltip: t('Sonraki gün'),
              enabled: _canGoForward,
              onTap: () => onDateChanged(date.add(const Duration(days: 1))),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (var i = 0; i < moodEmojis.length; i++)
              _MoodButton(
                emoji: moodEmojis[i],
                selected: entry.mood == i + 1,
                onTap: () => state.updateEntry(date, mood: entry.mood == i + 1 ? 0 : i + 1),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final r in moodReasonOptions)
              _ReasonChip(
                label: t(r),
                selected: entry.moodReasons.contains(r),
                onTap: () => state.toggleMoodReason(date, r),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            for (final (v, l) in [(1, 'boş'), (2, 'normal'), (3, 'yoğun')])
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: _WorkloadChip(
                    label: t(l),
                    selected: entry.workload == v,
                    onTap: () => state.updateEntry(date, workload: entry.workload == v ? 0 : v),
                  ),
                ),
              ),
          ],
        ),
        const _SectionDivider(),
        Text(t('Günün Olayı'), style: AppTextStyles.hand(fontSize: 24, color: AppColors.coral)),
        Text(t('Bugün başına gelen en absürt, komik ya da trajik şey.'),
            style: AppTextStyles.body(fontSize: 11, color: AppColors.textMuted)),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final c in incidentCategories)
              _ReasonChip(
                label: '${c.$1} ${t(c.$2)}',
                selected: entry.incidentCategory == c.$2,
                onTap: () => state.updateEntry(date, incidentCategory: entry.incidentCategory == c.$2 ? '' : c.$2),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        _MinimalField(controller: incidentCtrl, hint: t('Ne oldu?'), onChanged: (v) => state.updateEntry(date, incident: v)),
        const _SectionDivider(),
        Text(t('Günün küçük zaferi'), style: AppTextStyles.hand(fontSize: 24, color: AppColors.coral)),
        const SizedBox(height: AppSpacing.sm),
        _MinimalField(controller: winCtrl, hint: t('Bugün iyi giden bir şey'), onChanged: (v) => state.updateEntry(date, dailyWin: v)),
        const _SectionDivider(),
        Text(t('Bugünün şarkısı'), style: AppTextStyles.hand(fontSize: 24, color: AppColors.coral)),
        const SizedBox(height: AppSpacing.sm),
        AnimatedSwitcher(
          duration: AppMotion.of(context, AppMotion.standard),
          transitionBuilder: (c, a) => SizeTransition(sizeFactor: a, alignment: Alignment.topCenter, child: FadeTransition(opacity: a, child: c)),
          child: entry.songUrl.isNotEmpty
              ? Padding(
                  key: ValueKey('${entry.song}|${entry.songUrl}|${state.songLookupPending}'),
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: _NowPlayingCard(
                    title: entry.song,
                    url: entry.songUrl,
                    loading: state.songLookupPending && entry.song.trim().isEmpty,
                  ),
                )
              : const SizedBox.shrink(key: ValueKey('none')),
        ),
        _MinimalField(controller: songCtrl, hint: t('🎵 Şarkı - sanatçı'), onChanged: (v) => state.updateEntry(date, song: v)),
        if (entry.songUrl.isEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          _SpotifyRow(song: entry.song, url: entry.songUrl),
        ],
      ],
    );
  }
}

class _DateStepButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final bool enabled;
  final VoidCallback onTap;
  const _DateStepButton({required this.icon, required this.tooltip, required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(icon, size: 20, color: enabled ? AppColors.textPrimary : AppColors.textFaint),
        ),
      ),
    );
  }
}

class _SectionDivider extends StatelessWidget {
  const _SectionDivider();
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        child: Divider(height: 1, color: AppColors.border),
      );
}

/// A borderless, underline-only text field — used inside cards that already
/// have their own border, so nesting a second outlined box on top would
/// look heavy.
class _MinimalField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;
  const _MinimalField({required this.controller, required this.hint, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: AppTextStyles.body(fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.body(fontSize: 14, color: AppColors.textFaint),
        isDense: true,
        filled: false,
        contentPadding: const EdgeInsets.symmetric(vertical: 8),
        border: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.border)),
        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.border)),
        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.coral, width: 1.5)),
      ),
    );
  }
}

class _MoodButton extends StatelessWidget {
  final String emoji;
  final bool selected;
  final VoidCallback onTap;
  const _MoodButton({required this.emoji, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final duration = AppMotion.of(context, AppMotion.standard);
    return Pressable(
      onTap: onTap,
      pressedScale: 0.88,
      child: AnimatedScale(
        scale: selected ? 1.15 : 1,
        duration: duration,
        curve: AppMotion.settle,
        child: AnimatedContainer(
          duration: duration,
          width: 48,
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.coralLight : AppColors.sunkenBg,
            shape: BoxShape.circle,
            border: Border.all(color: selected ? AppColors.coral : Colors.transparent, width: 2),
            boxShadow: selected
                ? [BoxShadow(color: AppColors.coral.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))]
                : null,
          ),
          child: Text(emoji, style: const TextStyle(fontSize: 22)),
        ),
      ),
    );
  }
}

class _ReasonChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _ReasonChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      pressedScale: 0.93,
      child: AnimatedContainer(
        duration: AppMotion.of(context, AppMotion.standard),
        curve: AppMotion.standardCurve,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.coral : AppColors.sunkenBg,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: AppTextStyles.body(
            fontSize: 12,
            weight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected ? AppColors.onCoral : AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}

class _WorkloadChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _WorkloadChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: AnimatedContainer(
        duration: AppMotion.of(context, AppMotion.standard),
        curve: AppMotion.standardCurve,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          color: selected ? AppColors.coral : AppColors.sunkenBg,
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        child: Text(
          label,
          style: AppTextStyles.body(
            fontSize: 13,
            weight: FontWeight.w600,
            color: selected ? AppColors.onCoral : AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}

class _MoodHistoryCard extends StatelessWidget {
  final AppState state;
  const _MoodHistoryCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final days = [
      for (var offset = 6; offset >= 0; offset--) DateTime(state.today.year, state.today.month, state.today.day - offset),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(t('Son 7 gün'), style: AppTextStyles.hand(fontSize: 24, color: AppColors.coral)),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          height: 36,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (final d in days)
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Builder(builder: (context) {
                    final mood = state.entryFor(d).mood;
                    final h = mood == 0 ? 4.0 : 36 * (mood / 5);
                    return TweenAnimationBuilder<double>(
                      tween: Tween(begin: 4, end: h),
                      duration: AppMotion.of(context, AppMotion.slow),
                      curve: AppMotion.emphasized,
                      builder: (context, v, _) => Container(
                        width: 14,
                        height: v,
                        decoration: BoxDecoration(
                          color: mood == 0
                              ? AppColors.sunkenBg
                              : mood >= 4
                                  ? AppColors.coral
                                  : AppColors.coral.withValues(alpha: 0.45),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    );
                  }),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

void _confirmResetBingo(BuildContext context, AppState state) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(t('Bingo kartını sıfırla')),
      content: Text(t('Tüm işaretler kaldırılacak. Devam edilsin mi?')),
      actions: [
        TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text(t('Vazgeç'))),
        TextButton(
          onPressed: () {
            state.resetBingoCard();
            Navigator.of(ctx).pop();
          },
          child: Text(t('Sıfırla')),
        ),
      ],
    ),
  );
}

void _showBingoSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.cardBg,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.cardLarge)),
    ),
    builder: (_) => const _BingoSheet(),
  );
}

/// Full-size bingo card: shows each square's text, tap to tick it off,
/// long-press to rewrite it into something from the user's own internship.
class _BingoSheet extends StatelessWidget {
  const _BingoSheet();

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final cells = state.bingoTasks.take(9).toList();
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(t('Staj Bingo'), style: AppTextStyles.head(fontSize: 17))),
                    TextButton(
                      onPressed: () => _confirmResetBingo(context, state),
                      child: Text(t('Sıfırla')),
                    ),
                  ],
                ),
                Text(
                  t('Dokun: işaretle · Uzun bas: kareyi düzenle'),
                  style: AppTextStyles.body(fontSize: 12, color: AppColors.textMuted),
                ),
                const SizedBox(height: AppSpacing.md),
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 3,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 1,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    for (final task in cells)
                      InkWell(
                        borderRadius: BorderRadius.circular(AppRadius.card),
                        onTap: () => state.toggleBingo(task.id),
                        onLongPress: () => _editBingoTask(context, state, task),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: task.done ? AppColors.coral : AppColors.coralLight,
                            borderRadius: BorderRadius.circular(AppRadius.card),
                          ),
                          child: Text(
                            task.done ? '✓ ${tStored(task.text)}' : tStored(task.text),
                            textAlign: TextAlign.center,
                            maxLines: 5,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.body(fontSize: 11, color: task.done ? AppColors.onCoral : AppColors.textPrimary),
                          ),
                        ),
                      ),
                  ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _editBingoTask(BuildContext context, AppState state, BingoTask task) {
    final ctrl = TextEditingController(text: tStored(task.text));
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t('Kareyi düzenle')),
        content: TextField(controller: ctrl, autofocus: true, maxLines: 3),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text(t('Vazgeç'))),
          TextButton(
            onPressed: () {
              state.updateBingoTaskText(task.id, ctrl.text);
              Navigator.of(ctx).pop();
            },
            child: Text(t('Kaydet')),
          ),
        ],
      ),
    );
  }
}

class _BingoCard extends StatelessWidget {
  final AppState state;
  const _BingoCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final cells = state.bingoTasks.take(9).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () => _showBingoSheet(context),
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        t('Bingo'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.hand(fontSize: 24, color: AppColors.coral),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.open_in_full, size: 12, color: AppColors.textFaint),
                  ],
                ),
              ),
            ),
            InkWell(
              onTap: () => _confirmResetBingo(context, state),
              child: Padding(
                padding: const EdgeInsets.all(2),
                child: Icon(Icons.refresh, size: 16, color: AppColors.textFaint),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Expanded(
          child: GridView.count(
            crossAxisCount: 3,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              for (final task in cells)
                Tooltip(
                  message: tStored(task.text),
                  child: InkWell(
                    onTap: () => state.toggleBingo(task.id),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: task.done ? AppColors.coral : AppColors.coralLight,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

void _showBadgesSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.cardBg,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.cardLarge)),
    ),
    builder: (_) => Consumer<AppState>(
      builder: (context, state, _) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Text(t('Rozetler'), style: AppTextStyles.head(fontSize: 17)),
            const SizedBox(height: AppSpacing.md),
            for (final b in state.badges)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: b.earned ? AppColors.coral : AppColors.coralLight,
                    shape: BoxShape.circle,
                  ),
                  child: Text(b.emoji, style: const TextStyle(fontSize: 18)),
                ),
                title: Text(b.label, style: AppTextStyles.body(fontSize: 14, weight: FontWeight.w600)),
                subtitle: Text(
                  b.earned
                      ? (b.earnedAt != null ? t('Kazanıldı · {date}', {'date': fullDateFor(b.earnedAt!)}) : t('Kazanıldı'))
                      : t('Henüz kazanılmadı'),
                  style: AppTextStyles.body(fontSize: 12, color: AppColors.textMuted),
                ),
              ),
          ],
        ),
      ),
    ),
  );
}

class _BadgesCard extends StatelessWidget {
  final AppState state;
  const _BadgesCard({required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => _showBadgesSheet(context),
          child: Row(
            children: [
              Flexible(
                child: Text(
                  t('Rozetler'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.hand(fontSize: 24, color: AppColors.coral),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '${state.badges.where((b) => b.earned).length}/${state.badges.length}',
                style: AppTextStyles.body(fontSize: 11, color: AppColors.textMuted),
              ),
              const SizedBox(width: 4),
              Icon(Icons.open_in_full, size: 12, color: AppColors.textFaint),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Expanded(
          child: Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final b in state.badges)
                Tooltip(
                  message: '${b.label}${b.earned ? '' : ' ${t('(henüz kazanılmadı)')}'}',
                  child: Container(
                    width: 32,
                    height: 32,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: b.earned ? AppColors.coral : AppColors.coralLight,
                      shape: BoxShape.circle,
                    ),
                    child: Opacity(opacity: b.earned ? 1 : 0.35, child: Text(b.emoji, style: const TextStyle(fontSize: 14))),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MentorCard extends StatelessWidget {
  final AppState state;
  const _MentorCard({required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(t('Mentor sözlüğü'), style: AppTextStyles.hand(fontSize: 24, color: AppColors.coral))),
            if (state.mentorQuotes.isNotEmpty)
              TextButton(
                onPressed: () => _showAllQuotes(context),
                child: Text(t('Tümü ({n})', {'n': state.mentorQuotes.length})),
              ),
            InkWell(
              onTap: () => _addQuote(context, state),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Icon(Icons.add_circle_outline, size: 20, color: AppColors.coral),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (state.mentorQuotes.isEmpty)
          Text(t('Henüz söz eklenmedi.'), style: AppTextStyles.body(fontSize: 13, color: AppColors.textMuted))
        else
          for (final q in state.mentorQuotes.take(3))
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                q.author != null && q.author!.isNotEmpty ? '"${q.quote}" — ${q.author}' : '"${q.quote}"',
                style: AppTextStyles.body(fontSize: 13, color: AppColors.textMuted).copyWith(fontStyle: FontStyle.italic),
              ),
            ),
      ],
    );
  }

  void _showAllQuotes(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.cardLarge)),
      ),
      builder: (_) => Consumer<AppState>(
        builder: (context, state, _) => SafeArea(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              Text(t('Mentor sözlüğü'), style: AppTextStyles.head(fontSize: 17)),
              const SizedBox(height: AppSpacing.sm),
              for (final q in state.mentorQuotes)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('"${q.quote}"', style: AppTextStyles.body(fontSize: 14).copyWith(fontStyle: FontStyle.italic)),
                  subtitle: q.author != null && q.author!.isNotEmpty
                      ? Text('— ${q.author}', style: AppTextStyles.body(fontSize: 12, color: AppColors.textMuted))
                      : null,
                  trailing: IconButton(
                    tooltip: t('Sil'),
                    icon: Icon(Icons.delete_outline, size: 20, color: AppColors.textMuted),
                    onPressed: () => state.removeMentorQuote(q.id),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _addQuote(BuildContext context, AppState state) {
    final quoteCtrl = TextEditingController();
    final authorCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t('Mentor sözü ekle')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: quoteCtrl, autofocus: true, decoration: InputDecoration(hintText: t('Söz'))),
            const SizedBox(height: 8),
            TextField(controller: authorCtrl, decoration: InputDecoration(hintText: t('Kim söyledi? (opsiyonel)'))),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text(t('Vazgeç'))),
          TextButton(
            onPressed: () {
              state.addMentorQuote(quoteCtrl.text, author: authorCtrl.text);
              Navigator.of(ctx).pop();
            },
            child: Text(t('Ekle')),
          ),
        ],
      ),
    );
  }
}

class _CapsuleCard extends StatelessWidget {
  final AppState state;
  const _CapsuleCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final i = state.internship!;
    final canReveal = !i.capsuleOpened && (i.capsuleExpectation.isNotEmpty || i.capsuleFear.isNotEmpty);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.hourglass_bottom, size: 16, color: AppColors.coral),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                t('Zaman Kapsülü'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.hand(fontSize: 24, color: AppColors.coral),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (i.capsuleOpened) ...[
          Text(t('Beklenti: {v}', {'v': i.capsuleExpectation}), style: AppTextStyles.body(fontSize: 12, color: AppColors.textMuted)),
          Text(t('Korku: {v}', {'v': i.capsuleFear}), style: AppTextStyles.body(fontSize: 12, color: AppColors.textMuted)),
          const SizedBox(height: 4),
          Text(t('Gerçekte ne oldu: {v}', {'v': i.capsuleReflection}), style: AppTextStyles.body(fontSize: 13)),
        ] else if (canReveal)
          TextButton(
            onPressed: () => _openCapsule(context, state),
            child: Text(t('Zaman kapsülünü aç')),
          )
        else
          Text(t('Staj başında bir beklenti ya da korku yazmadın.'), style: AppTextStyles.body(fontSize: 12, color: AppColors.textMuted)),
      ],
    );
  }

  void _openCapsule(BuildContext context, AppState state) {
    final i = state.internship!;
    final reflectionCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t('Zaman Kapsülü')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t('Beklentin: {v}', {'v': i.capsuleExpectation}), style: AppTextStyles.body(fontSize: 13)),
            Text(t('Korkun: {v}', {'v': i.capsuleFear}), style: AppTextStyles.body(fontSize: 13)),
            const SizedBox(height: 12),
            TextField(
              controller: reflectionCtrl,
              maxLines: 3,
              autofocus: true,
              decoration: InputDecoration(hintText: t('Gerçekte ne oldu?')),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text(t('Vazgeç'))),
          TextButton(
            onPressed: () {
              state.openCapsule(reflectionCtrl.text);
              Navigator.of(ctx).pop();
            },
            child: Text(t('Kaydet')),
          ),
        ],
      ),
    );
  }
}

/// Opens the song in Spotify when it was shared in with a link; otherwise
/// sends the user to Spotify (searching for what they typed) so they can
/// share the track back with Share → Cepte Staj.
class _SpotifyRow extends StatelessWidget {
  final String song;
  final String url;
  const _SpotifyRow({required this.song, required this.url});

  static const _spotifyGreen = Color(0xFF1DB954);

  Future<void> _open(BuildContext context) {
    final query = Uri.encodeComponent(song.trim());
    return _openSpotify(
      context,
      url.isNotEmpty
          ? [Uri.parse(url)]
          : [
              Uri.parse(song.trim().isEmpty ? 'spotify:' : 'spotify:search:$query'),
              Uri.parse(song.trim().isEmpty ? 'https://open.spotify.com' : 'https://open.spotify.com/search/$query'),
            ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasLink = url.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Pressable(
          onTap: () => _open(context),
          child: Container(
            padding: const EdgeInsets.fromLTRB(10, 7, 14, 7),
            decoration: BoxDecoration(
              color: _spotifyGreen.withValues(alpha: AppColors.isDark ? 0.2 : 0.12),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(hasLink ? Icons.play_circle_fill_rounded : Icons.search_rounded, size: 18, color: _spotifyGreen),
                const SizedBox(width: 6),
                Text(
                  hasLink ? t('Spotify\'da aç') : t('Spotify\'dan seç'),
                  style: AppTextStyles.body(fontSize: 13, weight: FontWeight.w600, color: _spotifyGreen),
                ),
              ],
            ),
          ),
        ),
        if (!hasLink) ...[
          const SizedBox(height: 6),
          Text(
            t('Spotify\'da şarkıda Paylaş → Cepte Staj\'a dokun, buraya gelsin.'),
            style: AppTextStyles.body(fontSize: 11, color: AppColors.textMuted),
          ),
        ],
      ],
    );
  }
}

Future<void> _openSpotify(BuildContext context, List<Uri> candidates) async {
  final messenger = ScaffoldMessenger.of(context);
  for (final uri in candidates) {
    try {
      if (await launchUrl(uri, mode: LaunchMode.externalApplication)) return;
    } catch (_) {}
  }
  messenger.showSnackBar(SnackBar(content: Text(t('Spotify açılamadı'))));
}

/// The shared song, shown big at the top of the "Bugünün şarkısı" section:
/// its name (looked up from the link) and a play button into Spotify.
class _NowPlayingCard extends StatelessWidget {
  final String title;
  final String url;
  final bool loading;
  const _NowPlayingCard({required this.title, required this.url, required this.loading});

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF1DB954);
    final name = title.trim().isNotEmpty
        ? title.trim()
        : loading
            ? t('Şarkı adı alınıyor…')
            : t('Adı bulunamadı — aşağıya yazabilirsin');
    return Pressable(
      onTap: () => _openSpotify(context, [Uri.parse(url)]),
      pressedScale: 0.98,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.card),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1ED760), Color(0xFF128A3E)],
          ),
          boxShadow: [BoxShadow(color: green.withValues(alpha: 0.3), blurRadius: 14, offset: const Offset(0, 6))],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.18), borderRadius: BorderRadius.circular(10)),
              child: loading
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                    )
                  : const Icon(Icons.music_note_rounded, color: Colors.white),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.body(fontSize: 15, weight: FontWeight.w700, color: Colors.white),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    t('Spotify\'da aç'),
                    style: AppTextStyles.body(fontSize: 12, weight: FontWeight.w500, color: Colors.white.withValues(alpha: 0.85)),
                  ),
                ],
              ),
            ),
            const Icon(Icons.play_circle_fill_rounded, size: 34, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
