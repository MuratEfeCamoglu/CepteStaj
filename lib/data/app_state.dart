import 'dart:async';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../core/achievements.dart';
import '../core/holidays.dart';
import '../core/id_gen.dart';
import '../core/local_store.dart';
import '../core/notification_service.dart';
import '../core/photo_service.dart';
import '../core/pin.dart';
import '../core/workday_calculator.dart';
import '../models/models.dart';
import '../theme/app_colors.dart';

/// The app's single source of truth. Owns every piece of data (internship
/// config, day entries, photos, counters, journal extras, settings),
/// derives all the calendar/streak/progress numbers from real dates via
/// [WorkdayCalculator], and persists itself to disk after every mutation.
class AppState extends ChangeNotifier {
  AppState() {
    _load();
  }

  bool loading = true;
  Internship? internship;
  bool get hasInternship => internship != null;

  final Map<String, DayEntry> _entries = {};
  final List<DayPhoto> photos = [];
  final List<QuickCounter> quickCounters = [];
  final List<MentorQuote> mentorQuotes = [];
  final List<BingoTask> bingoTasks = [];
  final Map<String, DateTime> _badgeEarnedAt = {};

  bool isDarkTheme = false;
  double textScale = 1.0; // 0.9 / 1.0 / 1.15
  String? _pinHash;
  bool personalUnlockedThisSession = true;

  /// Set right after a badge flips to earned, so a screen can show a toast;
  /// cleared once read via [consumeJustEarnedBadge].
  AppBadge? justEarnedBadge;

  Timer? _saveDebounce;

  // ── Persistence ────────────────────────────────────────────────────
  Future<void> _load() async {
    final json = await LocalStore.load();
    if (json != null) {
      _applyBackupJson(json, notify: false);
    }
    AppColors.setDark(isDarkTheme);
    loading = false;
    notifyListeners();
  }

  void _scheduleSave() {
    _saveDebounce?.cancel();
    _saveDebounce = Timer(const Duration(milliseconds: 700), saveNow);
  }

  Future<void> saveNow() async {
    _saveDebounce?.cancel();
    await LocalStore.save(toBackupJson());
  }

  void _afterMutation({bool immediate = false}) {
    _refreshBadges();
    notifyListeners();
    if (immediate) {
      saveNow();
    } else {
      _scheduleSave();
    }
  }

  // ── Onboarding / internship setup ─────────────────────────────────
  void setupInternship(Internship value) {
    internship = value;
    if (bingoTasks.isEmpty) {
      for (final t in BingoTask.defaultTasks) {
        bingoTasks.add(BingoTask(id: IdGen.next(), text: t));
      }
    }
    if (quickCounters.isEmpty) {
      quickCounters.addAll([
        QuickCounter(id: IdGen.next(), emoji: '☕', label: 'Kahve molası'),
        QuickCounter(id: IdGen.next(), emoji: '🐛', label: 'Bug çözüldü'),
        QuickCounter(id: IdGen.next(), emoji: '🙋', label: 'Soru soruldu'),
      ]);
    }
    _applyReminder();
    _afterMutation(immediate: true);
  }

  void updateInternship(void Function(Internship i) mutate) {
    if (internship == null) return;
    mutate(internship!);
    _applyReminder();
    _afterMutation(immediate: true);
  }

  void _applyReminder() {
    final i = internship;
    if (i == null) return;
    if (i.reminderEnabled) {
      NotificationService.scheduleDailyReminder(hour: i.reminderHour, minute: i.reminderMinute);
    } else {
      NotificationService.cancelDailyReminder();
    }
  }

  // ── Dates / calendar math ──────────────────────────────────────────
  // Every getter below is null-safe even though the screens that use them
  // are normally only reachable once an internship exists (splash routes
  // elsewhere otherwise) — this is deliberate defense-in-depth: AppShell's
  // tabs live in an IndexedStack and stay mounted (and subscribed to this
  // ChangeNotifier) even while off-screen, so e.g. resetAllData() clearing
  // `internship` while Settings is the visible tab must not crash the
  // still-mounted Home/Calendar tabs underneath.
  DateTime get today => WorkdayCalculator.dateOnly(DateTime.now());

