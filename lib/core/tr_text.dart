/// Turkish-aware casing. Dart's [String.toUpperCase] is locale-blind, so
/// "Ekim" would become "EKIM" and "Gizlilik" "GIZLILIK" — wrong in Turkish,
/// where i ↔ İ and ı ↔ I are separate letters.
extension TurkishCase on String {
  String toUpperTr() => replaceAll('i', 'İ').replaceAll('ı', 'I').toUpperCase();
}
