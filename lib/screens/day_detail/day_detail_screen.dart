import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/app_state.dart';
import '../../models/models.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/lined_paper_background.dart';
import '../../widgets/responsive_content.dart';
import '../../widgets/segmented_tabs.dart';
import '../paper_mode/paper_mode_screen.dart';

const _monthNames = ['Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran', 'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'];
const _weekdayNames = ['Pazartesi', 'Salı', 'Çarşamba', 'Perşembe', 'Cuma', 'Cumartesi', 'Pazar'];

String weekdayNameFor(DateTime d) => _weekdayNames[d.weekday - 1];
String shortDateFor(DateTime d) => '${d.day} ${_monthNames[d.month - 1]}';

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
          idx != null ? '${weekdayNameFor(widget.date)} · $idx. gün' : weekdayNameFor(widget.date),
          style: AppTextStyles.body(fontSize: 15),
        ),
        actions: [
          IconButton(
            tooltip: entry.signed ? 'İmzalandı ✓' : 'İmzalandı olarak işaretle',
            icon: Icon(entry.signed ? Icons.verified : Icons.verified_outlined,
                color: entry.signed ? AppColors.checkGreen : AppColors.textMuted),
            onPressed: () => state.markSigned(widget.date),
          ),
          TextButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => PaperModeScreen(date: widget.date)),
            ),
            icon: const Icon(Icons.edit_note, size: 18, color: AppColors.ink),
            label: Text('Kağıda geçir', style: AppTextStyles.body(fontSize: 13, weight: FontWeight.w600, color: AppColors.ink)),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            ResponsiveContent(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.md),
                child: SegmentedTabs(
                  labels: const ['Defter', 'Fotoğraf'],
                  selectedIndex: _tab,
                  onChanged: (i) => setState(() => _tab = i),
                ),
              ),
            ),
            Expanded(
              child: _tab == 0 ? _DefterTab(date: widget.date) : _FotografTab(date: widget.date),
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

  static const _defaultSnippets = [
    'Ekibin daily toplantısına katıldım.',
    'Mentörümle birebir görüştüm.',
    'Dokümantasyon inceledim.',
    'Kod incelemesine (code review) katıldım.',
  ];

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
    final sep = _bodyCtrl.text.isEmpty || _bodyCtrl.text.endsWith(' ') || _bodyCtrl.text.endsWith('\n') ? '' : ' ';
    _bodyCtrl.text = '${_bodyCtrl.text}$sep$text';
    _bodyCtrl.selection = TextSelection.collapsed(offset: _bodyCtrl.text.length);
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
      SnackBar(content: Text(ok ? 'Önceki günün kaydı kopyalandı' : 'Kopyalanacak önceki kayıt yok')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final entry = state.entryFor(widget.date);
    final goal = state.internship?.dailyWordGoal ?? 120;
    final progress = goal == 0 ? 0.0 : (entry.wordCount / goal).clamp(0, 1).toDouble();

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              ResponsiveContent(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(shortDateFor(widget.date), style: AppTextStyles.body(fontSize: 13, color: AppColors.textMuted)),
                          TextButton.icon(
                            onPressed: () => _copyFromYesterday(state),
                            icon: Icon(Icons.content_copy, size: 14, color: AppColors.textMuted),
                            label: Text('Dünden kopyala', style: AppTextStyles.body(fontSize: 12, color: AppColors.textMuted)),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      TextField(
                        controller: _topicCtrl,
                        onChanged: (v) => state.updateEntry(widget.date, topic: v),
                        style: AppTextStyles.body(fontSize: 14),
                        decoration: _fieldDecoration('Konu (örn. API entegrasyonu)'),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          for (final s in _defaultSnippets)
                            ActionChip(
                              backgroundColor: AppColors.sunkenBg,
                              side: BorderSide.none,
                              label: Text(s, style: AppTextStyles.body(fontSize: 11, color: AppColors.textMuted)),
                              onPressed: () => _insertSnippet(state, s),
                            ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Container(
                        constraints: const BoxConstraints(minHeight: 220),
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.cardBg,
                          borderRadius: BorderRadius.circular(AppRadius.card),
                        ),
                        child: Stack(
                          children: [
                            LinedPaperBackground(lineHeight: 26, opacity: 0.7, lineColor: AppColors.border),
                            TextField(
                              controller: _bodyCtrl,
                              maxLines: null,
                              minLines: 8,
                              onChanged: (v) => state.updateEntry(widget.date, body: v),
                              style: AppTextStyles.body(fontSize: 16, height: 26 / 16),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
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
                              label: 'Giriş',
                              value: entry.checkIn,
                              onPicked: (v) => state.updateEntry(widget.date, checkIn: v),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: _TimeButton(
                              label: 'Çıkış',
                              value: entry.checkOut,
                              onPicked: (v) => state.updateEntry(widget.date, checkOut: v),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      TextField(
                        controller: _learnedCtrl,
                        onChanged: (v) => state.updateEntry(widget.date, learned: v),
                        style: AppTextStyles.body(fontSize: 14),
                        minLines: 2,
                        maxLines: 4,
                        decoration: _fieldDecoration('Öğrendiklerim'),
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
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.lg),
            decoration: BoxDecoration(color: AppColors.cardBg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 3,
                    backgroundColor: AppColors.sunkenBg,
                    valueColor: const AlwaysStoppedAnimation(AppColors.ink),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    _CountStat(value: '${entry.wordCount}', unit: '/ $goal kelime'),
                    const SizedBox(width: AppSpacing.lg),
                    _CountStat(
                      value: '~${entry.lineEstimate(state.internship?.wordsPerLine ?? 12)}',
                      unit: 'satır',
                    ),
                    const Spacer(),
                    if (entry.copiedToPaper) const Icon(Icons.check_circle, size: 18, color: AppColors.checkGreen),
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
          borderSide: const BorderSide(color: AppColors.ink, width: 1.5),
        ),
      );
}

class _TimeButton extends StatelessWidget {
  final String label;
  final String value;
  final ValueChanged<String> onPicked;
  const _TimeButton({required this.label, required this.value, required this.onPicked});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.card),
      onTap: () async {
        var initial = const TimeOfDay(hour: 9, minute: 0);
        final parts = value.split(':');
        if (parts.length == 2) {
          final h = int.tryParse(parts[0]);
          final m = int.tryParse(parts[1]);
          if (h != null && m != null) initial = TimeOfDay(hour: h, minute: m);
        }
        final picked = await showTimePicker(context: context, initialTime: initial);
        if (picked != null) {
          onPicked('${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}');
        }
      },
      onLongPress: value.isEmpty ? null : () => onPicked(''),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(color: AppColors.sunkenBg, borderRadius: BorderRadius.circular(AppRadius.card)),
        child: Row(
          children: [
            Icon(Icons.schedule, size: 16, color: AppColors.textMuted),
            const SizedBox(width: 8),
            Text(
              value.isEmpty ? label : '$label  $value',
              style: AppTextStyles.body(fontSize: 14, color: value.isEmpty ? AppColors.textFaint : AppColors.textPrimary),
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
        Text(value, style: AppTextStyles.body(fontSize: 13, weight: FontWeight.w700)),
        const SizedBox(width: 4),
        Text(unit, style: AppTextStyles.body(fontSize: 12, color: AppColors.textMuted)),
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
        SnackBar(content: Text(fromCamera ? 'Kamera açılamadı. İzinleri kontrol et.' : 'Fotoğraf seçilemedi.')),
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
                          child: Icon(Icons.add_a_photo_outlined, color: AppColors.textFaint, size: 28),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text('Bu güne bir fotoğraf ekle', style: AppTextStyles.body(fontSize: 14, color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                )
              : ResponsiveContent(
                  child: GridView.builder(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.lg),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 0.9,
                    ),
                    itemCount: photos.length,
                    itemBuilder: (context, i) => _PhotoTile(key: ValueKey(photos[i].id), photo: photos[i]),
                  ),
                ),
        ),
        ResponsiveContent(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _add(context, fromCamera: true),
                    icon: const Icon(Icons.photo_camera_outlined, size: 18),
                    label: const Text('Kamera'),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _add(context, fromCamera: false),
                    icon: const Icon(Icons.photo_library_outlined, size: 18),
                    label: const Text('Galeri'),
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
        title: const Text('Fotoğrafı sil'),
        content: const Text('Bu fotoğraf kalıcı olarak silinecek.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Vazgeç')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Sil')),
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
                Image.file(File(photo.filePath), fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const ColoredBox(color: Colors.black12, child: Icon(Icons.broken_image_outlined))),
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
                    decoration: const InputDecoration(
                      isDense: true,
                      border: InputBorder.none,
                      hintText: 'Açıklama...',
                    ),
                  ),
                ),
                Tooltip(
                  message: photo.includeInExport ? 'Resmi Defter PDF\'ine dahil' : 'PDF\'e ekle (varsayılan: kişisel)',
                  child: InkWell(
                    onTap: () => state.togglePhotoIncludeInExport(photo.id),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        photo.includeInExport ? Icons.picture_as_pdf : Icons.picture_as_pdf_outlined,
                        size: 18,
                        color: photo.includeInExport ? AppColors.ink : AppColors.textFaint,
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
