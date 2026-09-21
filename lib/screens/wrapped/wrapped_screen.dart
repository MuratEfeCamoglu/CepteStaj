import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/app_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

class _WrappedSlide {
  final String eyebrow;
  final String stat;
  final String unit;
  final String caption;
  const _WrappedSlide({required this.eyebrow, required this.stat, required this.unit, required this.caption});
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
          eyebrow: 'Bu staj boyunca',
          stat: state.totalWordsWritten.toString(),
          unit: 'kelime yazdın',
          caption: 'defterine, her gün biraz daha',
        ),
        _WrappedSlide(
          eyebrow: 'Toplam',
          stat: '${state.filledWorkdays}',
          unit: 'gün doldurdun',
          caption: '${state.totalWorkdays} iş gününün ${state.filledWorkdays} tanesi tamam',
        ),
        _WrappedSlide(
          eyebrow: 'Güncel seri',
          stat: '${state.currentStreak}',
          unit: 'gün üst üste',
          caption: 'aralıksız defter tutma serisi',
        ),
        if (state.quickCounters.isNotEmpty)
          _WrappedSlide(
            eyebrow: 'Bu staj boyunca içtin',
            stat: '${state.quickCounters.firstWhereOrNull((c) => c.emoji == '☕')?.count ?? state.quickCounters.first.count}',
            unit: 'kahve',
            caption: 'hızlı sayaçlardan toplandı',
          ),
        _WrappedSlide(
          eyebrow: 'Kazandığın',
          stat: '${state.badges.where((b) => b.earned).length}',
          unit: 'rozet',
          caption: 'günlüğünden takip edebilirsin',
        ),
      ];

  void _next(int count) {
    if (_page < count - 1) {
      _controller.nextPage(duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
    } else {
      Navigator.of(context).pop();
    }
  }

  void _prev() {
    if (_page > 0) {
      _controller.previousPage(duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
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

    return Scaffold(
      backgroundColor: AppColors.ink,
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
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(999),
                              child: LinearProgressIndicator(
                                value: i < _page
                                    ? 1
                                    : i == _page
                                        ? 1
                                        : 0,
                                minHeight: 3,
                                backgroundColor: Colors.white.withValues(alpha: 0.35),
                                valueColor: AlwaysStoppedAnimation(
                                  i <= _page ? AppColors.onInk : Colors.transparent,
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
                  Expanded(child: GestureDetector(onTap: _prev, behavior: HitTestBehavior.translucent)),
                  Expanded(child: GestureDetector(onTap: () => _next(slides.length), behavior: HitTestBehavior.translucent)),
                ],
              ),
            ),
            Positioned(
              top: 8,
              left: 8,
              child: IconButton(
                icon: const Icon(Icons.ios_share, color: AppColors.onInk),
                onPressed: () => _share(state, slides),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.close, color: AppColors.onInk),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _share(AppState state, List<_WrappedSlide> slides) {
    final lines = [
      'Cepte Staj Wrapped — ${state.internship?.name ?? ''}',
      for (final s in slides) '${s.stat} ${s.unit}',
    ];
    SharePlus.instance.share(ShareParams(text: lines.join('\n')));
  }
}

class _SlideView extends StatelessWidget {
  final _WrappedSlide slide;
  const _SlideView({required this.slide});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            slide.eyebrow,
            textAlign: TextAlign.center,
            style: AppTextStyles.body(fontSize: 14, color: AppColors.onInk.withValues(alpha: 0.7)),
          ),
          const SizedBox(height: 12),
          Text(
            slide.stat,
            textAlign: TextAlign.center,
            style: AppTextStyles.disp(fontSize: 64, color: AppColors.onInk, height: 1).copyWith(
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            slide.unit,
            textAlign: TextAlign.center,
            style: AppTextStyles.body(fontSize: 18, weight: FontWeight.w600, color: AppColors.onInk),
          ),
          const SizedBox(height: 8),
          Text(
            slide.caption,
            textAlign: TextAlign.center,
            style: AppTextStyles.body(fontSize: 13, color: AppColors.onInk.withValues(alpha: 0.6)),
          ),
        ],
      ),
    );
  }
}
