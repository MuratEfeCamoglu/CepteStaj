import '../models/models.dart';

/// Pure badge-evaluation engine — no side effects, safe to call after every
/// write and in tests. Given the current data, it returns the full badge
/// list with up-to-date `earned` flags; [AppState] is responsible for
/// persisting `earnedAt` the first time a badge flips to earned.
class AchievementEngine {
  AchievementEngine._();

  static const definitions = <(String key, String label, String emoji)>[
    ('first_day', 'İlk Gün', '🌱'),
    ('streak_7', '7 Gün Seri', '🔥'),
    ('halfway', 'Yarı Yol', '🚩'),
    ('words_1000', '1000 Kelime', '✍️'),
    ('first_photo', 'İlk Fotoğraf', '📷'),
    ('bingo_line', 'Bingo Satırı', '🎯'),
    ('no_missed_days', 'Hiç Gün Kaçırmadın', '🏆'),
    ('night_owl', 'Gece Yazarı', '🦉'),
    ('early_bird', 'Erken Kuş', '🐦'),
  ];

  static List<AppBadge> evaluate({
    required List<DayEntry> entries,
    required int currentStreak,
    required int filledWorkdays,
    required int totalWorkdays,
    required bool hasAnyPhoto,
    required bool hasBingoLine,
    required int missedWorkdaysSoFar,
    Map<String, DateTime>? earnedAtByKey,
  }) {
    final totalWords = entries.fold<int>(0, (sum, e) => sum + e.wordCount);
    final hasNightEntry = entries.any((e) => e.body.isNotEmpty && e.updatedAt.hour >= 23);
    final hasEarlyEntry = entries.any((e) => e.body.isNotEmpty && e.updatedAt.hour < 7);

    final earned = <String, bool>{
      'first_day': entries.any((e) => e.hasOfficialContent),
      'streak_7': currentStreak >= 7,
      'halfway': totalWorkdays > 0 && filledWorkdays >= (totalWorkdays / 2).ceil(),
      'words_1000': totalWords >= 1000,
      'first_photo': hasAnyPhoto,
      'bingo_line': hasBingoLine,
      'no_missed_days': filledWorkdays > 0 && missedWorkdaysSoFar == 0,
      'night_owl': hasNightEntry,
      'early_bird': hasEarlyEntry,
    };

    return [
      for (final (key, label, emoji) in definitions)
        AppBadge(
          key: key,
          label: label,
          emoji: emoji,
          earned: earned[key] ?? false,
          earnedAt: earnedAtByKey?[key],
        ),
    ];
  }

  /// True if any full row, column or diagonal of a square bingo grid
  /// (side = sqrt(cells.length)) is fully done.
  static bool hasCompletedLine(List<bool> cells) {
    final side = _sqrt(cells.length);
    if (side * side != cells.length || side == 0) return false;
    for (var r = 0; r < side; r++) {
      if (List.generate(side, (c) => cells[r * side + c]).every((v) => v)) return true;
    }
    for (var c = 0; c < side; c++) {
      if (List.generate(side, (r) => cells[r * side + c]).every((v) => v)) return true;
    }
    if (List.generate(side, (i) => cells[i * side + i]).every((v) => v)) return true;
    if (List.generate(side, (i) => cells[i * side + (side - 1 - i)]).every((v) => v)) return true;
    return false;
  }

  static int _sqrt(int n) {
    var i = 0;
    while (i * i < n) {
      i++;
    }
    return i;
  }
}
