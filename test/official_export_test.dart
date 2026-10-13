import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:cepte_staj/core/official_export.dart';
import 'package:cepte_staj/models/models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xml/xml.dart';

/// A day with every personal field filled with a marker string, so a leak
/// into any official output is easy to spot (claude.md §3.14).
DayEntry _dayWithSecrets() => DayEntry(
      date: '2026-10-13',
      topic: 'REST API & <JSON> testleri',
      body: 'Postman ile uç noktaları denedim.\nĞ ş ı İ ç ö ü karakterleri.',
      learned: 'HTTP durum kodları',
      checkIn: '09:00',
      checkOut: '17:30',
      mood: 1,
      workload: 3,
      moodReasons: ['GİZLİ-SEBEP'],
      incident: 'GİZLİ-OLAY',
      incidentCategory: 'panik',
      dailyWin: 'GİZLİ-ZAFER',
      song: 'GİZLİ-ŞARKI',
      journalNote: 'GİZLİ-NOT',
    );

String _docxText(List<int> bytes) {
  final archive = ZipDecoder().decodeBytes(bytes);
  final xml = utf8.decode(archive.findFile('word/document.xml')!.readBytes()!);
  return XmlDocument.parse(xml).innerText; // parse also proves well-formedness
}

void main() {
  test('day text carries the official fields and nothing personal', () {
    final text = OfficialExport.dayText(_dayWithSecrets());

    expect(text, contains('*Staj Defteri — 13.10.2026*'));
    expect(text, contains('*Konu:* REST API & <JSON> testleri'));
    expect(text, contains('Postman ile uç noktaları denedim.'));
    expect(text, contains('*Öğrendiklerim:* HTTP durum kodları'));
    expect(text, contains('Giriş: 09:00 · Çıkış: 17:30'));
    expect(text, isNot(contains('GİZLİ')));
  });

  test('day text skips empty sections', () {
    final text = OfficialExport.dayText(DayEntry(date: '2026-10-13', body: 'Sadece metin.'));
    expect(text, '*Staj Defteri — 13.10.2026*\n\nSadece metin.');
  });

  test('docx is a valid Word package with Turkish text and no personal fields', () {
    final bytes = OfficialExport.buildDocx(
      internship: Internship(name: 'Yazılım Stajı', company: 'Şirket A.Ş.'),
      entries: [_dayWithSecrets(), DayEntry(date: '2026-10-12', mood: 5, incident: 'GİZLİ-BOŞ-GÜN')],
    );

    final archive = ZipDecoder().decodeBytes(bytes);
    for (final part in ['[Content_Types].xml', '_rels/.rels', 'word/document.xml']) {
      final file = archive.findFile(part);
      expect(file, isNotNull, reason: part);
      XmlDocument.parse(utf8.decode(file!.readBytes()!));
    }

    final text = _docxText(bytes);
    expect(text, contains('Yazılım Stajı'));
    expect(text, contains('Şirket A.Ş.'));
    expect(text, contains('13.10.2026'));
    expect(text, contains('REST API & <JSON> testleri')); // escaped, not broken
    expect(text, contains('Ğ ş ı İ ç ö ü karakterleri.'));
    expect(text, contains('Öğrendiklerim: HTTP durum kodları'));
    expect(text, isNot(contains('GİZLİ')));
    // A day with only personal content isn't a notebook page.
    expect(text, isNot(contains('12.10.2026')));
  });

  test('docx strips control characters that would corrupt the XML', () {
    final bytes = OfficialExport.buildDocx(
      internship: Internship(name: 'Staj'),
      entries: [DayEntry(date: '2026-10-13', body: 'önce\u0007sonra')],
    );
    expect(_docxText(bytes), contains('öncesonra'));
  });
}
