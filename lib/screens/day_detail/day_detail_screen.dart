import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/i18n.dart';
import '../../core/snippets.dart';
import '../../data/app_state.dart';
import '../../models/models.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_motion.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/export_sheet.dart';
import '../../widgets/lined_paper_background.dart';
import '../../widgets/motion.dart';
import '../../widgets/responsive_content.dart';
import '../../widgets/segmented_tabs.dart';

/// "Gün Detayı" — the note-taking screen for the official side of a day:
/// the Defter entry and an attached Fotoğraf. The private/personal side
/// (ruh hali, Günün Olayı, ...) lives only on the Günlüğüm tab now — see
/// JournalScreen — so it isn't duplicated here.
class DayDetailScreen extends StatefulWidget {
  final DateTime date;

  const DayDetailScreen({super.key, required this.date});

  @override
  State<DayDetailScreen> createState() => _DayDetailScreenState();
}

class _DayDetailScreenState extends State<DayDetailScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final entry = state.entryFor(widget.date);
    final idx = state.workdayIndexFor(widget.date);
    return Scaffold(
      backgroundColor: AppColors.screenBg,
      appBar: AppBar(
        leading: BackButton(color: AppColors.textPrimary),
        title: Text(
          idx != null
              ? '${weekdayNameFor(widget.date)} · ${t('{n}. gün', {'n': idx})}'
              : weekdayNameFor(widget.date),
          style: AppTextStyles.head(fontSize: 18),
        ),
        actions: [
          IconButton(
            tooltip: t('Paylaş / indir'),
            icon: Icon(Icons.ios_share_rounded, color: AppColors.textPrimary),
            onPressed: () => showExportSheet(context, day: widget.date),
          ),
          IconButton(
            tooltip: entry.signed ? t('İmzalandı ✓') : t('İmzalandı olarak işaretle'),
            icon: Icon(
              entry.signed ? Icons.verified : Icons.verified_outlined,
              color: entry.signed ? AppColors.checkGreen : AppColors.textMuted,
            ),
            onPressed: () => state.markSigned(widget.date),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            ResponsiveContent(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.sm,
                  AppSpacing.lg,
                  AppSpacing.md,
                ),
                child: SegmentedTabs(
                  labels: [t('Defter'), t('Fotoğraf')],
                  selectedIndex: _tab,
                  onChanged: (i) => setState(() => _tab = i),
                ),
              ),
            ),
            Expanded(
              child: _tab == 0
                  ? _DefterTab(date: widget.date)
                  : _FotografTab(date: widget.date),
            ),
          ],
        ),
      ),
    );
  }
}

class _DefterTab extends StatefulWidget {
  final DateTime date;
  const _DefterTab({required this.date});

  @override
  State<_DefterTab> createState() => _DefterTabState();
}

class _DefterTabState extends State<_DefterTab> {
  late final TextEditingController _topicCtrl;
  late final TextEditingController _bodyCtrl;
  late final TextEditingController _learnedCtrl;

  @override
  void initState() {
    super.initState();
    final entry = context.read<AppState>().entryFor(widget.date);
    _topicCtrl = TextEditingController(text: entry.topic);
    _bodyCtrl = TextEditingController(text: entry.body);
    _learnedCtrl = TextEditingController(text: entry.learned);
  }

  @override
  void dispose() {
    _topicCtrl.dispose();
    _bodyCtrl.dispose();
    _learnedCtrl.dispose();
    super.dispose();
  }

  void _insertSnippet(AppState state, String text) {
    final sep =
        _bodyCtrl.text.isEmpty ||
            _bodyCtrl.text.endsWith(' ') ||
            _bodyCtrl.text.endsWith('\n')
        ? ''
        : ' ';
    _bodyCtrl.text = '${_bodyCtrl.text}$sep$text';
    _bodyCtrl.selection = TextSelection.collapsed(
      offset: _bodyCtrl.text.length,
    );
    state.updateEntry(widget.date, body: _bodyCtrl.text);
    setState(() {});
  }

