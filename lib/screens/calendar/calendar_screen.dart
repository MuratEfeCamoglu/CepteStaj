import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
import '../../widgets/responsive_content.dart';
import '../../widgets/segmented_tabs.dart';
import '../day_detail/day_detail_screen.dart';

/// Mood → color, 1 (worst) .. 5 (best). Used by the "Ruh hali" view.
Color moodColor(int mood) => switch (mood) {
      1 => AppColors.danger,
      2 => AppColors.warning,
      3 => AppColors.textMuted,
      4 => AppColors.sky,
      _ => AppColors.checkGreen,
    };

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _month;
  DateTime? _selected;
  int _mode = 0; // 0 = durum, 1 = ruh hali
  int _direction = 1; // which way the month grid slides in

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = DateTime(now.year, now.month, 1);
    _selected = DateTime(now.year, now.month, now.day);
  }

  void _shiftMonth(int delta, DateTime today) {
    setState(() {
      _direction = delta;
      _month = DateTime(_month.year, _month.month + delta, 1);
      _selected = _isSameMonth(today, _month) ? today : null;
    });
  }

  void _goToday(DateTime today) {
    setState(() {
      _direction = today.isBefore(_month) ? -1 : 1;
      _month = DateTime(today.year, today.month, 1);
      _selected = today;
    });
  }

  static bool _isSameMonth(DateTime a, DateTime b) => a.year == b.year && a.month == b.month;

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final days = state.calendarForMonth(_month);
        if (days.isEmpty) return const SizedBox.shrink();
        final today = state.today;
        final onCurrentMonth = _isSameMonth(today, _month);
        final selectedDay = _selected == null ? null : days.where((d) => d.date == _selected).firstOrNull;

        return SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.xxl),
            children: [
              ResponsiveContent(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Entrance(
                      child: Row(
                        children: [
                          Expanded(child: Text(t('Takvim'), style: AppTextStyles.disp(fontSize: 30))),
                          AnimatedSwitcher(
                            duration: AppMotion.of(context, AppMotion.standard),
                            transitionBuilder: (c, a) => ScaleTransition(scale: a, child: FadeTransition(opacity: a, child: c)),
                            child: onCurrentMonth
                                ? const SizedBox.shrink()
                                : Pressable(
                                    onTap: () => _goToday(today),
                                    child: Container(
                                      padding: const EdgeInsets.fromLTRB(10, 7, 12, 7),
                                      decoration: BoxDecoration(
                                        color: AppColors.inkLight,
                                        borderRadius: BorderRadius.circular(999),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.today_rounded, size: 16, color: AppColors.ink),
                                          const SizedBox(width: 6),
                                          Text(
                                            t('Bugün'),
                                            style: AppTextStyles.body(fontSize: 13, weight: FontWeight.w600, color: AppColors.ink),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Entrance(
                      index: 1,
                      child: SegmentedTabs(
                        labels: [t('Durum'), t('Ruh hali')],
                        selectedIndex: _mode,
                        onChanged: (i) => setState(() => _mode = i),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Entrance(
                      index: 2,
                      child: _MonthCard(
                        month: _month,
                        days: days,
                        mode: _mode,
                        direction: _direction,
                        selected: _selected,
                        state: state,
                        onPrev: () => _shiftMonth(-1, today),
                        onNext: () => _shiftMonth(1, today),
                        onSelect: (d) {
                          if (_selected == d) {
                            _openDay(context, d);
                          } else {
                            setState(() => _selected = d);
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Entrance(index: 3, child: _Legend(mode: _mode)),
                    const SizedBox(height: AppSpacing.lg),
                    Entrance(
                      index: 4,
                      child: AnimatedSize(
                        duration: AppMotion.of(context, AppMotion.standard),
                        curve: AppMotion.emphasized,
                        alignment: Alignment.topCenter,
                        child: AnimatedSwitcher(
                          duration: AppMotion.of(context, AppMotion.standard),
                          switchInCurve: AppMotion.emphasized,
                          transitionBuilder: (c, a) => FadeTransition(
                            opacity: a,
                            child: SlideTransition(
                              position: Tween(begin: const Offset(0, 0.04), end: Offset.zero).animate(a),
                              child: c,
                            ),
                          ),
                          child: selectedDay == null
                              ? _SelectHint(key: const ValueKey('hint'))
                              : _DayPreview(key: ValueKey(selectedDay.date), state: state, day: selectedDay),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Entrance(index: 5, child: _MonthSummary(state: state, month: _month, days: days)),
                    ..._holidaySection(state),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _holidaySection(AppState state) {
    final holidays = state.holidaysInMonth(_month);
    if (holidays.isEmpty) return const [];
    return [
      const SizedBox(height: AppSpacing.xl),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Text(t('Bu ayın resmi tatilleri').toUpperTr(), style: AppTextStyles.label()),
      ),
      const SizedBox(height: AppSpacing.sm),
      Container(
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(AppRadius.cardLarge),
          boxShadow: AppColors.cardShadow,
        ),
        child: Column(
          children: [
            for (var i = 0; i < holidays.length; i++) ...[
              if (i > 0) Divider(height: 1, indent: 64, color: AppColors.border),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 10),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: AppColors.tint(AppColors.sky), borderRadius: BorderRadius.circular(12)),
                      child: Text(
                        '${holidays[i].$1.day}',
                        style: AppTextStyles.disp(fontSize: 17, color: AppColors.sky),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(t(holidays[i].$2), style: AppTextStyles.body(fontSize: 14, weight: FontWeight.w600)),
                          Text(weekdayNameFor(holidays[i].$1),
                              style: AppTextStyles.body(fontSize: 12, color: AppColors.textMuted)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    ];
  }
}

void _openDay(BuildContext context, DateTime date) {
  Navigator.of(context).push(MaterialPageRoute(builder: (_) => DayDetailScreen(date: date)));
}

class _MonthCard extends StatelessWidget {
  final DateTime month;
  final List<CalendarDay> days;
  final int mode;
  final int direction;
  final DateTime? selected;
  final AppState state;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final ValueChanged<DateTime> onSelect;

  const _MonthCard({
    required this.month,
    required this.days,
    required this.mode,
    required this.direction,
    required this.selected,
    required this.state,
    required this.onPrev,
    required this.onNext,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final leadingBlanks = (days.first.date.weekday - 1) % 7; // Monday=0
    final start = state.internship == null ? null : DateUtils.dateOnly(state.internship!.startDate);
    final end = state.endDate;

    return Container(
      padding: const EdgeInsets.fromLTRB(AppSpacing.sm, AppSpacing.sm, AppSpacing.sm, AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(AppRadius.cardLarge),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        children: [
          Row(
            children: [
              _NavButton(icon: Icons.chevron_left_rounded, tooltip: t('Önceki ay'), onTap: onPrev),
              Expanded(
                child: AnimatedSwitcher(
                  duration: AppMotion.of(context, AppMotion.standard),
                  child: Text(
                    monthYearFor(month),
                    key: ValueKey(month),
                    textAlign: TextAlign.center,
                    style: AppTextStyles.head(fontSize: 17),
                  ),
                ),
              ),
              _NavButton(icon: Icons.chevron_right_rounded, tooltip: t('Sonraki ay'), onTap: onNext),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              for (final l in weekdayLetters)
                Expanded(
                  child: Center(
                    child: Text(
                      l,
                      style: AppTextStyles.body(fontSize: 12, weight: FontWeight.w600, color: AppColors.textFaint),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          // Swipe sideways to change month.
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onHorizontalDragEnd: (d) {
              final v = d.primaryVelocity ?? 0;
              if (v < -250) onNext();
              if (v > 250) onPrev();
            },
            child: AnimatedSwitcher(
              duration: AppMotion.of(context, AppMotion.standard),
              switchInCurve: AppMotion.emphasized,
              switchOutCurve: Curves.easeIn,
              layoutBuilder: (current, previous) => Stack(
                alignment: Alignment.topCenter,
                children: [...previous, ?current],
              ),
              transitionBuilder: (child, animation) {
                final incoming = child.key == ValueKey(month);
                final dx = (incoming ? 0.12 : -0.12) * direction;
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween(begin: Offset(dx, 0), end: Offset.zero).animate(animation),
                    child: child,
                  ),
                );
              },
              child: GridView.count(
                key: ValueKey(month),
                shrinkWrap: true,
                crossAxisCount: 7,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  for (var i = 0; i < leadingBlanks; i++) const SizedBox.shrink(),
                  for (final day in days)
                    _DayCell(
                      day: day,
                      mode: mode,
                      mood: state.existingEntry(day.date)?.mood ?? 0,
                      selected: selected == day.date,
                      isStart: start != null && day.date == start,
                      isEnd: state.hasInternship && day.date == end,
                      onTap: () => onSelect(day.date),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  const _NavButton({required this.icon, required this.tooltip, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Pressable(
        onTap: onTap,
        pressedScale: 0.88,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(color: AppColors.sunkenBg, shape: BoxShape.circle),
          child: Icon(icon, color: AppColors.textPrimary),
        ),
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  final CalendarDay day;
  final int mode;
  final int mood;
  final bool selected;
  final bool isStart;
  final bool isEnd;
  final VoidCallback onTap;

  const _DayCell({
    required this.day,
    required this.mode,
    required this.mood,
    required this.selected,
    required this.isStart,
    required this.isEnd,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final duration = AppMotion.of(context, AppMotion.standard);
    return LayoutBuilder(
      builder: (context, constraints) {
        final side = constraints.biggest.shortestSide;
        final dot = (side * 0.84).clamp(26.0, 46.0);
        final fontSize = (dot * 0.38).clamp(11.0, 16.0);

        Color bg = Colors.transparent;
        Color fg = AppColors.textPrimary;
        Widget? content;
        FontWeight weight = FontWeight.w600;

        if (mode == 1) {
          if (mood > 0) {
            bg = AppColors.tint(moodColor(mood));
            content = Text(moodEmojis[mood - 1], style: TextStyle(fontSize: fontSize + 2));
          } else {
            fg = day.type == DayType.future ? AppColors.textFaint : AppColors.textMuted;
            weight = FontWeight.w500;
          }
        } else {
          switch (day.type) {
            case DayType.filled:
              bg = AppColors.ink;
              fg = AppColors.onInk;
            case DayType.empty:
              bg = AppColors.tint(AppColors.warning);
              fg = AppColors.warning;
            case DayType.holiday:
              bg = AppColors.tint(AppColors.sky);
              fg = AppColors.sky;
            case DayType.notWorkday:
              fg = AppColors.textFaint;
              weight = FontWeight.w500;
            case DayType.future:
              fg = AppColors.textMuted;
              weight = FontWeight.w500;
          }
        }
        if (day.isToday && bg == Colors.transparent) {
          bg = AppColors.highlighter;
          fg = AppColors.onHighlighter;
        }

        content ??= Text(
          '${day.date.day}',
          style: AppTextStyles.body(fontSize: fontSize, weight: weight, color: fg)
              .copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
        );

        return Semantics(
          button: true,
          selected: selected,
          label: fullDateFor(day.date),
          child: Pressable(
            onTap: onTap,
            pressedScale: 0.85,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                AnimatedContainer(
                  duration: duration,
                  curve: AppMotion.standardCurve,
                  width: dot,
                  height: dot,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: bg,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected
                          ? AppColors.textPrimary
                          : day.isToday && bg != AppColors.highlighter
                              ? AppColors.highlighter
                              : Colors.transparent,
                      width: selected ? 2 : 2.5,
                    ),
                  ),
                  child: content,
                ),
                if (isStart || isEnd)
                  Positioned(
                    top: 0,
                    right: 2,
                    child: Container(
                      width: 16,
                      height: 16,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isEnd ? AppColors.coral : AppColors.checkGreen,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.cardBg, width: 1.5),
                      ),
                      child: Icon(
                        isEnd ? Icons.flag_rounded : Icons.play_arrow_rounded,
                        size: 9,
                        color: Colors.white,
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
}

class _Legend extends StatelessWidget {
  final int mode;
  const _Legend({required this.mode});

  @override
  Widget build(BuildContext context) {
    final items = mode == 0
        ? [
            (AppColors.ink, t('dolu')),
            (AppColors.warning, t('eksik')),
            (AppColors.sky, t('tatil')),
            (AppColors.highlighter, t('bugün')),
            (AppColors.checkGreen, t('başlangıç')),
            (AppColors.coral, t('bitiş')),
          ]
        : [
            for (var m = 1; m <= 5; m++) (moodColor(m), moodEmojis[m - 1]),
          ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Wrap(
        spacing: 12,
        runSpacing: 6,
        children: [
          for (final (color, label) in items)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                ),
                const SizedBox(width: 5),
                Text(label, style: AppTextStyles.body(fontSize: 11, color: AppColors.textMuted)),
              ],
            ),
        ],
      ),
    );
  }
}

class _SelectHint extends StatelessWidget {
  const _SelectHint({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.sunkenBg,
        borderRadius: BorderRadius.circular(AppRadius.cardLarge),
      ),
      child: Row(
        children: [
          Icon(Icons.touch_app_outlined, color: AppColors.textMuted),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              t('Bir güne dokun, özetini burada gör. İkinci dokunuş günü açar.'),
              style: AppTextStyles.body(fontSize: 13, color: AppColors.textMuted),
            ),
          ),
        ],
      ),
    );
  }
}

/// Summary of the selected day under the grid — what's written, the
/// times, the mood — with one button into the full day.
class _DayPreview extends StatelessWidget {
  final AppState state;
  final CalendarDay day;
  const _DayPreview({super.key, required this.state, required this.day});

  @override
  Widget build(BuildContext context) {
    final entry = state.existingEntry(day.date);
    final filled = entry?.hasOfficialContent ?? false;
    final photos = state.photosFor(day.date).length;
    final holiday = day.type == DayType.holiday ? state.holidaysInMonth(day.date).where((h) => h.$1 == day.date).firstOrNull?.$2 : null;
    final idx = state.workdayIndexFor(day.date);

    final (String label, Color color) = switch (day.type) {
      DayType.filled => (t('Dolu'), AppColors.ink),
      DayType.empty => (t('Eksik'), AppColors.warning),
      DayType.holiday => (t('Resmi tatil'), AppColors.sky),
      DayType.future => (t('İleri tarih'), AppColors.textMuted),
      DayType.notWorkday => (t('İş günü değil'), AppColors.textMuted),
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(AppRadius.cardLarge),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${weekdayNameFor(day.date)}${idx != null ? ' · ${t('{n}. gün', {'n': idx})}' : ''}'.toUpperTr(),
                      style: AppTextStyles.label(),
                    ),
                    const SizedBox(height: 2),
                    Text(shortDateFor(day.date), style: AppTextStyles.disp(fontSize: 24)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: AppColors.tint(color), borderRadius: BorderRadius.circular(999)),
                child: Text(label, style: AppTextStyles.body(fontSize: 12, weight: FontWeight.w600, color: color)),
              ),
            ],
          ),
          if (holiday != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text('🎉 ${t(holiday)}', style: AppTextStyles.body(fontSize: 14, weight: FontWeight.w600)),
          ],
          if (filled) ...[
            const SizedBox(height: AppSpacing.md),
            if (entry!.topic.trim().isNotEmpty)
              Text(entry.topic.trim(), style: AppTextStyles.body(fontSize: 15, weight: FontWeight.w600)),
            if (entry.body.trim().isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                entry.body.trim(),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.body(fontSize: 13, color: AppColors.textMuted, height: 1.45),
              ),
            ],
          ],
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              if (filled) _InfoPill(icon: Icons.notes_rounded, text: t('{n} kelime', {'n': entry!.wordCount})),
              if (entry != null && (entry.checkIn.isNotEmpty || entry.checkOut.isNotEmpty))
                _InfoPill(
                  icon: Icons.schedule_rounded,
                  text: '${entry.checkIn.isEmpty ? '—' : entry.checkIn} – ${entry.checkOut.isEmpty ? '—' : entry.checkOut}',
                ),
              if (photos > 0) _InfoPill(icon: Icons.photo_outlined, text: t('{n} fotoğraf', {'n': photos})),
              if (entry != null && entry.signed) _InfoPill(icon: Icons.verified_rounded, text: t('İmzalandı'), color: AppColors.checkGreen),
              if (entry != null && entry.mood > 0)
                _InfoPill(emoji: moodEmojis[entry.mood - 1], text: t('ruh hali'), color: AppColors.coral),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          PrimaryButton(
            label: filled ? t('Günü aç') : t('Bu günü doldur'),
            icon: filled ? Icons.menu_book_rounded : Icons.draw_rounded,
            onTap: () => _openDay(context, day.date),
          ),
        ],
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final IconData? icon;
  final String? emoji;
  final String text;
  final Color? color;
  const _InfoPill({this.icon, this.emoji, required this.text, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.textMuted;
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 5, 10, 5),
      decoration: BoxDecoration(color: AppColors.sunkenBg, borderRadius: BorderRadius.circular(999)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) Icon(icon, size: 14, color: c),
          if (emoji != null) Text(emoji!, style: const TextStyle(fontSize: 13)),
          const SizedBox(width: 5),
          Text(text, style: AppTextStyles.body(fontSize: 12, weight: FontWeight.w600, color: c)),
        ],
      ),
    );
  }
}

class _MonthSummary extends StatelessWidget {
  final AppState state;
  final DateTime month;
  final List<CalendarDay> days;
  const _MonthSummary({required this.state, required this.month, required this.days});

  @override
  Widget build(BuildContext context) {
    final filled = days.where((d) => d.type == DayType.filled).length;
    final empty = days.where((d) => d.type == DayType.empty).length;
    final holidays = days.where((d) => d.type == DayType.holiday).length;
    final words = state.wordsInMonth(month);
    final workdays = filled + empty;
    final ratio = workdays == 0 ? 0.0 : filled / workdays;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(AppRadius.cardLarge),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(t('{month} özeti', {'month': monthName(month.month)}), style: AppTextStyles.head(fontSize: 16)),
          const SizedBox(height: 2),
          Text(
            t('Bu ay {n} gün doldurdun', {'n': filled}),
            style: AppTextStyles.body(fontSize: 13, color: AppColors.textMuted),
          ),
          const SizedBox(height: AppSpacing.md),
          TweenAnimationBuilder<double>(
            key: ValueKey(month),
            tween: Tween(begin: 0, end: ratio),
            duration: AppMotion.of(context, AppMotion.slow),
            curve: AppMotion.emphasized,
            builder: (context, v, _) => ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: v,
                minHeight: 8,
                backgroundColor: AppColors.tint(AppColors.warning),
                valueColor: AlwaysStoppedAnimation(AppColors.ink),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              _SummaryStat(value: filled, label: t('dolu'), color: AppColors.ink),
              _SummaryStat(value: empty, label: t('eksik'), color: AppColors.warning),
              _SummaryStat(value: holidays, label: t('tatil'), color: AppColors.sky),
              _SummaryStat(value: words, label: t('kelime'), color: AppColors.violet),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryStat extends StatelessWidget {
  final int value;
  final String label;
  final Color color;
  const _SummaryStat({required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: CountUpText(value: value, style: AppTextStyles.disp(fontSize: 22, color: color)),
          ),
          Text(label, style: AppTextStyles.body(fontSize: 12, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}
