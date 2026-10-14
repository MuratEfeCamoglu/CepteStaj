import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/i18n.dart';
import '../../core/tr_text.dart';
import '../../data/app_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_motion.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/motion.dart';

class _WrappedSlide {
  final String eyebrow;
  final String stat;
  final String unit;
  final String caption;
  const _WrappedSlide({
    required this.eyebrow,
    required this.stat,
    required this.unit,
    required this.caption,
  });
}

/// "Staj Wrapped" — a Spotify-Wrapped-style story summarizing the
/// internship so far. Swipe or tap the sides to move between slides.
class WrappedScreen extends StatefulWidget {
  const WrappedScreen({super.key});

  @override
  State<WrappedScreen> createState() => _WrappedScreenState();
}

class _WrappedScreenState extends State<WrappedScreen> {
  final _controller = PageController();
  int _page = 0;

  List<_WrappedSlide> _slides(AppState state) => [
    _WrappedSlide(
      eyebrow: t('Bu staj boyunca'),
      stat: state.totalWordsWritten.toString(),
      unit: t('kelime yazdın'),
      caption: t('defterine, her gün biraz daha'),
    ),
    _WrappedSlide(
      eyebrow: t('Toplam'),
      stat: '${state.filledWorkdays}',
      unit: t('gün doldurdun'),
      caption: t('{total} iş gününün {filled} tanesi tamam', {'total': state.totalWorkdays, 'filled': state.filledWorkdays}),
    ),
    _WrappedSlide(
      eyebrow: t('Güncel seri'),
      stat: '${state.currentStreak}',
      unit: t('gün üst üste'),
      caption: t('aralıksız defter tutma serisi'),
    ),
    if (state.quickCounters.isNotEmpty)
      _WrappedSlide(
        eyebrow: t('Bu staj boyunca içtin'),
        stat:
            '${state.quickCounters.firstWhereOrNull((c) => c.emoji == '☕')?.count ?? state.quickCounters.first.count}',
        unit: t('kahve'),
        caption: t('hızlı sayaçlardan toplandı'),
      ),
    _WrappedSlide(
      eyebrow: t('Kazandığın'),
      stat: '${state.badges.where((b) => b.earned).length}',
      unit: t('rozet'),
      caption: t('günlüğünden takip edebilirsin'),
    ),
  ];

  void _next(int count) {
    if (_page < count - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  void _prev() {
    if (_page > 0) {
      _controller.previousPage(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final slides = _slides(state);

    // Each card gets its own deep tone, story-style; the change cross-fades.
    const tones = [
      Color(0xFF0B7A6D),
      Color(0xFF3B2A7A),
      Color(0xFF075A50),
      Color(0xFF7A2E3B),
      Color(0xFF123F57),
    ];
    return AnimatedContainer(
      duration: AppMotion.of(context, AppMotion.slow),
      curve: AppMotion.standardCurve,
      color: tones[_page % tones.length],
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Row(
                      children: [
                        for (var i = 0; i < slides.length; i++)
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 2,
                              ),
                              child: Container(
                                height: 4,
                                clipBehavior: Clip.antiAlias,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.25),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: AnimatedFractionallySizedBox(
                                  alignment: Alignment.centerLeft,
                                  widthFactor: i <= _page ? 1 : 0,
                                  duration: AppMotion.of(
                                    context,
                                    AppMotion.slow,
                                  ),
                                  curve: AppMotion.emphasized,
                                  child: const ColoredBox(
                                    color: AppColors.onDeep,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: PageView.builder(
                      controller: _controller,
                      itemCount: slides.length,
                      onPageChanged: (i) => setState(() => _page = i),
                      itemBuilder: (context, i) => _SlideView(slide: slides[i]),
                    ),
                  ),
                ],
              ),
              // Left/right tap zones, story-style.
              Positioned.fill(
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: _prev,
                        behavior: HitTestBehavior.translucent,
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _next(slides.length),
                        behavior: HitTestBehavior.translucent,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 8,
                left: 8,
                child: IconButton(
                  tooltip: t('Paylaş'),
                  icon: const Icon(Icons.ios_share, color: AppColors.onDeep),
                  onPressed: () => _share(state, slides),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  tooltip: t('Kapat'),
                  icon: const Icon(Icons.close, color: AppColors.onDeep),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _share(AppState state, List<_WrappedSlide> slides) {
    final lines = [
      'Cepte Staj Wrapped — ${tStored(state.internship?.name ?? '')}',
      for (final s in slides) '${s.stat} ${s.unit}',
    ];
    SharePlus.instance.share(ShareParams(text: lines.join('\n')));
  }
}

class _SlideView extends StatelessWidget {
  final _WrappedSlide slide;
  const _SlideView({required this.slide});

  /// The big number, in highlighter ink, counting up to its value.
  Widget _statText(String stat) {
    final style = AppTextStyles.disp(
      fontSize: 104,
      color: AppColors.highlighter,
      height: 1,
    );
    final n = int.tryParse(stat);
    return n == null
        ? Text(stat, textAlign: TextAlign.center, style: style)
        : CountUpText(
            value: n,
            style: style,
            duration: const Duration(milliseconds: 1100),
          );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Entrance(
            child: Text(
              slide.eyebrow.toUpperTr(),
              textAlign: TextAlign.center,
              style: AppTextStyles.label(
                color: AppColors.onDeep.withValues(alpha: 0.7),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Entrance(index: 1, offsetY: 24, child: _statText(slide.stat)),
          const SizedBox(height: 4),
          Entrance(
            index: 3,
            child: Text(
              slide.unit,
              textAlign: TextAlign.center,
              style: AppTextStyles.disp(
                fontSize: 26,
                weight: FontWeight.w700,
                color: AppColors.onDeep,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Entrance(
            index: 4,
            child: Text(
              slide.caption,
              textAlign: TextAlign.center,
              style: AppTextStyles.body(
                fontSize: 14,
                color: AppColors.onDeep.withValues(alpha: 0.65),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
