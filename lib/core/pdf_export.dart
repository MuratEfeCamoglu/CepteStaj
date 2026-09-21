import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../models/models.dart';

/// Generates and shares the "Resmi Defter PDF".
///
/// Architecture rule (see claude.md §3.14): this function may only read the
/// official fields of a [DayEntry] — topic, body, learned, checkIn/checkOut
/// — plus photos explicitly opted into export. It must never touch mood,
/// workload, incident, dailyWin, journalNote or song. If you're adding a
/// field here, ask "would a supervisor see this?" first.
class PdfExportService {
  PdfExportService._();

  static Future<pw.ThemeData> _loadTheme() async {
    // The built-in PDF fonts lack ğ ş ı İ Ş Ğ, so bundle a Unicode font.
    final regular = pw.Font.ttf(await rootBundle.load('assets/fonts/roboto-regular.ttf'));
    final bold = pw.Font.ttf(await rootBundle.load('assets/fonts/roboto-bold.ttf'));
    final italic = pw.Font.ttf(await rootBundle.load('assets/fonts/roboto-italic.ttf'));
    return pw.ThemeData.withFont(base: regular, bold: bold, italic: italic, boldItalic: bold);
  }

  static Future<File> buildOfficialNotebookPdf({
    required Internship internship,
    required List<DayEntry> entries,
    List<DayPhoto> photos = const [],
  }) async {
    final doc = pw.Document(theme: await _loadTheme());
    final sorted = [...entries]..sort((a, b) => a.date.compareTo(b.date));
    final withContent = sorted.where((e) => e.hasOfficialContent).toList();

    // Only photos the user explicitly opted in ever reach this function's output.
    final exportPhotos = <String, List<({pw.MemoryImage image, String caption})>>{};
    for (final p in photos.where((p) => p.includeInExport)) {
      try {
        final file = File(p.filePath);
        if (!await file.exists()) continue;
        exportPhotos
            .putIfAbsent(p.date, () => [])
            .add((image: pw.MemoryImage(await file.readAsBytes()), caption: p.caption));
      } catch (e) {
        debugPrint('PDF photo skipped: $e');
      }
    }

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        header: (ctx) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(internship.name, style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
            if (internship.company.isNotEmpty)
              pw.Text(internship.company, style: const pw.TextStyle(fontSize: 12)),
            pw.Divider(),
          ],
        ),
        build: (ctx) => [
          for (final e in withContent) ...[
            pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 14),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(_formatDate(e.date), style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
                  if (e.topic.isNotEmpty)
                    pw.Text(e.topic, style: pw.TextStyle(fontSize: 12, fontStyle: pw.FontStyle.italic)),
                  pw.SizedBox(height: 4),
                  if (e.body.isNotEmpty) pw.Text(e.body, style: const pw.TextStyle(fontSize: 11)),
                  if (e.learned.isNotEmpty) ...[
                    pw.SizedBox(height: 4),
                    pw.Text('Öğrendiklerim: ${e.learned}', style: const pw.TextStyle(fontSize: 11)),
                  ],
                  if (e.checkIn.isNotEmpty || e.checkOut.isNotEmpty)
                    pw.Text(
                      'Giriş: ${e.checkIn}   Çıkış: ${e.checkOut}',
                      style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
                    ),
                  for (final ph in exportPhotos[e.date] ?? const <({pw.MemoryImage image, String caption})>[]) ...[
                    pw.SizedBox(height: 6),
                    pw.Container(
                      constraints: const pw.BoxConstraints(maxHeight: 200, maxWidth: 300),
                      child: pw.Image(ph.image, fit: pw.BoxFit.contain),
                    ),
                    if (ph.caption.isNotEmpty)
                      pw.Text(ph.caption, style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                  ],
                ],
              ),
            ),
          ],
          if (withContent.isEmpty)
            pw.Text('Henüz doldurulmuş bir defter kaydı yok.', style: const pw.TextStyle(fontSize: 12)),
        ],
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/resmi_defter_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await doc.save());
    return file;
  }

  static Future<void> shareOfficialNotebookPdf({
    required Internship internship,
    required List<DayEntry> entries,
    List<DayPhoto> photos = const [],
  }) async {
    try {
      final file = await buildOfficialNotebookPdf(internship: internship, entries: entries, photos: photos);
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          subject: 'Resmi Defter — ${internship.name}',
          text: 'Cepte Staj — Resmi Defter PDF',
        ),
      );
    } catch (e) {
      debugPrint('PDF export/share failed: $e');
      rethrow;
    }
  }

  static String _formatDate(String isoDate) {
    final parts = isoDate.split('-');
    return '${parts[2]}.${parts[1]}.${parts[0]}';
  }
}
