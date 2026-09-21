import 'holidays.dart';

/// Pure, side-effect-free workday arithmetic — the one place that decides
/// whether a given calendar date counts toward the internship or not.
///
/// A mistake here silently breaks every counter in the app (progress ring,
/// streak, calendar heatmap, estimated end date), so keep this class free
/// of app/UI state and covered by unit tests (see test/workday_calculator_test.dart).
class WorkdayCalculator {
  WorkdayCalculator._();

  static DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  /// [workDaysMask] has 7 entries, index 0 = Monday ... index 6 = Sunday,
  /// matching `DateTime.weekday - 1`.
  static bool isWorkday(
    DateTime date, {
    required List<bool> workDaysMask,
    required bool excludeHolidays,
  }) {
    if (!workDaysMask[date.weekday - 1]) return false;
    if (excludeHolidays && TrHolidays.isHoliday(date)) return false;
    return true;
  }

  /// Counts workdays in the inclusive range [start, end].
  static int countWorkdaysBetween(
    DateTime start,
    DateTime end, {
    required List<bool> workDaysMask,
    required bool excludeHolidays,
  }) {
    start = dateOnly(start);
    end = dateOnly(end);
    if (end.isBefore(start)) return 0;
    var count = 0;
    var d = start;
    while (!d.isAfter(end)) {
      if (isWorkday(d, workDaysMask: workDaysMask, excludeHolidays: excludeHolidays)) {
        count++;
      }
      d = d.add(const Duration(days: 1));
    }
    return count;
  }

  /// Walks forward from [start] until [totalWorkdays] workdays have been
  /// counted (the start date itself counts as day 1 if it's a workday),
  /// returning the date of the last (Nth) workday.
  static DateTime computeEndDate({
    required DateTime start,
    required int totalWorkdays,
    required List<bool> workDaysMask,
    required bool excludeHolidays,
  }) {
    assert(totalWorkdays > 0);
    var d = dateOnly(start);
    var remaining = totalWorkdays;
    // Failsafe bound so a bad mask (all-false) can't loop forever.
    var guard = 0;
    while (guard < 3660) {
      if (isWorkday(d, workDaysMask: workDaysMask, excludeHolidays: excludeHolidays)) {
        remaining--;
        if (remaining == 0) return d;
      }
      d = d.add(const Duration(days: 1));
      guard++;
    }
    return d;
  }

  /// Workdays that have elapsed from [start] through [asOf] inclusive —
  /// i.e. how many "should be filled by now" workdays exist.
  static int elapsedWorkdays({
    required DateTime start,
    required DateTime asOf,
    required List<bool> workDaysMask,
    required bool excludeHolidays,
  }) {
    final s = dateOnly(start);
    final a = dateOnly(asOf);
    if (a.isBefore(s)) return 0;
    return countWorkdaysBetween(s, a, workDaysMask: workDaysMask, excludeHolidays: excludeHolidays);
  }

  /// The nth work day index (1-based) for [date] within the internship, or
  /// null if [date] isn't a workday or is outside [start, end].
  static int? workdayIndexOf(
    DateTime date, {
    required DateTime start,
    required DateTime end,
    required List<bool> workDaysMask,
    required bool excludeHolidays,
  }) {
    final d = dateOnly(date);
    final s = dateOnly(start);
    final e = dateOnly(end);
    if (d.isBefore(s) || d.isAfter(e)) return null;
    if (!isWorkday(d, workDaysMask: workDaysMask, excludeHolidays: excludeHolidays)) return null;
    return countWorkdaysBetween(s, d, workDaysMask: workDaysMask, excludeHolidays: excludeHolidays);
  }

  /// The next workday on/after [from] (inclusive), bounded by [end].
  static DateTime? nextWorkdayOnOrAfter(
    DateTime from, {
    required DateTime end,
    required List<bool> workDaysMask,
    required bool excludeHolidays,
  }) {
    var d = dateOnly(from);
    final e = dateOnly(end);
    while (!d.isAfter(e)) {
      if (isWorkday(d, workDaysMask: workDaysMask, excludeHolidays: excludeHolidays)) return d;
      d = d.add(const Duration(days: 1));
    }
    return null;
  }

  /// Default Mon-Fri mask.
  static List<bool> get defaultMask => [true, true, true, true, true, false, false];

  /// Mon-Sat mask.
  static List<bool> get sixDayMask => [true, true, true, true, true, true, false];
}
