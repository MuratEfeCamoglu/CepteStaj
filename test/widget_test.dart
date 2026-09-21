// Smoke tests: the app boots to onboarding on a fresh install, and — once
// an internship is already configured — lands on the home tab with all
// four bottom-nav tabs reachable.

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:cepte_staj/main.dart';

Future<void> _pumpAndSettleBoot(WidgetTester tester) async {
  await tester.pumpWidget(const CepteStajApp());
  await tester.pump(const Duration(milliseconds: 1000));
  await tester.pumpAndSettle();
}

/// Minimal but valid `cepte_staj_state_v1` payload with an internship
/// already configured, so boot skips onboarding and lands on Home.
Map<String, dynamic> _seededState() => {
      'internship': {
        'name': 'Test Stajı',
        'company': 'Acme',
        'department': '',
        'supervisor': '',
        'totalWorkdays': 20,
        'startDate': '2026-08-17',
        'workDaysMask': [true, true, true, true, true, false, false],
        'excludeHolidays': true,
        'dailyWordGoal': 120,
        'wordsPerLine': 12,
        'reminderEnabled': false,
        'reminderHour': 20,
        'reminderMinute': 0,
        'capsuleExpectation': '',
        'capsuleFear': '',
        'capsuleReflection': '',
        'capsuleOpened': false,
      },
      'entries': [],
      'photos': [],
      'counters': [
        {'id': 'c1', 'emoji': '☕', 'label': 'Kahve molası', 'count': 0},
      ],
      'mentorQuotes': [],
      'bingoTasks': [],
      'badgeEarnedAt': {},
      'isDarkTheme': false,
      'textScale': 1.0,
      'pinHash': null,
    };

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Fresh install boots from splash into onboarding', (WidgetTester tester) async {
    await tester.pumpWidget(const CepteStajApp());

    expect(find.text('Cepte'), findsOneWidget);
    expect(find.text('Staj'), findsOneWidget);

    await _pumpAndSettleBoot(tester);
    expect(find.text('Cepte Staj\'a hoş geldin'), findsOneWidget);
  });

  testWidgets('An already-configured internship boots straight to Home', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({
      'cepte_staj_state_v1': jsonEncode(_seededState()),
    });

    await _pumpAndSettleBoot(tester);
    expect(find.text('Bugünü doldur'), findsOneWidget);
  });

  testWidgets('Bottom nav switches between all four tabs', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({
      'cepte_staj_state_v1': jsonEncode(_seededState()),
    });
    await _pumpAndSettleBoot(tester);

    await tester.tap(find.text('Takvim'));
    await tester.pumpAndSettle();
    expect(find.textContaining('gün doldurdun'), findsOneWidget);

    await tester.tap(find.text('Günlüğüm').first);
    await tester.pumpAndSettle();
    expect(find.text('Bugün nasıldı?'), findsOneWidget);
    await tester.dragUntilVisible(
      find.text('Mentor sözlüğü'),
      find.byType(Scrollable).first,
      const Offset(0, -300),
    );
    expect(find.text('Mentor sözlüğü'), findsOneWidget);

    await tester.tap(find.text('Ayarlar'));
    await tester.pumpAndSettle();
    expect(find.text('Staj tarihleri'), findsOneWidget);
  });

  testWidgets('Günlüğüm lets you step back to a previous day to catch up', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({
      'cepte_staj_state_v1': jsonEncode(_seededState()),
    });
    await _pumpAndSettleBoot(tester);

    await tester.tap(find.text('Günlüğüm').first);
    await tester.pumpAndSettle();
    expect(find.text('Bugün nasıldı?'), findsOneWidget);

    await tester.tap(find.byTooltip('Önceki gün'));
    await tester.pumpAndSettle();
    expect(find.text('Bugün nasıldı?'), findsNothing);
    expect(find.textContaining('nasıldı?'), findsOneWidget);

    await tester.tap(find.byTooltip('Sonraki gün'));
    await tester.pumpAndSettle();
    expect(find.text('Bugün nasıldı?'), findsOneWidget);
  });

  testWidgets('Resetting all data from Settings does not crash the still-mounted Home/Calendar/Günlüğüm tabs',
      (WidgetTester tester) async {
    // Regression test: AppShell keeps every tab alive in an IndexedStack,
    // so clearing `internship` while Settings is on screen must not crash
    // the off-screen tabs' Consumer<AppState> rebuilds (see AppState's
    // null-safe getters and JournalScreen's early-return guard).
    SharedPreferences.setMockInitialValues({
      'cepte_staj_state_v1': jsonEncode(_seededState()),
    });
    await _pumpAndSettleBoot(tester);

    // Visit Calendar and Günlüğüm once so their tab widgets are built and
    // alive inside the IndexedStack before we reset from Settings.
    await tester.tap(find.text('Takvim'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Günlüğüm').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ayarlar'));
    await tester.pumpAndSettle();

    await tester.dragUntilVisible(
      find.text('Tüm verileri sıfırla'),
      find.byType(Scrollable).first,
      const Offset(0, -300),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tüm verileri sıfırla'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sil'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Cepte Staj\'a hoş geldin'), findsOneWidget);
  });

  testWidgets('Staj Wrapped does not crash when every quick counter has been removed',
      (WidgetTester tester) async {
    // Regression test: Ayarlar lets a user long-press-remove every quick
    // counter down to zero. WrappedScreen used to call `.first` on the
    // (possibly empty) counters list to build its "kahve" slide.
    final seeded = _seededState()..['counters'] = <Map<String, dynamic>>[];
    SharedPreferences.setMockInitialValues({
      'cepte_staj_state_v1': jsonEncode(seeded),
    });
    await _pumpAndSettleBoot(tester);

    await tester.tap(find.text('Ayarlar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Staj Wrapped\'ı gör'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('kelime yazdın'), findsOneWidget);
  });

  testWidgets('Günlüğüm text fields follow the selected day when stepping between days', (tester) async {
    SharedPreferences.setMockInitialValues({'cepte_staj_state_v1': jsonEncode(_seededState())});
    await _pumpAndSettleBoot(tester);
    await tester.tap(find.text('Günlüğüm').first);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'Bugünkü olay');
    await tester.pumpAndSettle();
    expect(find.text('Bugünkü olay'), findsOneWidget);

    await tester.ensureVisible(find.byTooltip('Önceki gün'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Önceki gün'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Bugünkü olay'), findsNothing);

    await tester.ensureVisible(find.byTooltip('Sonraki gün'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Sonraki gün'));
    await tester.pumpAndSettle();
    expect(find.text('Bugünkü olay'), findsOneWidget);
  });

  testWidgets('Kağıda geçir on an empty day does not mark it as written', (tester) async {
    SharedPreferences.setMockInitialValues({'cepte_staj_state_v1': jsonEncode(_seededState())});
    await _pumpAndSettleBoot(tester);

    await tester.tap(find.text('Bugünü doldur'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Kağıda geçir'));
    await tester.pumpAndSettle();
    expect(find.text('Bu gün için henüz bir defter kaydın yok.'), findsOneWidget);

    await tester.tap(find.text('Geri dön'));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.check_circle), findsNothing);
  });

  testWidgets('Bingo sheet opens, ticks a square and lets you rewrite it', (tester) async {
    final seeded = _seededState()
      ..['bingoTasks'] = [
        for (var i = 0; i < 9; i++) {'id': 'b$i', 'text': i == 0 ? 'İlk kez toplantıda konuştum' : 'Görev $i', 'done': false},
      ];
    SharedPreferences.setMockInitialValues({'cepte_staj_state_v1': jsonEncode(seeded)});
    await _pumpAndSettleBoot(tester);
    await tester.tap(find.text('Günlüğüm').first);
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Bingo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bingo'));
    await tester.pumpAndSettle();
    expect(find.text('Staj Bingo'), findsOneWidget);

    await tester.tap(find.text('İlk kez toplantıda konuştum'));
    await tester.pumpAndSettle();
    expect(find.text('✓ İlk kez toplantıda konuştum'), findsOneWidget);

    await tester.longPress(find.text('✓ İlk kez toplantıda konuştum'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'Kendi görevim');
    await tester.tap(find.text('Kaydet'));
    await tester.pumpAndSettle();
    expect(find.text('✓ Kendi görevim'), findsOneWidget);
  });

  testWidgets('Editing staj dates from Ayarlar starts on the info step and Back exits', (tester) async {
    SharedPreferences.setMockInitialValues({'cepte_staj_state_v1': jsonEncode(_seededState())});
    await _pumpAndSettleBoot(tester);
    await tester.tap(find.text('Ayarlar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Staj tarihleri'));
    await tester.pumpAndSettle();
    expect(find.text('Staj bilgileri'), findsOneWidget);

    await tester.tap(find.text('Geri'));
    await tester.pumpAndSettle();
    expect(find.text('Staj tarihleri'), findsOneWidget);
  });
}
