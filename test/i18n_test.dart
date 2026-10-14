import 'dart:io';

import 'package:cepte_staj/core/achievements.dart';
import 'package:cepte_staj/core/i18n.dart';
import 'package:cepte_staj/core/i18n_en.dart';
import 'package:cepte_staj/core/snippets.dart';
import 'package:cepte_staj/core/tr_text.dart';
import 'package:cepte_staj/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

/// Every `t('…')` literal in lib/, with Dart escapes resolved.
Set<String> _keysUsedInLib() {
  final call = RegExp(r"""\bt\(\s*(['"])((?:\\.|(?!\1).)*?)\1""");
  final keys = <String>{};
  for (final f in Directory('lib').listSync(recursive: true).whereType<File>()) {
    // i18n*.dart only mention t() in doc comments.
    if (!f.path.endsWith('.dart') || f.uri.pathSegments.last.startsWith('i18n')) continue;
    for (final m in call.allMatches(f.readAsStringSync())) {
      keys.add(m.group(2)!.replaceAll(r"\'", "'").replaceAll(r'\"', '"').replaceAll(r'\$', r'$'));
    }
  }
  return keys;
}

void main() {
  tearDown(() => L10n.setLang('tr'));

  test('every t() string in lib/ has an English translation', () {
    final missing = _keysUsedInLib().where((k) => !enStrings.containsKey(k)).toList()..sort();
    expect(missing, isEmpty, reason: 'Add these to lib/core/i18n_en.dart');
  });

  test('stored-in-Turkish option lists all translate', () {
    final lists = [
      ...moodReasonOptions,
      for (final c in incidentCategories) c.$2,
      ...BingoTask.defaultTasks,
      for (final d in AchievementEngine.definitions) d.$2,
      ...generalSnippets,
      for (final list in fieldSnippets.values) ...list,
      for (final f in internshipFields) ...[f.label, f.topicHint],
      'boş', 'normal', 'yoğun',
    ];
    expect(lists.where((k) => !enStrings.containsKey(k)), isEmpty);
  });

  test('placeholders survive translation', () {
    for (final e in enStrings.entries) {
      final tr = RegExp(r'\{\w+\}').allMatches(e.key).map((m) => m[0]).toSet();
      final en = RegExp(r'\{\w+\}').allMatches(e.value).map((m) => m[0]).toSet();
      expect(en, tr, reason: e.key);
    }
  });

  test('t() switches language and fills placeholders', () {
    expect(t('{n} gün', {'n': 3}), '3 gün');
    L10n.setLang('en');
    expect(t('{n} gün', {'n': 3}), '3 days');
    expect(t('bilinmeyen metin'), 'bilinmeyen metin');
  });

  test('saved default texts follow the language, user text stays as written', () {
    L10n.setLang('en');
    expect(tStored('Kahve molası'), 'Coffee break');
    expect(tStored('Benim sayacım'), 'Benim sayacım');
    L10n.setLang('tr');
    // Saved while the app was in English.
    expect(tStored('Coffee break'), 'Kahve molası');
    expect(tStored('Kahve molası'), 'Kahve molası');
  });

  test('dates and casing follow the language', () {
    final d = DateTime(2026, 10, 14);
    expect(shortDateFor(d), '14 Ekim');
    expect('gizlilik'.toUpperTr(), 'GİZLİLİK');
    L10n.setLang('en');
    expect(shortDateFor(d), 'October 14');
    expect(weekdayNameFor(d), 'Wednesday');
    expect('privacy'.toUpperTr(), 'PRIVACY');
  });
}
