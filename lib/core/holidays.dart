/// Turkish official holiday table used by [WorkdayCalculator] to exclude
/// non-working days from the internship day count.
///
/// Fixed-date national holidays repeat every year. Religious holidays
/// (Ramazan/Kurban Bayramı) follow the lunar calendar and are looked up
/// from a per-year table below — extend [_religiousHolidays] as new years
/// are needed. Dates are Diyanet-published/estimated; a user can always
/// mark an extra day as "izinli/rapor" from the calendar regardless of
/// this table.
library;

class Holiday {
  final DateTime date;
  final String name;
  const Holiday(this.date, this.name);
}

class TrHolidays {
  TrHolidays._();

  /// Month/day pairs that are holidays every year.
  static const List<(int month, int day, String name)> _fixed = [
    (1, 1, 'Yılbaşı'),
    (4, 23, 'Ulusal Egemenlik ve Çocuk Bayramı'),
    (5, 1, 'Emek ve Dayanışma Günü'),
    (5, 19, 'Atatürk\'ü Anma, Gençlik ve Spor Bayramı'),
    (7, 15, 'Demokrasi ve Millî Birlik Günü'),
    (8, 30, 'Zafer Bayramı'),
    (10, 29, 'Cumhuriyet Bayramı'),
  ];

  /// Religious holidays by year — (month, day, spanInDays, name). Spans
  /// include the arefe (eve) half-day as a full day off for simplicity.
  static final Map<int, List<(int month, int day, int span, String name)>>
      _religiousHolidays = {
    2025: [
      (3, 29, 4, 'Ramazan Bayramı'),
      (6, 5, 5, 'Kurban Bayramı'),
    ],
    2026: [
      (3, 19, 4, 'Ramazan Bayramı'),
      (5, 26, 5, 'Kurban Bayramı'),
    ],
    2027: [
      (3, 8, 4, 'Ramazan Bayramı'),
      (5, 15, 5, 'Kurban Bayramı'),
    ],
    2028: [
      (2, 25, 4, 'Ramazan Bayramı'),
      (5, 3, 5, 'Kurban Bayramı'),
    ],
  };

  static Map<DateTime, String>? _cache;

  static Map<DateTime, String> _table() {
    if (_cache != null) return _cache!;
    final map = <DateTime, String>{};
    for (final year in [
      ..._religiousHolidays.keys,
    ]) {
      for (final (m, d, span, name) in _religiousHolidays[year]!) {
        var day = DateTime(year, m, d);
        for (var i = 0; i < span; i++) {
          map[_key(day)] = name;
          day = day.add(const Duration(days: 1));
        }
      }
    }
    _cache = map;
    return map;
  }

  static DateTime _key(DateTime d) => DateTime(d.year, d.month, d.day);

  /// Returns the holiday name for [date], or null if it's not a holiday.
  static String? nameFor(DateTime date) {
    for (final (m, d, name) in _fixed) {
      if (date.month == m && date.day == d) return name;
    }
    return _table()[_key(date)];
  }

  static bool isHoliday(DateTime date) => nameFor(date) != null;
}
