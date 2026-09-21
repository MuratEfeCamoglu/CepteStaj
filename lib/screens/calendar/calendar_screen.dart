import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/app_state.dart';
import '../../models/models.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/responsive_content.dart';
import '../day_detail/day_detail_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _month;

  static const _weekdayLetters = ['P', 'S', 'Ç', 'P', 'C', 'C', 'P'];
  static const _monthNames = [
    'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
    'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık',
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = DateTime(now.year, now.month, 1);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final days = state.calendarForMonth(_month);
        if (days.isEmpty) return const SizedBox.shrink();
        final leadingBlanks = (days.first.date.weekday - 1) % 7; // Monday=0
        final rowCount = ((leadingBlanks + days.length) / 7).ceil();
        return SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ResponsiveContent(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.xs),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Takvim', style: AppTextStyles.disp(fontSize: 26)),
                      Row(
                        children: [
                          InkWell(
                            onTap: () => setState(() => _month = DateTime(_month.year, _month.month - 1, 1)),
                            borderRadius: BorderRadius.circular(999),
                            child: Padding(
                              padding: const EdgeInsets.all(6),
                              child: Icon(Icons.chevron_left, color: AppColors.textPrimary),
                            ),
                          ),
                          SizedBox(
                            width: 108,
                            child: Text(
                              '${_monthNames[_month.month - 1]} ${_month.year}',
                              textAlign: TextAlign.center,
                              style: AppTextStyles.body(fontSize: 14, weight: FontWeight.w600),
                            ),
                          ),
                          InkWell(
                            onTap: () => setState(() => _month = DateTime(_month.year, _month.month + 1, 1)),
                            borderRadius: BorderRadius.circular(999),
                            child: Padding(
                              padding: const EdgeInsets.all(6),
                              child: Icon(Icons.chevron_right, color: AppColors.textPrimary),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              ResponsiveContent(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.sm),
                  child: Wrap(
                    spacing: 14,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      _Legend(dot: true, filled: true, label: 'dolu'),
                      _Legend(dot: true, filled: false, label: 'eksik'),
                      _Legend(symbol: '╱', label: 'tatil'),
                      _Legend(symbol: '✓', label: 'kağıda yazıldı'),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: ResponsiveContent(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.md),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.cardBg,
                        borderRadius: BorderRadius.circular(AppRadius.cardLarge),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              for (final l in _weekdayLetters)
                                Expanded(
                                  child: Center(
                                    child: Text(l,
                                        style: AppTextStyles.body(
                                            fontSize: 12, weight: FontWeight.w600, color: AppColors.textFaint)),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Expanded(
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                const spacing = 4.0;
                                final cellWidth = (constraints.maxWidth - spacing * 6) / 7;
                                final cellHeight = (constraints.maxHeight - spacing * (rowCount - 1)) / rowCount;
                                return GridView.count(
                                  crossAxisCount: 7,
                                  mainAxisSpacing: spacing,
                                  crossAxisSpacing: spacing,
                                  childAspectRatio: cellWidth / cellHeight,
                                  physics: const NeverScrollableScrollPhysics(),
                                  children: [
                                    for (var i = 0; i < leadingBlanks; i++) const SizedBox.shrink(),
                                    for (final day in days)
                                      _DayCell(
                                        day: day,
                                        onTap: () => Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) => DayDetailScreen(date: day.date),
                                          ),
                                        ),
                                      ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              ResponsiveContent(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
                  child: Text(
                    'Bu ay ${state.filledThisMonth} gün doldurdun',
                    style: AppTextStyles.body(fontSize: 13, color: AppColors.textMuted),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DayCell extends StatelessWidget {
  final CalendarDay day;
  final VoidCallback onTap;
  const _DayCell({required this.day, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Scale everything off the actual cell size so the grid stays
        // proportionate whether it renders small (many weeks) or large
        // (few weeks, wide screen).
        final side = constraints.biggest.shortestSide;
        final dot = (side * 0.72).clamp(22.0, 40.0);
        final fontSize = (dot * 0.42).clamp(11.0, 16.0);

        Widget child;
        switch (day.type) {
          case DayType.filled:
            child = _dot(dot, fontSize, AppColors.ink, '${day.date.day}');
            break;
          case DayType.writtenToPaper:
            child = _dot(dot, fontSize, AppColors.ink, '✓', isSymbol: true);
            break;
          case DayType.holiday:
            child = Text('╱', style: AppTextStyles.body(fontSize: fontSize, color: AppColors.textFaint));
            break;
          case DayType.notWorkday:
          case DayType.future:
            child = Text('${day.date.day}',
                style: AppTextStyles.body(fontSize: fontSize, color: AppColors.textFaint).copyWith(
                  fontFeatures: const [FontFeature.tabularFigures()],
                ));
            break;
          case DayType.empty:
            child = Text('${day.date.day}',
                style: AppTextStyles.body(fontSize: fontSize, weight: FontWeight.w600, color: AppColors.warning).copyWith(
                  fontFeatures: const [FontFeature.tabularFigures()],
                ));
            break;
        }
        return InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (day.isToday)
                Container(
                  width: dot + 6,
                  height: dot + 6,
                  decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.ink, width: 1.4)),
                ),
              Center(child: child),
            ],
          ),
        );
      },
    );
  }

  Widget _dot(double size, double fontSize, Color color, String label, {bool isSymbol = false}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Text(
        label,
        style: AppTextStyles.body(fontSize: fontSize, color: AppColors.onInk).copyWith(
          fontFeatures: isSymbol ? null : const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final bool dot;
  final bool filled;
  final String? symbol;
  final String label;

  const _Legend({this.dot = false, this.filled = false, this.symbol, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (dot)
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(right: 4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: filled ? AppColors.ink : Colors.transparent,
              border: filled ? null : Border.all(color: AppColors.borderLight, width: 1.5),
            ),
          )
        else if (symbol != null)
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Text(symbol!, style: AppTextStyles.body(fontSize: 11, color: AppColors.textMuted)),
          ),
        Text(label, style: AppTextStyles.body(fontSize: 11, color: AppColors.textMuted)),
      ],
    );
  }
}