  DateTime get endDate {
    final i = internship;
    if (i == null) return today;
    return WorkdayCalculator.computeEndDate(
      start: i.startDate,
      totalWorkdays: i.totalWorkdays,
      workDaysMask: i.workDaysMask,
      excludeHolidays: i.excludeHolidays,
    );
  }

  bool isWorkday(DateTime date) {
    final i = internship;
    if (i == null) return false;
    return WorkdayCalculator.isWorkday(date, workDaysMask: i.workDaysMask, excludeHolidays: i.excludeHolidays);
  }

  int? workdayIndexFor(DateTime date) {
    final i = internship;
    if (i == null) return null;
    return WorkdayCalculator.workdayIndexOf(
      date,
      start: i.startDate,
      end: endDate,
      workDaysMask: i.workDaysMask,
      excludeHolidays: i.excludeHolidays,
    );
  }

  List<DayEntry> get allEntries => _entries.values.toList();

  int get filledWorkdays => _entries.values.where((e) {
        final d = parseDateKey(e.date);
        return e.hasOfficialContent && isWorkday(d);
      }).length;

  int get totalWorkdays => internship?.totalWorkdays ?? 0;
  double get progress => totalWorkdays == 0 ? 0 : (filledWorkdays / totalWorkdays).clamp(0, 1);
  int get remainingDays => (totalWorkdays - filledWorkdays).clamp(0, totalWorkdays);

  int get elapsedWorkdaysSoFar {
    final i = internship;
    if (i == null) return 0;
    return WorkdayCalculator.elapsedWorkdays(
      start: i.startDate,
      asOf: today,
      workDaysMask: i.workDaysMask,
      excludeHolidays: i.excludeHolidays,
    );
  }

  int get emptyDaysBehind {
    final filledSoFar = _entries.values.where((e) {
      final d = parseDateKey(e.date);
      return e.hasOfficialContent && isWorkday(d) && !d.isAfter(today);
    }).length;
    return (elapsedWorkdaysSoFar - filledSoFar).clamp(0, elapsedWorkdaysSoFar);
  }

  /// Consecutive filled workdays ending at the most recent workday on/before
  /// today — non-workdays are skipped, not counted as breaks.
  int get currentStreak {
    final i = internship;
    if (i == null) return 0;
    var d = today;
    // Walk back to the most recent workday (today counts if it's a workday,
    // even if not filled yet — an unfilled today shouldn't retroactively
    // erase yesterday's streak).
    var streak = 0;
    var cursor = d;
    var guard = 0;
    while (guard < 3660) {
      if (WorkdayCalculator.isWorkday(cursor, workDaysMask: i.workDaysMask, excludeHolidays: i.excludeHolidays)) {
        final entry = _entries[dateKey(cursor)];
        final filled = entry?.hasOfficialContent ?? false;
        if (filled) {
          streak++;
        } else if (dateKey(cursor) == dateKey(today)) {
          // today not filled yet — skip without breaking the streak.
        } else {
          break;
        }
      }
      if (cursor.isBefore(i.startDate)) break;
      cursor = cursor.subtract(const Duration(days: 1));
      guard++;
    }
    return streak;
  }

  /// Last 7 calendar days, true if that day has a filled entry (used for
  /// the home screen streak dots).
  List<bool> get streakWeek {
    return [
      for (var offset = 6; offset >= 0; offset--)
        _entries[dateKey(today.subtract(Duration(days: offset)))]?.hasOfficialContent ?? false,
    ];
  }

  List<CalendarDay> calendarForMonth(DateTime month) {
    final i = internship;
    if (i == null) return const [];
    final firstOfMonth = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    return [
      for (var d = 0; d < daysInMonth; d++)
        _calendarDayFor(DateTime(firstOfMonth.year, firstOfMonth.month, d + 1), i),
    ];
  }

  CalendarDay _calendarDayFor(DateTime date, Internship i) {
    final key = dateKey(date);
    final entry = _entries[key];
    final workday = isWorkday(date);
    DayType type;
    if (date.isAfter(today)) {
      type = DayType.future;
    } else if (!workday) {
      type = TrHolidays.isHoliday(date) ? DayType.holiday : DayType.notWorkday;
    } else if (entry?.copiedToPaper == true) {
      type = DayType.writtenToPaper;
    } else if (entry?.hasOfficialContent == true) {
      type = DayType.filled;
    } else {
      type = DayType.empty;
    }
    return CalendarDay(date: date, type: type, isToday: key == dateKey(today));
  }

