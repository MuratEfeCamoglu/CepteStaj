import 'package:flutter/widgets.dart' show Locale, WidgetsBinding;

import 'i18n_en.dart';

/// App language. Turkish is the source language: every UI string is written
/// in Turkish at its call site and wrapped in [t], which looks up the
/// English translation in [enStrings] when English is active. A missing
/// translation falls back to the Turkish text instead of failing.
///
/// Like [AppColors], the active language is a static flag flipped once from
/// [AppState]; the app forces a full rebuild when it changes (see main.dart),
/// so no widget needs to listen for it.
class L10n {
  L10n._();

  static const supported = ['tr', 'en'];
  static String _lang = 'tr';

  static String get lang => _lang;
  static bool get isEn => _lang == 'en';
  static void setLang(String value) => _lang = supported.contains(value) ? value : 'tr';

  static Locale get locale => isEn ? const Locale('en', 'US') : const Locale('tr', 'TR');

  /// Language for a fresh install: Turkish on a Turkish phone, English
  /// everywhere else.
  static String deviceDefault() =>
      WidgetsBinding.instance.platformDispatcher.locale.languageCode == 'tr' ? 'tr' : 'en';
}

/// Translates a Turkish UI string. `{name}` placeholders are filled from
/// [args] in either language: `t('{n} gün kaldı', {'n': 5})`.
String t(String tr, [Map<String, Object?> args = const {}]) {
  var s = L10n.isEn ? (enStrings[tr] ?? tr) : tr;
  args.forEach((k, v) => s = s.replaceAll('{$k}', '$v'));
  return s;
}

/// For text saved to disk that started life as a built-in default — quick
/// counter labels, bingo squares, the default internship name. Shows it in
/// the current language whichever language it was saved in (older saves
/// stored the translated text). Anything the user wrote themselves matches
/// no entry and comes back unchanged.
String tStored(String saved) {
  final trKey = enStrings.containsKey(saved) ? saved : _trByEn[saved];
  return trKey == null ? saved : t(trKey);
}

final Map<String, String> _trByEn = {for (final e in enStrings.entries) e.value: e.key};

// ── Dates ─────────────────────────────────────────────────────────────
const _monthsTr = ['Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran', 'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'];
const _monthsEn = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
const _monthsShortTr = ['Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz', 'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara'];
const _monthsShortEn = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
const _weekdaysTr = ['Pazartesi', 'Salı', 'Çarşamba', 'Perşembe', 'Cuma', 'Cumartesi', 'Pazar'];
const _weekdaysEn = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
const _weekdaysShortTr = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
const _weekdaysShortEn = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const _weekdayLettersTr = ['P', 'S', 'Ç', 'P', 'C', 'C', 'P'];
const _weekdayLettersEn = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

String monthName(int month) => (L10n.isEn ? _monthsEn : _monthsTr)[month - 1];
String monthShort(int month) => (L10n.isEn ? _monthsShortEn : _monthsShortTr)[month - 1];

/// Monday = index 0.
List<String> get weekdayLetters => L10n.isEn ? _weekdayLettersEn : _weekdayLettersTr;
List<String> get weekdayShortNames => L10n.isEn ? _weekdaysShortEn : _weekdaysShortTr;

String weekdayNameFor(DateTime d) => (L10n.isEn ? _weekdaysEn : _weekdaysTr)[d.weekday - 1];
String weekdayShortFor(DateTime d) => weekdayShortNames[d.weekday - 1];

/// "14 Ekim" / "October 14".
String shortDateFor(DateTime d) => L10n.isEn ? '${monthName(d.month)} ${d.day}' : '${d.day} ${monthName(d.month)}';

/// "14 Eki" / "Oct 14".
String compactDateFor(DateTime d) => L10n.isEn ? '${monthShort(d.month)} ${d.day}' : '${d.day} ${monthShort(d.month)}';

/// "14 Eki 2026" / "Oct 14, 2026".
String fullDateFor(DateTime d) =>
    L10n.isEn ? '${monthShort(d.month)} ${d.day}, ${d.year}' : '${d.day} ${monthShort(d.month)} ${d.year}';

/// "Ekim 2026" / "October 2026".
String monthYearFor(DateTime d) => '${monthName(d.month)} ${d.year}';
