import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/app_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/lined_paper_background.dart';
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
        title: Text('Kağıda geçir', style: AppTextStyles.body(fontSize: 15)),
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
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: InkWell(
                          onTap: isCurrent ? () => setState(() => _doneCount++) : null,
                          child: Opacity(
                            opacity: opacity,
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                if (isDone)
                                  const Positioned(
                                    left: -24,
                                    top: 4,
                                    child: Text('✓', style: TextStyle(color: AppColors.checkGreen, fontSize: 16)),
                                  ),
                                Text(
                                  lines[i],
                                  style: AppTextStyles.body(fontSize: fontSize, height: 1.95, color: color),
                                ),
                              ],
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
                    decoration: BoxDecoration(color: AppColors.cardBg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isEmpty ? '' : allDone ? 'Tüm satırlar tamam' : '~$remaining satır kaldı',
                          style: AppTextStyles.body(fontSize: 12, color: AppColors.textMuted),
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
