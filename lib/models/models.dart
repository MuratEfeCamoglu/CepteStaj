import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Date key helper: every "one entry per calendar day" record is keyed by
/// this canonical `yyyy-MM-dd` string instead of an arbitrary index, so the
/// calendar, the day-detail screen and the entries map all agree on what
/// "today" or "the 8th" mean.
String dateKey(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

DateTime parseDateKey(String key) {
  final parts = key.split('-');
  return DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
}

/// The fill-state of a single calendar day, derived at render time from the
/// real [Internship] + [DayEntry] data rather than stored directly.
enum DayType { filled, empty, holiday, writtenToPaper, future, notWorkday }

class CalendarDay {
  final DateTime date;
  final DayType type;
  final bool isToday;

  const CalendarDay({required this.date, required this.type, this.isToday = false});

  bool get isFilled => type == DayType.filled || type == DayType.writtenToPaper;
}

/// The active internship's configuration — set during onboarding, editable
/// later from Ayarlar → Staj tarihleri.
class Internship {
  String name;
  String company;
  String department;
  String supervisor;
  int totalWorkdays;
  DateTime startDate;

  /// index 0 = Monday ... index 6 = Sunday.
  List<bool> workDaysMask;
  bool excludeHolidays;
  int dailyWordGoal;
  int wordsPerLine;
  bool reminderEnabled;
  int reminderHour;
  int reminderMinute;

  // Zaman Kapsülü
  String capsuleExpectation;
  String capsuleFear;
  String capsuleReflection;
  bool capsuleOpened;

  Internship({
    this.name = 'Stajım',
    this.company = '',
    this.department = '',
    this.supervisor = '',
    this.totalWorkdays = 20,
    DateTime? startDate,
    List<bool>? workDaysMask,
    this.excludeHolidays = true,
    this.dailyWordGoal = 120,
    this.wordsPerLine = 12,
    this.reminderEnabled = true,
    this.reminderHour = 20,
    this.reminderMinute = 0,
    this.capsuleExpectation = '',
    this.capsuleFear = '',
    this.capsuleReflection = '',
    this.capsuleOpened = false,
  })  : startDate = startDate ?? DateTime.now(),
        workDaysMask = workDaysMask ?? [true, true, true, true, true, false, false];

  Map<String, dynamic> toJson() => {
        'name': name,
        'company': company,
        'department': department,
        'supervisor': supervisor,
        'totalWorkdays': totalWorkdays,
        'startDate': dateKey(startDate),
        'workDaysMask': workDaysMask,
        'excludeHolidays': excludeHolidays,
        'dailyWordGoal': dailyWordGoal,
        'wordsPerLine': wordsPerLine,
        'reminderEnabled': reminderEnabled,
        'reminderHour': reminderHour,
        'reminderMinute': reminderMinute,
        'capsuleExpectation': capsuleExpectation,
        'capsuleFear': capsuleFear,
        'capsuleReflection': capsuleReflection,
        'capsuleOpened': capsuleOpened,
      };

  factory Internship.fromJson(Map<String, dynamic> j) => Internship(
        name: j['name'] ?? 'Stajım',
        company: j['company'] ?? '',
        department: j['department'] ?? '',
        supervisor: j['supervisor'] ?? '',
        totalWorkdays: j['totalWorkdays'] ?? 20,
        startDate: j['startDate'] != null ? parseDateKey(j['startDate']) : DateTime.now(),
        workDaysMask: (j['workDaysMask'] as List?)?.cast<bool>() ??
            [true, true, true, true, true, false, false],
        excludeHolidays: j['excludeHolidays'] ?? true,
        dailyWordGoal: j['dailyWordGoal'] ?? 120,
        wordsPerLine: j['wordsPerLine'] ?? 12,
        reminderEnabled: j['reminderEnabled'] ?? true,
        reminderHour: j['reminderHour'] ?? 20,
        reminderMinute: j['reminderMinute'] ?? 0,
        capsuleExpectation: j['capsuleExpectation'] ?? '',
        capsuleFear: j['capsuleFear'] ?? '',
        capsuleReflection: j['capsuleReflection'] ?? '',
        capsuleOpened: j['capsuleOpened'] ?? false,
      );
}

/// One notebook entry for a given calendar day — official ("Defter") and
/// personal ("Günlüğüm") fields live on the same record but are kept
/// strictly separate at the *usage* level: see AppState.buildOfficialPdfData,
/// the only place allowed to read the official-only subset for export.
class DayEntry {
  final String date; // yyyy-MM-dd, unique key
  // ── Resmi (Defter) ──
  String topic;
  String body;
  String learned;
  String checkIn;
  String checkOut;
  List<String> tags;
  bool copiedToPaper;
  bool signed;

  // ── Kişisel (Günlüğüm) ──
  int mood; // 0 = unset, 1..5
  int workload; // 0 = unset, 1 = boş, 2 = normal, 3 = yoğun
  List<String> moodReasons;
  String incident;
  String? incidentCategory;
  String dailyWin;
  String song;
  String journalNote; // free-form legacy note field, kept for continuity

  DateTime createdAt;
  DateTime updatedAt;

  DayEntry({
    required this.date,
    this.topic = '',
    this.body = '',
    this.learned = '',
    this.checkIn = '',
    this.checkOut = '',
    List<String>? tags,
    this.copiedToPaper = false,
    this.signed = false,
    this.mood = 0,
    this.workload = 0,
    List<String>? moodReasons,
    this.incident = '',
    this.incidentCategory,
    this.dailyWin = '',
    this.song = '',
    this.journalNote = '',
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : tags = tags ?? [],
        moodReasons = moodReasons ?? [],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  int get wordCount => body.trim().isEmpty ? 0 : body.trim().split(RegExp(r'\s+')).length;
  int get charCount => body.length;

  /// Rough estimate of physical notebook lines this entry will take up.
  int lineEstimate(int wordsPerLine) =>
      body.trim().isEmpty ? 0 : (wordCount / wordsPerLine).ceil();

  bool get hasOfficialContent => topic.trim().isNotEmpty || body.trim().isNotEmpty;
  bool get hasPersonalContent =>
      mood != 0 || workload != 0 || incident.trim().isNotEmpty || dailyWin.trim().isNotEmpty ||
      moodReasons.isNotEmpty || journalNote.trim().isNotEmpty || song.trim().isNotEmpty;

  Map<String, dynamic> toJson() => {
        'date': date,
        'topic': topic,
        'body': body,
        'learned': learned,
        'checkIn': checkIn,
        'checkOut': checkOut,
        'tags': tags,
        'copiedToPaper': copiedToPaper,
        'signed': signed,
        'mood': mood,
        'workload': workload,
        'moodReasons': moodReasons,
        'incident': incident,
        'incidentCategory': incidentCategory,
        'dailyWin': dailyWin,
        'song': song,
        'journalNote': journalNote,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory DayEntry.fromJson(Map<String, dynamic> j) => DayEntry(
        date: j['date'],
        topic: j['topic'] ?? '',
        body: j['body'] ?? '',
        learned: j['learned'] ?? '',
        checkIn: j['checkIn'] ?? '',
        checkOut: j['checkOut'] ?? '',
        tags: (j['tags'] as List?)?.cast<String>() ?? [],
        copiedToPaper: j['copiedToPaper'] ?? false,
        signed: j['signed'] ?? false,
        mood: j['mood'] ?? 0,
        workload: j['workload'] ?? 0,
        moodReasons: (j['moodReasons'] as List?)?.cast<String>() ?? [],
        incident: j['incident'] ?? '',
        incidentCategory: j['incidentCategory'],
        dailyWin: j['dailyWin'] ?? '',
        song: j['song'] ?? '',
        journalNote: j['journalNote'] ?? '',
        createdAt: j['createdAt'] != null ? DateTime.parse(j['createdAt']) : DateTime.now(),
        updatedAt: j['updatedAt'] != null ? DateTime.parse(j['updatedAt']) : DateTime.now(),
      );
}

/// A photo attached to a day entry. Personal by default — the user has to
/// explicitly opt a photo into the official export.
class DayPhoto {
  final String id;
  final String date;
  String filePath;
  String caption;
  bool includeInExport;

  DayPhoto({
    required this.id,
    required this.date,
    required this.filePath,
    this.caption = '',
    this.includeInExport = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date,
        'filePath': filePath,
        'caption': caption,
        'includeInExport': includeInExport,
      };

  factory DayPhoto.fromJson(Map<String, dynamic> j) => DayPhoto(
        id: j['id'],
        date: j['date'],
        filePath: j['filePath'],
        caption: j['caption'] ?? '',
        includeInExport: j['includeInExport'] ?? false,
      );
}

/// A single quick-tap counter chip on the home screen (coffee breaks, bugs
/// fixed, questions asked, ...).
class QuickCounter {
  final String id;
  final String emoji;
  final String label;
  int count;

  QuickCounter({required this.id, required this.emoji, required this.label, this.count = 0});

  Map<String, dynamic> toJson() => {'id': id, 'emoji': emoji, 'label': label, 'count': count};

  factory QuickCounter.fromJson(Map<String, dynamic> j) => QuickCounter(
        id: j['id'],
        emoji: j['emoji'],
        label: j['label'],
        count: j['count'] ?? 0,
      );
}

/// A short definition collected in the private "mentor sözlüğü" (mentor
/// dictionary) card.
class MentorQuote {
  final String id;
  String quote;
  String? author;
  DateTime createdAt;

  MentorQuote({required this.id, required this.quote, this.author, DateTime? createdAt})
      : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() =>
      {'id': id, 'quote': quote, 'author': author, 'createdAt': createdAt.toIso8601String()};

  factory MentorQuote.fromJson(Map<String, dynamic> j) => MentorQuote(
        id: j['id'],
        quote: j['quote'],
        author: j['author'],
        createdAt: j['createdAt'] != null ? DateTime.parse(j['createdAt']) : DateTime.now(),
      );
}

/// One cell of the Staj Bingo card.
class BingoTask {
  final String id;
  String text;
  bool done;
  DateTime? doneAt;

  BingoTask({required this.id, required this.text, this.done = false, this.doneAt});

  Map<String, dynamic> toJson() =>
      {'id': id, 'text': text, 'done': done, 'doneAt': doneAt?.toIso8601String()};

  factory BingoTask.fromJson(Map<String, dynamic> j) => BingoTask(
        id: j['id'],
        text: j['text'],
        done: j['done'] ?? false,
        doneAt: j['doneAt'] != null ? DateTime.parse(j['doneAt']) : null,
      );

  static List<String> defaultTasks = const [
    'İlk kez toplantıda konuştum',
    'Bir şeyi bozdum ve düzelttim',
    'Ekiple öğle yemeğine çıktım',
    'Mentoruma "anlamadım" dedim',
    'Kendi başıma bir görevi bitirdim',
    'Bir kere geç kaldım',
    'Birine bir şey öğrettim',
    'Production\'a bir şey gönderdim',
    'Yeni bir araç/teknoloji öğrendim',
  ];
}

/// Named `AppBadge` to avoid clashing with `package:flutter/material.dart`'s
/// own `Badge` widget. Earned state is computed by the achievement engine,
/// never stored directly (except [earnedAt] once it fires), so re-evaluating
/// past data always yields consistent results.
class AppBadge {
  final String key;
  final String label;
  final String emoji;
  final bool earned;
  final DateTime? earnedAt;

  const AppBadge({
    required this.key,
    required this.label,
    required this.emoji,
    this.earned = false,
    this.earnedAt,
  });
}

/// Colors that flip depending on which "side" of the app is active: the
/// shared/official notebook side (teal) vs. the private journal side
/// (terra).
class SectionAccent {
  final Color color;
  const SectionAccent(this.color);

  static SectionAccent get notebook => SectionAccent(AppColors.ink);
  static SectionAccent get journal => SectionAccent(AppColors.terra);
}

const List<(String emoji, String label)> incidentCategories = [
  ('🤦', 'utanç'),
  ('😂', 'komik'),
  ('😱', 'panik'),
  ('💀', 'felaket'),
  ('🏆', 'gurur'),
  ('🤔', 'tuhaf'),
];

const List<String> moodReasonOptions = [
  'yoğun', 'sıkıldım', 'yeni şey öğrendim', 'mentor iyiydi', 'kimse iş vermedi',
  'ekip güzeldi', 'yorgunum', 'gurur duydum', 'kaos', 'trafik/yol',
];

const List<String> moodEmojis = ['😫', '😕', '😐', '🙂', '🤩'];
