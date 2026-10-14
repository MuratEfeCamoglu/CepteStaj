import 'i18n.dart';

/// Turkish-aware casing. Dart's [String.toUpperCase] is locale-blind, so
/// "Ekim" would become "EKIM" and "Gizlilik" "GIZLILIK" — wrong in Turkish,
/// where i ↔ İ and ı ↔ I are separate letters. In English the plain
/// uppercase is the right one.
extension TurkishCase on String {
  String toUpperTr() =>
      L10n.isEn ? toUpperCase() : replaceAll('i', 'İ').replaceAll('ı', 'I').toUpperCase();
}