  int get filledThisMonth {
    final now = today;
    return calendarForMonth(now).where((d) => d.isFilled).length;
  }

  // ── Day entries ──────────────────────────────────────────────────
  DayEntry entryFor(DateTime date) {
    final key = dateKey(date);
    return _entries.putIfAbsent(key, () => DayEntry(date: key));
  }

  DayEntry get entryForToday => entryFor(today);

  void updateEntry(
    DateTime date, {
    String? topic,
    String? body,
    String? learned,
    String? checkIn,
    String? checkOut,
    int? mood,
    int? workload,
    String? incident,
    String? incidentCategory,
    String? dailyWin,
    String? song,
    String? journalNote,
  }) {
    final e = entryFor(date);
    if (topic != null) e.topic = topic;
    if (body != null) e.body = body;
    if (learned != null) e.learned = learned;
    if (checkIn != null) e.checkIn = checkIn;
    if (checkOut != null) e.checkOut = checkOut;
    if (mood != null) e.mood = mood;
    if (workload != null) e.workload = workload;
    if (incident != null) e.incident = incident;
    if (incidentCategory != null) e.incidentCategory = incidentCategory;
    if (dailyWin != null) e.dailyWin = dailyWin;
    if (song != null) e.song = song;
    if (journalNote != null) e.journalNote = journalNote;
    e.updatedAt = DateTime.now();
    _afterMutation();
  }

  void toggleMoodReason(DateTime date, String reason) {
    final e = entryFor(date);
    if (e.moodReasons.contains(reason)) {
      e.moodReasons.remove(reason);
    } else {
      e.moodReasons.add(reason);
    }
    e.updatedAt = DateTime.now();
    _afterMutation();
  }

  bool copyFromYesterday(DateTime date) {
    DayEntry? source;
    for (var back = 1; back <= 14 && source == null; back++) {
      final candidate = _entries[dateKey(date.subtract(Duration(days: back)))];
      if (candidate != null && candidate.hasOfficialContent) source = candidate;
    }
    if (source == null) return false;
    final e = entryFor(date);
    e.topic = source.topic;
    e.body = source.body;
    e.learned = source.learned;
    e.tags = [...source.tags];
    e.updatedAt = DateTime.now();
    _afterMutation(immediate: true);
    return true;
  }

  void markCopiedToPaper(DateTime date) {
    entryFor(date).copiedToPaper = true;
    _afterMutation(immediate: true);
  }

  void markSigned(DateTime date) {
    final e = entryFor(date);
    e.signed = !e.signed;
    _afterMutation(immediate: true);
  }

  // ── Photos ──────────────────────────────────────────────────────
  List<DayPhoto> photosFor(DateTime date) =>
      photos.where((p) => p.date == dateKey(date)).toList();

  Future<void> addPhoto(DateTime date, {required bool fromCamera}) async {
    final path = await PhotoService.pickAndStore(fromCamera: fromCamera);
    if (path == null) return;
    photos.add(DayPhoto(id: IdGen.next(), date: dateKey(date), filePath: path));
    _afterMutation(immediate: true);
  }

  void updatePhotoCaption(String id, String caption) {
    final p = photos.where((p) => p.id == id).firstOrNull;
    if (p == null) return;
    p.caption = caption;
    _afterMutation();
  }

  void togglePhotoIncludeInExport(String id) {
    final p = photos.where((p) => p.id == id).firstOrNull;
    if (p == null) return;
    p.includeInExport = !p.includeInExport;
    _afterMutation(immediate: true);
  }

  void deletePhoto(String id) {
    final p = photos.where((p) => p.id == id).firstOrNull;
    if (p == null) return;
    photos.remove(p);
    try {
      final f = File(p.filePath);
      if (f.existsSync()) f.deleteSync();
    } catch (_) {}
    _afterMutation(immediate: true);
  }

  bool get hasAnyPhoto => photos.isNotEmpty;

