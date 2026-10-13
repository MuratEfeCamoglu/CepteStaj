import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/models.dart';

/// Plain-text and Word (.docx) versions of the Resmi Defter, plus the
/// "download" / "share" / "send to WhatsApp" plumbing shared with the PDF.
///
/// Architecture rule (see claude.md §3.14), same as [PdfExportService]:
/// everything here reads only the official fields of a [DayEntry] — topic,
/// body, learned, checkIn/checkOut. Never mood, workload, incident,
/// dailyWin, journalNote or song.
class OfficialExport {
  OfficialExport._();

  static const pdfMime = 'application/pdf';
  static const docxMime = 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';

  // ── Text (WhatsApp etc.) ────────────────────────────────────────────

  /// One day as a message. `*bold*` renders as bold in WhatsApp and stays
  /// readable as plain text everywhere else.
  static String dayText(DayEntry e) {
    final out = StringBuffer('*Staj Defteri — ${formatDate(e.date)}*');
    if (e.topic.trim().isNotEmpty) out.write('\n*Konu:* ${e.topic.trim()}');
    if (e.body.trim().isNotEmpty) out.write('\n\n${e.body.trim()}');
    if (e.learned.trim().isNotEmpty) out.write('\n\n*Öğrendiklerim:* ${e.learned.trim()}');
    final hours = _hours(e);
    if (hours != null) out.write('\n\n$hours');
    return out.toString();
  }

  /// Opens WhatsApp with [text] ready to send. Falls back to the system
  /// share sheet when WhatsApp isn't installed.
  static Future<void> sendToWhatsApp(String text) async {
    final uri = Uri.parse('whatsapp://send?text=${Uri.encodeComponent(text)}');
    var opened = false;
    try {
      opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}
    if (!opened) await shareText(text);
  }

  static Future<void> shareText(String text, {String? subject}) =>
      SharePlus.instance.share(ShareParams(text: text, subject: subject));

  // ── Word (.docx) ────────────────────────────────────────────────────

  /// A minimal but valid Office Open XML document: one paragraph per line,
  /// days separated by spacing. Opens in Word, Google Docs and LibreOffice.
  static Uint8List buildDocx({required Internship internship, required List<DayEntry> entries}) {
    final sorted = [...entries.where((e) => e.hasOfficialContent)]..sort((a, b) => a.date.compareTo(b.date));
    final body = StringBuffer()
      ..write(_p(internship.name, bold: true, size: 32))
      ..write(internship.company.isNotEmpty ? _p(internship.company, size: 24, after: 240) : _p('', after: 120));
    for (final e in sorted) {
      body.write(_p(formatDate(e.date), bold: true, size: 26, before: 240));
      if (e.topic.trim().isNotEmpty) body.write(_p(e.topic.trim(), italic: true, size: 24));
      for (final line in const LineSplitter().convert(e.body.trim())) {
        body.write(_p(line, size: 22));
      }
      if (e.learned.trim().isNotEmpty) body.write(_p('Öğrendiklerim: ${e.learned.trim()}', size: 22, before: 80));
      final hours = _hours(e);
      if (hours != null) body.write(_p(hours, size: 18, color: '666666'));
    }
    if (sorted.isEmpty) body.write(_p('Henüz doldurulmuş bir defter kaydı yok.', size: 22));

    final document = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
        '<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">'
        '<w:body>$body'
        '<w:sectPr><w:pgSz w:w="11906" w:h="16838"/>'
        '<w:pgMar w:top="1134" w:right="1134" w:bottom="1134" w:left="1134" w:header="709" w:footer="709" w:gutter="0"/>'
        '</w:sectPr></w:body></w:document>';

    final archive = Archive()
      ..addFile(ArchiveFile.string(
        '[Content_Types].xml',
        '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
            '<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">'
            '<Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>'
            '<Default Extension="xml" ContentType="application/xml"/>'
            '<Override PartName="/word/document.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/>'
            '</Types>',
      ))
      ..addFile(ArchiveFile.string(
        '_rels/.rels',
        '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
            '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">'
            '<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="word/document.xml"/>'
            '</Relationships>',
      ))
      ..addFile(ArchiveFile.string('word/document.xml', document));
    return Uint8List.fromList(ZipEncoder().encode(archive));
  }

  /// One `<w:p>` paragraph. [size] is in half-points (22 = 11pt);
  /// [before]/[after] spacing in twentieths of a point.
  static String _p(
    String text, {
    bool bold = false,
    bool italic = false,
    int size = 22,
    int before = 0,
    int after = 60,
    String? color,
  }) {
    final rPr = StringBuffer('<w:rPr><w:rFonts w:ascii="Calibri" w:hAnsi="Calibri" w:cs="Calibri"/>');
    if (bold) rPr.write('<w:b/>');
    if (italic) rPr.write('<w:i/>');
    if (color != null) rPr.write('<w:color w:val="$color"/>');
    rPr.write('<w:sz w:val="$size"/></w:rPr>');
    return '<w:p><w:pPr><w:spacing w:before="$before" w:after="$after"/></w:pPr>'
        '<w:r>$rPr<w:t xml:space="preserve">${_xml(text)}</w:t></w:r></w:p>';
  }

  static String _xml(String s) => s
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;')
      // Control characters (other than tab) are illegal in XML 1.0 and
      // would make Word refuse to open the file.
      .replaceAll(RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F]'), '');

  // ── Download / share a file ─────────────────────────────────────────

  /// Opens the system "save as" screen so the user picks where the file
  /// goes (Downloads, Drive, …). No storage permission needed.
  /// Returns false if they cancelled.
  static Future<bool> saveFile({required String fileName, required Uint8List bytes, required String mimeType}) async {
    final uri = await FilePicker.saveFile(fileName: fileName, bytes: bytes, mimeType: mimeType);
    return uri != null;
  }

  /// Shares the file through the system share sheet (WhatsApp, Gmail, …).
  static Future<void> shareFile({
    required String fileName,
    required Uint8List bytes,
    required String mimeType,
    String? subject,
  }) async {
    // Temp dir: the share sheet only needs it briefly, and a copy left in
    // documents would survive "Tüm verileri sıfırla".
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(bytes, flush: true);
    await SharePlus.instance.share(
      ShareParams(files: [XFile(file.path, mimeType: mimeType)], subject: subject),
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────────

  /// `2026-10-13` → `13.10.2026`
  static String formatDate(String isoDate) {
    final parts = isoDate.split('-');
    return '${parts[2]}.${parts[1]}.${parts[0]}';
  }

  static String? _hours(DayEntry e) {
    final inT = e.checkIn.trim();
    final outT = e.checkOut.trim();
    if (inT.isEmpty && outT.isEmpty) return null;
    return [if (inT.isNotEmpty) 'Giriş: $inT', if (outT.isNotEmpty) 'Çıkış: $outT'].join(' · ');
  }
}
