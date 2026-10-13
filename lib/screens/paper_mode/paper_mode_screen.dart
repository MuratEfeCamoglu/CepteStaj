import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../data/app_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_motion.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/lined_paper_background.dart';
import '../../widgets/motion.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/responsive_content.dart';

/// "Kağıda Geçirme Modu" — walks the user line-by-line through their
/// digital notebook entry so it's easy to copy out onto the physical
/// internship notebook. Tap the highlighted line once you've written it
/// down to advance to the next.
class PaperModeScreen extends StatefulWidget {
  final DateTime date;
  const PaperModeScreen({super.key, required this.date});

  @override
  State<PaperModeScreen> createState() => _PaperModeScreenState();
}

class _PaperModeScreenState extends State<PaperModeScreen> {
  int _doneCount = 0;
  double _fontScale = 0.38; // matches the ~38% slider position in the design

  // Keep the screen on while copying — the user's eyes and hands are on the
  // paper notebook, and the phone dimming mid-sentence breaks the flow.
  // Failures (e.g. no plugin in tests) are harmless: the screen just dims.
  @override
  void initState() {
    super.initState();
    WakelockPlus.enable().catchError((_) {});
  }

  @override
  void dispose() {
    WakelockPlus.disable().catchError((_) {});
    super.dispose();
  }

  List<String> _linesFor(String topic, String body, String learned) {
    final lines = <String>[];
    if (topic.trim().isNotEmpty) lines.add(topic.trim());
    lines.addAll(
      body
          .split(RegExp(r'(?<=[.!?])\s+'))
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty),
    );
    if (learned.trim().isNotEmpty) lines.add('Öğrendiklerim: ${learned.trim()}');
    return lines;
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final entry = state.entryFor(widget.date);
    final lines = _linesFor(entry.topic, entry.body, entry.learned);
    final isEmpty = lines.isEmpty;
    final doneCount = _doneCount.clamp(0, lines.length);
    final remaining = (lines.length - doneCount).clamp(0, lines.length);
    final allDone = remaining == 0;
    final fontSize = 20 + _fontScale * 16; // 20..36

    return Scaffold(
      backgroundColor: AppColors.screenBg,
      appBar: AppBar(
        leading: BackButton(color: AppColors.textPrimary),
        title: Text('Kağıda geçir', style: AppTextStyles.head(fontSize: 18)),
      ),
      body: SafeArea(
        top: false,
        child: Stack(
          children: [
            const LinedPaperBackground(),
            Column(
              children: [
                Expanded(
                  child: ResponsiveContent(
                    child: isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(AppSpacing.xxxl),
                              child: Text(
                                'Bu gün için henüz bir defter kaydın yok.',
                                textAlign: TextAlign.center,
                                style: AppTextStyles.body(fontSize: 16, color: AppColors.textMuted),
                              ),
                            ),
                          )
                        : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(36, 12, 20, 12),
                    itemCount: lines.length,
                    itemBuilder: (context, i) {
                      final isDone = i < doneCount;
                      final isCurrent = i == doneCount;
                      Color color;
                      double opacity;
                      if (isDone) {
                        color = AppColors.textPrimary;
                        opacity = 0.45;
                      } else if (isCurrent) {
                        color = AppColors.textPrimary;
                        opacity = 1;
                      } else {
                        color = AppColors.textFaint;
                        opacity = 1;
                      }
                      final duration = AppMotion.of(context, AppMotion.standard);
                      // The line being copied right now is marked with the
                      // highlighter; the mark moves down as lines are ticked.
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: InkWell(
                          onTap: isCurrent
                              ? () {
                                  HapticFeedback.lightImpact();
                                  setState(() => _doneCount++);
                                }
                              : null,
                          child: AnimatedOpacity(
                            opacity: opacity,
                            duration: duration,
                            child: AnimatedContainer(
                              duration: duration,
                              curve: AppMotion.standardCurve,
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                              decoration: BoxDecoration(
                                color: isCurrent ? AppColors.highlighter.withValues(alpha: AppColors.isDark ? 0.92 : 0.6) : Colors.transparent,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  if (isDone)
                                    const Positioned(
                                      left: -28,
                                      top: 4,
                                      child: PopIn(
                                        child: Icon(Icons.check_rounded, color: AppColors.checkGreen, size: 20),
                                      ),
                                    ),
                                  Text(
                                    lines[i],
                                    style: AppTextStyles.body(
                                      fontSize: fontSize,
                                      height: 1.95,
                                      color: isCurrent ? AppColors.onHighlighter : color,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    ),
                  ),
                ),
                ResponsiveContent(
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: AppColors.cardBg,
                      border: Border(top: BorderSide(color: AppColors.border)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!isEmpty) ...[
                          TweenAnimationBuilder<double>(
                            tween: Tween(end: lines.isEmpty ? 0 : doneCount / lines.length),
                            duration: AppMotion.of(context, AppMotion.standard),
                            curve: AppMotion.standardCurve,
                            builder: (context, v, _) => LinearProgressIndicator(
                              value: v,
                              minHeight: 6,
                              color: allDone ? AppColors.checkGreen : AppColors.ink,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                        ],
                        Text(
                          isEmpty ? '' : allDone ? 'Tüm satırlar tamam' : '~$remaining satır kaldı',
                          style: AppTextStyles.body(fontSize: 13, weight: FontWeight.w600, color: allDone ? AppColors.checkGreen : AppColors.textMuted),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          children: [
                            Text('A', style: TextStyle(fontSize: 13, color: AppColors.textFaint)),
                            Expanded(
                              child: SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  activeTrackColor: AppColors.ink,
                                  inactiveTrackColor: AppColors.sunkenBg,
                                  thumbColor: AppColors.ink,
                                  overlayColor: AppColors.ink.withValues(alpha: 0.12),
                                  trackHeight: 4,
                                ),
                                child: Slider(
                                  value: _fontScale,
                                  onChanged: (v) => setState(() => _fontScale = v),
                                ),
                              ),
                            ),
                            Text('A', style: TextStyle(fontSize: 20, color: AppColors.textMuted)),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        PrimaryButton(
                          label: isEmpty ? 'Geri dön' : 'Bitti',
                          onTap: allDone
                              ? () {
                                  if (!isEmpty) state.markCopiedToPaper(widget.date);
                                  Navigator.of(context).pop();
                                }
                              : () => setState(() => _doneCount = lines.length),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