  // ── Quick counters ─────────────────────────────────────────────────
  void incrementCounter(int index) {
    if (index < 0 || index >= quickCounters.length) return;
    quickCounters[index].count++;
    _afterMutation();
  }

  void addCounter(String emoji, String label) {
    quickCounters.add(QuickCounter(id: IdGen.next(), emoji: emoji, label: label));
    _afterMutation(immediate: true);
  }

  void removeCounterAt(int index) {
    if (index < 0 || index >= quickCounters.length) return;
    quickCounters.removeAt(index);
    _afterMutation(immediate: true);
  }

  // ── Mentor sözlüğü ──────────────────────────────────────────────────
  void addMentorQuote(String quote, {String? author}) {
    if (quote.trim().isEmpty) return;
    mentorQuotes.insert(0, MentorQuote(id: IdGen.next(), quote: quote.trim(), author: author?.trim()));
    _afterMutation(immediate: true);
  }

  void removeMentorQuote(String id) {
    mentorQuotes.removeWhere((q) => q.id == id);
    _afterMutation(immediate: true);
  }

  // ── Bingo ───────────────────────────────────────────────────────────
  /// Only the first 3x3 window counts toward a "line" — extra user-added
  /// tasks beyond that just extend the list without needing a square grid.
  bool get bingoHasLine =>
      AchievementEngine.hasCompletedLine(bingoTasks.take(9).map((t) => t.done).toList());

  void toggleBingo(String id) {
    final t = bingoTasks.where((t) => t.id == id).firstOrNull;
    if (t == null) return;
    t.done = !t.done;
    t.doneAt = t.done ? DateTime.now() : null;
    _afterMutation(immediate: true);
  }

  void resetBingoCard() {
    for (final t in bingoTasks) {
      t.done = false;
      t.doneAt = null;
    }
    _afterMutation(immediate: true);
  }

  void updateBingoTaskText(String id, String text) {
    final t = bingoTasks.where((t) => t.id == id).firstOrNull;
    if (t == null || text.trim().isEmpty) return;
    t.text = text.trim();
    _afterMutation(immediate: true);
  }

  // ── Badges ──────────────────────────────────────────────────────────
  List<AppBadge> _badges = const [];
  List<AppBadge> get badges => _badges;

  void _refreshBadges() {
    if (internship == null) {
      _badges = const [];
      return;
    }
    final prevEarnedKeys = _badges.where((b) => b.earned).map((b) => b.key).toSet();
    final next = AchievementEngine.evaluate(
      entries: allEntries,
      currentStreak: currentStreak,
      filledWorkdays: filledWorkdays,
      totalWorkdays: totalWorkdays,
      hasAnyPhoto: hasAnyPhoto,
      hasBingoLine: bingoHasLine,
      missedWorkdaysSoFar: emptyDaysBehind,
      earnedAtByKey: _badgeEarnedAt,
    );
    for (final b in next) {
      if (b.earned && !_badgeEarnedAt.containsKey(b.key)) {
        _badgeEarnedAt[b.key] = DateTime.now();
      }
    }
    final newlyEarned = next.where((b) => b.earned && !prevEarnedKeys.contains(b.key)).toList();
    if (newlyEarned.isNotEmpty) {
      justEarnedBadge = newlyEarned.first;
    }
    _badges = [
      for (final b in next)
        AppBadge(key: b.key, label: b.label, emoji: b.emoji, earned: b.earned, earnedAt: _badgeEarnedAt[b.key]),
    ];
  }

  AppBadge? consumeJustEarnedBadge() {
    final b = justEarnedBadge;
    justEarnedBadge = null;
    return b;
  }

  // ── Wrapped ─────────────────────────────────────────────────────────
  int get totalWordsWritten => allEntries.fold(0, (sum, e) => sum + e.wordCount);

  // ── Zaman Kapsülü ───────────────────────────────────────────────────
  void openCapsule(String reflection) {
    updateInternship((i) {
      i.capsuleOpened = true;
      i.capsuleReflection = reflection;
    });
  }

  // ── Appearance ──────────────────────────────────────────────────────
  void setDarkTheme(bool value) {
    isDarkTheme = value;
    AppColors.setDark(value);
    _afterMutation(immediate: true);
  }

