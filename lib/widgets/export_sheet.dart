import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/i18n.dart';
import '../core/tr_text.dart';
import '../core/official_export.dart';
import '../core/pdf_export.dart';
import '../data/app_state.dart';
import '../models/models.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// "Paylaş / indir" bottom sheet for the Resmi Defter.
///
/// With [day] set it exports that single day and also offers sending it as
/// a WhatsApp / text message; without it, it exports the whole notebook as
/// a file (PDF or Word). Only official fields ever leave — see
/// [OfficialExport] / [PdfExportService].
Future<void> showExportSheet(BuildContext context, {DateTime? day}) {
  final state = context.read<AppState>();
  final internship = state.internship;
  if (internship == null) return Future.value();

  final entries = day != null ? [state.entryFor(day)] : state.allEntries;
  if (!entries.any((e) => e.hasOfficialContent)) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(day != null
            ? t('Bu gün için henüz defter yazısı yok.')
            : t('Henüz doldurulmuş bir defter kaydı yok.')),
      ),
    );
    return Future.value();
  }

  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (_) => _ExportSheet(
      internship: internship,
      entries: entries,
      photos: state.photos,
      singleDay: day != null ? entries.single : null,
    ),
  );
}

enum _Format { pdf, docx }

class _ExportSheet extends StatelessWidget {
  final Internship internship;
  final List<DayEntry> entries;
  final List<DayPhoto> photos;
  final DayEntry? singleDay;

  const _ExportSheet({
    required this.internship,
    required this.entries,
    required this.photos,
    required this.singleDay,
  });

  String get _baseName => singleDay != null ? 'staj_defteri_${singleDay!.date}' : 'staj_defteri';

  @override
  Widget build(BuildContext context) {
    final day = singleDay;
    return SafeArea(
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.md),
        children: [
          Text(
            day != null
                ? t('{date} — paylaş / indir', {'date': OfficialExport.formatDate(day.date)})
                : t('Resmi Defter — paylaş / indir'),
            style: AppTextStyles.head(fontSize: 17),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            t('Yalnızca defter yazısı paylaşılır. Günlüğüm her zaman sende kalır.'),
            style: AppTextStyles.body(fontSize: 12, color: AppColors.textMuted),
          ),
          if (day != null) ...[
            _Header(t('Mesaj olarak')),
            _Option(
              icon: Icons.chat_outlined,
              label: t("WhatsApp'ta gönder"),
              onTap: () => _run(context, () => OfficialExport.sendToWhatsApp(OfficialExport.dayText(day))),
            ),
            _Option(
              icon: Icons.share_outlined,
              label: t('Başka uygulamada paylaş'),
              onTap: () => _run(
                context,
                () => OfficialExport.shareText(OfficialExport.dayText(day), subject: t('Staj Defteri — {date}', {'date': OfficialExport.formatDate(day.date)})),
              ),
            ),
          ],
          _Header(t('Dosya olarak')),
          _Option(
            icon: Icons.picture_as_pdf_outlined,
            label: t('PDF indir'),
            onTap: () => _save(context, _Format.pdf),
          ),
          _Option(
            icon: Icons.description_outlined,
            label: t('Word (.docx) indir'),
            onTap: () => _save(context, _Format.docx),
          ),
          _Option(
            icon: Icons.ios_share_outlined,
            label: t('PDF paylaş'),
            hint: t('WhatsApp, e-posta…'),
            onTap: () => _share(context, _Format.pdf),
          ),
          _Option(
            icon: Icons.ios_share_outlined,
            label: t('Word paylaş'),
            hint: t('WhatsApp, e-posta…'),
            onTap: () => _share(context, _Format.docx),
          ),
        ],
      ),
    );
  }

  Future<({String name, String mime, Uint8List bytes})> _build(_Format f) async {
    switch (f) {
      case _Format.pdf:
        return (
          name: '$_baseName.pdf',
          mime: OfficialExport.pdfMime,
          bytes: await PdfExportService.buildOfficialNotebookPdfBytes(internship: internship, entries: entries, photos: photos),
        );
      case _Format.docx:
        return (
          name: '$_baseName.docx',
          mime: OfficialExport.docxMime,
          bytes: OfficialExport.buildDocx(internship: internship, entries: entries),
        );
    }
  }

  void _save(BuildContext context, _Format f) {
    final messenger = ScaffoldMessenger.of(context);
    _run(context, () async {
      final file = await _build(f);
      final saved = await OfficialExport.saveFile(fileName: file.name, bytes: file.bytes, mimeType: file.mime);
      if (saved) messenger.showSnackBar(SnackBar(content: Text(t('{name} kaydedildi', {'name': file.name}))));
    });
  }

  void _share(BuildContext context, _Format f) {
    _run(context, () async {
      final file = await _build(f);
      await OfficialExport.shareFile(
        fileName: file.name,
        bytes: file.bytes,
        mimeType: file.mime,
        subject: t('Staj Defteri — {date}', {'date': internship.name}),
      );
    });
  }

  /// Closes the sheet, runs [action], and turns any failure into a snackbar
  /// rather than an unhandled error.
  Future<void> _run(BuildContext context, Future<void> Function() action) async {
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop();
    try {
      await action();
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(t('İşlem tamamlanamadı, tekrar dene.'))));
    }
  }
}

class _Header extends StatelessWidget {
  final String text;
  const _Header(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: AppSpacing.lg, bottom: AppSpacing.xs),
        child: Text(text.toUpperTr(), style: AppTextStyles.body(fontSize: 11, weight: FontWeight.w600, color: AppColors.textMuted)),
      );
}

class _Option extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? hint;
  final VoidCallback onTap;

  const _Option({required this.icon, required this.label, required this.onTap, this.hint});

  @override
  Widget build(BuildContext context) => ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: AppColors.inkLight, borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: AppColors.ink, size: 20),
        ),
        title: Text(label, style: AppTextStyles.body(fontSize: 15)),
        subtitle: hint != null ? Text(hint!, style: AppTextStyles.body(fontSize: 12, color: AppColors.textMuted)) : null,
        onTap: onTap,
      );
}
