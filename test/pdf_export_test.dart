import 'dart:io';

import 'package:cepte_staj/core/pdf_export.dart';
import 'package:cepte_staj/models/models.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tmp;
  setUp(() {
    tmp = Directory.systemTemp.createTempSync('cepte_pdf_test');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (call) async => tmp.path,
    );
  });
  tearDown(() => tmp.deleteSync(recursive: true));

  test('Official PDF builds with Turkish text and skips photos that were not opted in', () async {
    final entry = DayEntry(
      date: '2026-09-21',
      topic: 'Öğrenme ve şifre yönetimi',
      body: 'Ğ ş ı İ karakterleri içeren bir defter metni yazdım.',
      incident: 'GİZLİ-OLAY-METNİ',
      mood: 5,
    );
    final photo = File('${tmp.path}/p.png')..writeAsBytesSync(_tinyPng);
    final optedIn = DayPhoto(id: '1', date: entry.date, filePath: photo.path, includeInExport: true);
    final notOptedIn = DayPhoto(id: '2', date: entry.date, filePath: '${tmp.path}/missing.png');

    final file = await PdfExportService.buildOfficialNotebookPdf(
      internship: Internship(name: 'Yazılım Stajı', company: 'Şirket A.Ş.'),
      entries: [entry],
      photos: [optedIn, notOptedIn],
    );

    final bytes = await file.readAsBytes();
    expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
    expect(bytes.length, greaterThan(1000));

    final withoutPhoto = await PdfExportService.buildOfficialNotebookPdf(
      internship: Internship(name: 'Yazılım Stajı', company: 'Şirket A.Ş.'),
      entries: [entry],
      photos: [notOptedIn],
    );
    expect(bytes.length, greaterThan((await withoutPhoto.readAsBytes()).length));
  });
}

const _tinyPng = <int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52,
  0x00, 0x00, 0x00, 0x04, 0x00, 0x00, 0x00, 0x04, 0x08, 0x02, 0x00, 0x00, 0x00, 0x26, 0x93, 0x09,
  0x29, 0x00, 0x00, 0x00, 0x10, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0xF8, 0xCF, 0xC0, 0x00,
  0x47, 0x0C, 0xC4, 0x71, 0x00, 0xAE, 0x93, 0x0F, 0xF1, 0xD0, 0x5F, 0x23, 0x9E, 0x00, 0x00, 0x00,
  0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
];