  void setTextScale(double value) {
    textScale = value;
    _afterMutation(immediate: true);
  }

  // ── PIN lock (Günlüğüm tab) ────────────────────────────────────────
  bool get hasPinLock => _pinHash != null;

  void setPin(String pin) {
    _pinHash = PinUtil.hash(pin);
    personalUnlockedThisSession = true;
    _afterMutation(immediate: true);
  }

  void removePin() {
    _pinHash = null;
    personalUnlockedThisSession = true;
    _afterMutation(immediate: true);
  }

  bool unlockPersonal(String pin) {
    if (_pinHash == null) return true;
    final ok = PinUtil.verify(pin, _pinHash!);
    if (ok) {
      personalUnlockedThisSession = true;
      notifyListeners();
    }
    return ok;
  }

  void lockPersonalNow() {
    personalUnlockedThisSession = false;
    notifyListeners();
  }

  // ── Reset / backup ──────────────────────────────────────────────────
  Future<void> resetAllData() async {
    internship = null;
    _entries.clear();
    photos.clear();
    quickCounters.clear();
    mentorQuotes.clear();
    bingoTasks.clear();
    _badgeEarnedAt.clear();
    _badges = const [];
    isDarkTheme = false;
    AppColors.setDark(false);
    textScale = 1.0;
    _pinHash = null;
    personalUnlockedThisSession = true;
    await LocalStore.clear();
    notifyListeners();
  }

  Map<String, dynamic> toBackupJson() => {
        'internship': internship?.toJson(),
        'entries': _entries.values.map((e) => e.toJson()).toList(),
        'photos': photos.map((p) => p.toJson()).toList(),
        'counters': quickCounters.map((c) => c.toJson()).toList(),
        'mentorQuotes': mentorQuotes.map((q) => q.toJson()).toList(),
        'bingoTasks': bingoTasks.map((t) => t.toJson()).toList(),
        'badgeEarnedAt': _badgeEarnedAt.map((k, v) => MapEntry(k, v.toIso8601String())),
        'isDarkTheme': isDarkTheme,
        'textScale': textScale,
        'pinHash': _pinHash,
      };

  void _applyBackupJson(Map<String, dynamic> json, {required bool notify}) {
    final internshipJson = json['internship'];
    internship = internshipJson != null ? Internship.fromJson(Map<String, dynamic>.from(internshipJson)) : null;

    _entries.clear();
    for (final raw in (json['entries'] as List? ?? [])) {
      final e = DayEntry.fromJson(Map<String, dynamic>.from(raw));
      _entries[e.date] = e;
    }

    photos
      ..clear()
      ..addAll((json['photos'] as List? ?? []).map((r) => DayPhoto.fromJson(Map<String, dynamic>.from(r))));

    quickCounters
      ..clear()
      ..addAll((json['counters'] as List? ?? []).map((r) => QuickCounter.fromJson(Map<String, dynamic>.from(r))));

    mentorQuotes
      ..clear()
      ..addAll((json['mentorQuotes'] as List? ?? []).map((r) => MentorQuote.fromJson(Map<String, dynamic>.from(r))));

    bingoTasks
      ..clear()
      ..addAll((json['bingoTasks'] as List? ?? []).map((r) => BingoTask.fromJson(Map<String, dynamic>.from(r))));

    _badgeEarnedAt
      ..clear()
      ..addEntries(
        (Map<String, dynamic>.from(json['badgeEarnedAt'] ?? {}))
            .entries
            .map((e) => MapEntry(e.key, DateTime.parse(e.value))),
      );

    isDarkTheme = json['isDarkTheme'] ?? false;
    textScale = (json['textScale'] as num?)?.toDouble() ?? 1.0;
    _pinHash = json['pinHash'];
    personalUnlockedThisSession = _pinHash == null;

    if (internship != null) {
      _applyReminder();
      _refreshBadges();
    }
    if (notify) notifyListeners();
  }

  Future<bool> restoreFromBackupJson(Map<String, dynamic> json) async {
    try {
      _applyBackupJson(json, notify: true);
      await saveNow();
      return true;
    } catch (_) {
      return false;
    }
  }
}
