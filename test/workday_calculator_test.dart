// Unit tests for the one function whose mistakes silently break every
// counter in the app — see lib/core/workday_calculator.dart.

import 'package:cepte_staj/core/workday_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final monFri = WorkdayCalculator.defaultMask; // Mon-Fri
  final monSat = WorkdayCalculator.sixDayMask; // Mon-Sat

  group('isWorkday', () {
    test('Monday is a workday on a Mon-Fri mask', () {
      final monday = DateTime(2026, 8, 17); // a Monday
      expect(WorkdayCalculator.isWorkday(monday, workDaysMask: monFri, excludeHolidays: false), isTrue);
    });

    test('Saturday is not a workday on a Mon-Fri mask', () {
      final saturday = DateTime(2026, 8, 22);
      expect(WorkdayCalculator.isWorkday(saturday, workDaysMask: monFri, excludeHolidays: false), isFalse);
    });

    test('Saturday is a workday on a Mon-Sat mask', () {
      final saturday = DateTime(2026, 8, 22);
      expect(WorkdayCalculator.isWorkday(saturday, workDaysMask: monSat, excludeHolidays: false), isTrue);
    });

    test('a national holiday is excluded when excludeHolidays is true', () {
      final zaferBayrami = DateTime(2026, 8, 30); // a Sunday in 2026, but check a weekday holiday
      final cumhuriyet = DateTime(2026, 10, 29); // Thursday in 2026
      expect(WorkdayCalculator.isWorkday(cumhuriyet, workDaysMask: monFri, excludeHolidays: true), isFalse);
      expect(WorkdayCalculator.isWorkday(cumhuriyet, workDaysMask: monFri, excludeHolidays: false), isTrue);
      // Sanity: the date really is Zafer Bayramı weekday-independent check.
      expect(zaferBayrami.month, 8);
    });
  });

  group('countWorkdaysBetween', () {
    test('counts a single Mon-Fri work week as 5', () {
      final monday = DateTime(2026, 8, 17);
      final sunday = DateTime(2026, 8, 23);
      expect(
        WorkdayCalculator.countWorkdaysBetween(monday, sunday, workDaysMask: monFri, excludeHolidays: false),
        5,
      );
    });

    test('start after end returns 0', () {
      final a = DateTime(2026, 8, 20);
      final b = DateTime(2026, 8, 10);
      expect(WorkdayCalculator.countWorkdaysBetween(a, b, workDaysMask: monFri, excludeHolidays: false), 0);
    });
  });

  group('computeEndDate', () {
    test('20 Mon-Fri workdays starting Monday end 4 weeks later on a Friday', () {
      final start = DateTime(2026, 8, 17); // Monday
      final end = WorkdayCalculator.computeEndDate(
        start: start,
        totalWorkdays: 20,
        workDaysMask: monFri,
        excludeHolidays: false,
      );
      expect(end.weekday, DateTime.friday);
      expect(
        WorkdayCalculator.countWorkdaysBetween(start, end, workDaysMask: monFri, excludeHolidays: false),
        20,
      );
    });

    test('a single-day internship ends on the start date itself', () {
      final start = DateTime(2026, 8, 17);
      final end = WorkdayCalculator.computeEndDate(
        start: start,
        totalWorkdays: 1,
        workDaysMask: monFri,
        excludeHolidays: false,
      );
      expect(end, WorkdayCalculator.dateOnly(start));
    });
  });

  group('workdayIndexOf', () {
    test('first workday has index 1, second has index 2', () {
      final start = DateTime(2026, 8, 17); // Monday
      final end = WorkdayCalculator.computeEndDate(
        start: start, totalWorkdays: 20, workDaysMask: monFri, excludeHolidays: false);
      expect(
        WorkdayCalculator.workdayIndexOf(start, start: start, end: end, workDaysMask: monFri, excludeHolidays: false),
        1,
      );
      final tuesday = start.add(const Duration(days: 1));
      expect(
        WorkdayCalculator.workdayIndexOf(tuesday, start: start, end: end, workDaysMask: monFri, excludeHolidays: false),
        2,
      );
    });

    test('a weekend date has no workday index', () {
      final start = DateTime(2026, 8, 17);
      final saturday = DateTime(2026, 8, 22);
      final end = WorkdayCalculator.computeEndDate(
        start: start, totalWorkdays: 20, workDaysMask: monFri, excludeHolidays: false);
      expect(
        WorkdayCalculator.workdayIndexOf(saturday, start: start, end: end, workDaysMask: monFri, excludeHolidays: false),
        isNull,
      );
    });
  });

  group('elapsedWorkdays', () {
    test('is 0 before the internship starts', () {
      final start = DateTime(2026, 8, 17);
      final before = DateTime(2026, 8, 10);
      expect(
        WorkdayCalculator.elapsedWorkdays(start: start, asOf: before, workDaysMask: monFri, excludeHolidays: false),
        0,
      );
    });

    test('counts through today inclusive', () {
      final start = DateTime(2026, 8, 17); // Monday
      final wednesday = DateTime(2026, 8, 19);
      expect(
        WorkdayCalculator.elapsedWorkdays(start: start, asOf: wednesday, workDaysMask: monFri, excludeHolidays: false),
        3,
      );
    });
  });
}