  Future<void> _copyFromYesterday(AppState state) async {
    final ok = state.copyFromYesterday(widget.date);
    if (!mounted) return;
    if (ok) {
      final e = state.entryFor(widget.date);
      _topicCtrl.text = e.topic;
      _bodyCtrl.text = e.body;
      _learnedCtrl.text = e.learned;
      setState(() {});
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? t('Önceki günün kaydı kopyalandı')
              : t('Kopyalanacak önceki kayıt yok'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final entry = state.entryFor(widget.date);
    final goal = state.internship?.dailyWordGoal ?? 120;
    final progress = goal == 0
        ? 0.0
        : (entry.wordCount / goal).clamp(0, 1).toDouble();

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              ResponsiveContent(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    0,
                    AppSpacing.lg,
                    AppSpacing.md,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            shortDateFor(widget.date),
                            style: AppTextStyles.body(
                              fontSize: 13,
                              color: AppColors.textMuted,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () => _copyFromYesterday(state),
                            icon: Icon(
                              Icons.content_copy,
                              size: 14,
                              color: AppColors.textMuted,
                            ),
                            label: Text(
                              t('Dünden kopyala'),
                              style: AppTextStyles.body(
                                fontSize: 12,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      TextField(
                        controller: _topicCtrl,
                        onChanged: (v) =>
                            state.updateEntry(widget.date, topic: v),
                        style: AppTextStyles.body(fontSize: 14),
                        decoration: _fieldDecoration(
                          t(fieldFor(state.internship?.field ?? 'general').topicHint),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _SnippetPanel(onInsert: (s) => _insertSnippet(state, s)),
                      const SizedBox(height: AppSpacing.md),
                      Container(
                        constraints: const BoxConstraints(minHeight: 220),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.cardBg,
                          borderRadius: BorderRadius.circular(
                            AppRadius.cardLarge,
                          ),
                          boxShadow: AppColors.cardShadow,
                        ),
                        child: Stack(
                          children: [
                            LinedPaperBackground(
                              lineHeight: 26,
                              opacity: 0.7,
                              lineColor: AppColors.border,
                            ),
                            TextField(
                              controller: _bodyCtrl,
                              maxLines: null,
                              minLines: 8,
                              onChanged: (v) =>
                                  state.updateEntry(widget.date, body: v),
                              style: AppTextStyles.body(
                                fontSize: 16,
                                height: 26 / 16,
                              ),
                              decoration: const InputDecoration(
                                filled: false,
                                border: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 8,
                                ),
                                counterText: '',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          Expanded(
                            child: _TimeButton(
                              label: t('Giriş'),
                              value: entry.checkIn,
                              onPicked: (v) =>
                                  state.updateEntry(widget.date, checkIn: v),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: _TimeButton(
                              label: t('Çıkış'),
                              value: entry.checkOut,
                              onPicked: (v) =>
                                  state.updateEntry(widget.date, checkOut: v),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      TextField(
                        controller: _learnedCtrl,
                        onChanged: (v) =>
                            state.updateEntry(widget.date, learned: v),
                        style: AppTextStyles.body(fontSize: 14),
                        minLines: 2,
                        maxLines: 4,
                        decoration: _fieldDecoration(t('Öğrendiklerim')),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        ResponsiveContent(
          child: Container(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Glides as you type; turns green once the daily goal is met.
                TweenAnimationBuilder<double>(
                  tween: Tween(end: progress),
                  duration: AppMotion.of(context, AppMotion.standard),
                  curve: AppMotion.standardCurve,
                  builder: (context, v, _) => ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: v,
                      minHeight: 6,
                      backgroundColor: AppColors.sunkenBg,
                      valueColor: AlwaysStoppedAnimation(
                        progress >= 1 ? AppColors.checkGreen : AppColors.ink,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: Wrap(
                        spacing: AppSpacing.md,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          _CountStat(
                            value: '${entry.wordCount}',
                            unit: t('/ {g} kelime', {'g': goal}),
                          ),
                          _CountStat(
                            value:
                                '~${entry.lineEstimate(state.internship?.wordsPerLine ?? 12)}',
                            unit: t('satır'),
                          ),
                          if (progress >= 1)
                            PopIn(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.checkGreen.withValues(
                                    alpha: 0.14,
                                  ),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  t('Hedef tamam'),
                                  style: AppTextStyles.body(
                                    fontSize: 11,
                                    weight: FontWeight.w600,
                                    color: AppColors.checkGreen,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Pressable(
                      onTap: () {
                        FocusScope.of(context).unfocus();
                        state.saveNow();
                        Navigator.of(context).maybePop();
                      },
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(12, 9, 16, 9),
                        decoration: BoxDecoration(
                          color: AppColors.ink,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_rounded,
                              size: 18,
                              color: AppColors.onInk,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              t('Bitti'),
                              style: AppTextStyles.body(
                                fontSize: 13,
                                weight: FontWeight.w600,
                                color: AppColors.onInk,
                              ),
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
        ),
      ],
    );
  }

  InputDecoration _fieldDecoration(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: AppTextStyles.body(fontSize: 14, color: AppColors.textFaint),
    filled: true,
    fillColor: AppColors.sunkenBg,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.card),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.card),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.card),
      borderSide: BorderSide(color: AppColors.ink, width: 1.5),
    ),
  );
}

class _TimeButton extends StatelessWidget {
  final String label;
  final String value;
  final ValueChanged<String> onPicked;
  const _TimeButton({
    required this.label,
    required this.value,
    required this.onPicked,
  });

  @override
  Widget build(BuildContext context) {
    return Pressable(
      borderRadius: BorderRadius.circular(AppRadius.card),
      pressedScale: 0.97,
      onTap: () async {
        var initial = const TimeOfDay(hour: 9, minute: 0);
        final parts = value.split(':');
        if (parts.length == 2) {
          final h = int.tryParse(parts[0]);
          final m = int.tryParse(parts[1]);
          if (h != null && m != null) initial = TimeOfDay(hour: h, minute: m);
        }
        final picked = await showTimePicker(
          context: context,
          initialTime: initial,
        );
        if (picked != null) {
          onPicked(
            '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}',
          );
        }
      },
      onLongPress: value.isEmpty ? null : () => onPicked(''),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.sunkenBg,
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        child: Row(
          children: [
            Icon(
              Icons.schedule_rounded,
              size: 16,
              color: value.isEmpty ? AppColors.textMuted : AppColors.ink,
            ),
            const SizedBox(width: 8),
            Text(
              value.isEmpty ? label : '$label  $value',
              style: AppTextStyles.body(
                fontSize: 14,
                color: value.isEmpty
                    ? AppColors.textFaint
                    : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A compact "42 / 120 kelime" style stat — bold value, muted unit label
/// right after it on the same line.
class _CountStat extends StatelessWidget {
  final String value;
  final String unit;
  const _CountStat({required this.value, required this.unit});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          value,
          style: AppTextStyles.disp(
            fontSize: 18,
            weight: FontWeight.w700,
          ).copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
        ),
        const SizedBox(width: 4),
        Text(
          unit,
          style: AppTextStyles.body(fontSize: 12, color: AppColors.textMuted),
        ),
      ],
    );
  }
}

class _FotografTab extends StatelessWidget {
  final DateTime date;
  const _FotografTab({required this.date});

  Future<void> _add(BuildContext context, {required bool fromCamera}) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await context.read<AppState>().addPhoto(date, fromCamera: fromCamera);
    } catch (_) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            fromCamera
                ? t('Kamera açılamadı. İzinleri kontrol et.')
                : t('Fotoğraf seçilemedi.'),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final photos = state.photosFor(date);

    return Column(
      children: [
        Expanded(
          child: photos.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xxxl),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(
                            color: AppColors.sunkenBg,
                            borderRadius: BorderRadius.circular(AppRadius.card),
                          ),
                          child: Icon(
                            Icons.add_a_photo_outlined,
                            color: AppColors.textFaint,
                            size: 28,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          t('Bu güne bir fotoğraf ekle'),
                          style: AppTextStyles.body(
                            fontSize: 14,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : ResponsiveContent(
                  child: GridView.builder(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.md,
                      AppSpacing.lg,
                      AppSpacing.lg,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          childAspectRatio: 0.9,
                        ),
                    itemCount: photos.length,
                    itemBuilder: (context, i) => _PhotoTile(
                      key: ValueKey(photos[i].id),
                      photo: photos[i],
                    ),
                  ),
                ),
        ),
        ResponsiveContent(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              0,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _add(context, fromCamera: true),
                    icon: const Icon(Icons.photo_camera_outlined, size: 18),
                    label: Text(t('Kamera')),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _add(context, fromCamera: false),
                    icon: const Icon(Icons.photo_library_outlined, size: 18),
                    label: Text(t('Galeri')),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PhotoTile extends StatelessWidget {
  final DayPhoto photo;
  const _PhotoTile({super.key, required this.photo});

  Future<void> _confirmDelete(BuildContext context, AppState state) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t('Fotoğrafı sil')),
        content: Text(t('Bu fotoğraf kalıcı olarak silinecek.')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(t('Vazgeç')),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(t('Sil')),
          ),
        ],
      ),
    );
    if (ok == true) state.deletePhoto(photo.id);
  }

  @override
  Widget build(BuildContext context) {
    final state = context.read<AppState>();
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.file(
                  File(photo.filePath),
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => ColoredBox(
                    color: AppColors.sunkenBg,
                    child: Icon(Icons.broken_image_outlined, color: AppColors.textFaint),
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: InkWell(
                    onTap: () => _confirmDelete(context, state),
                    borderRadius: BorderRadius.circular(999),
                    child: const CircleAvatar(
                      radius: 13,
                      backgroundColor: Colors.black54,
                      child: Icon(Icons.close, size: 14, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: photo.caption,
                    onChanged: (v) => state.updatePhotoCaption(photo.id, v),
                    style: AppTextStyles.body(fontSize: 11),
                    decoration: InputDecoration(
                      isDense: true,
                      filled: false,
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      hintText: t('Açıklama...'),
                    ),
                  ),
                ),
                Tooltip(
                  message: photo.includeInExport
                      ? t('Resmi Defter PDF\'ine dahil')
                      : t('PDF\'e ekle (varsayılan: kişisel)'),
                  child: InkWell(
                    onTap: () => state.togglePhotoIncludeInExport(photo.id),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        photo.includeInExport
                            ? Icons.picture_as_pdf
                            : Icons.picture_as_pdf_outlined,
                        size: 18,
                        color: photo.includeInExport
                            ? AppColors.ink
                            : AppColors.textFaint,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Ready-made sentences for the student's field plus their own saved ones.
/// Collapsed to a handful by default so the writing area stays in view.
class _SnippetPanel extends StatefulWidget {
  final ValueChanged<String> onInsert;
  const _SnippetPanel({required this.onInsert});

  @override
  State<_SnippetPanel> createState() => _SnippetPanelState();
}

class _SnippetPanelState extends State<_SnippetPanel> {
  static const _collapsedCount = 6;
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final field = fieldFor(state.internship?.field ?? 'general');
    final builtIn = [for (final s in snippetsFor(field.key)) t(s)];
    final all = [...state.customSnippets, ...builtIn];
    final shown = _expanded ? all : all.take(_collapsedCount).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(t('Hazır cümleler'), style: AppTextStyles.body(fontSize: 12, weight: FontWeight.w600, color: AppColors.textMuted)),
            const Spacer(),
            Pressable(
              onTap: () => showFieldPicker(context),
              child: Container(
                padding: const EdgeInsets.fromLTRB(10, 5, 6, 5),
                decoration: BoxDecoration(color: AppColors.sunkenBg, borderRadius: BorderRadius.circular(999)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('${field.emoji} ${t(field.label)}',
                        style: AppTextStyles.body(fontSize: 12, weight: FontWeight.w600)),
                    Icon(Icons.expand_more_rounded, size: 16, color: AppColors.textMuted),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        AnimatedSize(
          duration: AppMotion.of(context, AppMotion.standard),
          curve: AppMotion.emphasized,
          alignment: Alignment.topLeft,
          child: Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final s in shown)
                _SnippetChip(
                  text: s,
                  custom: state.customSnippets.contains(s),
                  onTap: () => widget.onInsert(s),
                  onLongPress: state.customSnippets.contains(s) ? () => _confirmRemove(context, state, s) : null,
                ),
              _SnippetChip(
                text: t('Kendi cümlen'),
                icon: Icons.bookmark_add_outlined,
                muted: true,
                onTap: () => _addCustom(context, state),
              ),
              if (all.length > _collapsedCount)
                _SnippetChip(
                  text: _expanded ? t('Daha az') : t('Tümü ({n})', {'n': all.length}),
                  icon: _expanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                  muted: true,
                  onTap: () => setState(() => _expanded = !_expanded),
                ),
            ],
          ),
        ),
      ],
    );
  }

  void _addCustom(BuildContext context, AppState state) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t('Kendi cümleni kaydet')),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          maxLines: 3,
          minLines: 1,
          decoration: InputDecoration(hintText: t('Sık yazdığın bir cümle')),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text(t('Vazgeç'))),
          TextButton(
            onPressed: () {
              state.addCustomSnippet(ctrl.text);
              Navigator.of(ctx).pop();
            },
            child: Text(t('Kaydet')),
          ),
        ],
      ),
    );
  }

  void _confirmRemove(BuildContext context, AppState state, String s) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t('Cümleyi sil')),
        content: Text('"$s"'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text(t('Vazgeç'))),
          TextButton(
            onPressed: () {
              state.removeCustomSnippet(s);
              Navigator.of(ctx).pop();
            },
            child: Text(t('Sil')),
          ),
        ],
      ),
    );
  }
}

class _SnippetChip extends StatelessWidget {
  final String text;
  final IconData icon;
  final bool custom;
  final bool muted;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const _SnippetChip({
    required this.text,
    required this.onTap,
    this.icon = Icons.add_rounded,
    this.custom = false,
    this.muted = false,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final fg = muted ? AppColors.textMuted : (custom ? AppColors.violet : AppColors.ink);
    final bg = muted ? AppColors.sunkenBg : (custom ? AppColors.tint(AppColors.violet) : AppColors.inkLight);
    return Pressable(
      onTap: onTap,
      onLongPress: onLongPress,
      pressedScale: 0.94,
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 7, 12, 7),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(custom ? Icons.bookmark_rounded : icon, size: 14, color: fg),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                text,
                style: AppTextStyles.body(fontSize: 12, weight: FontWeight.w500, color: fg),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bottom sheet for choosing the internship field — shared by the Defter
/// sentence panel and Ayarlar.
Future<void> showFieldPicker(BuildContext context) {
  final state = context.read<AppState>();
  final current = state.internship?.field ?? 'general';
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t('Staj alanın'), style: AppTextStyles.head(fontSize: 18)),
            const SizedBox(height: 4),
            Text(
              t('Hazır cümleler bu alana göre gösterilir.'),
              style: AppTextStyles.body(fontSize: 13, color: AppColors.textMuted),
            ),
            const SizedBox(height: AppSpacing.md),
            FieldChips(
              selected: current,
              onSelected: (key) {
                Navigator.of(ctx).pop();
                if (key != current) state.setField(key);
              },
            ),
          ],
        ),
      ),
    ),
  );
}

/// Wrap of selectable field chips, used in onboarding and the picker sheet.
class FieldChips extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelected;
  const FieldChips({super.key, required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final f in internshipFields)
          Pressable(
            onTap: () => onSelected(f.key),
            child: AnimatedContainer(
              duration: AppMotion.of(context, AppMotion.standard),
              curve: AppMotion.standardCurve,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: f.key == selected ? AppColors.ink : AppColors.sunkenBg,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '${f.emoji}  ${t(f.label)}',
                style: AppTextStyles.body(
                  fontSize: 13,
                  weight: FontWeight.w600,
                  color: f.key == selected ? AppColors.onInk : AppColors.textPrimary,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
