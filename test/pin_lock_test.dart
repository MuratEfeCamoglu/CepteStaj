// The Günlüğüm PIN must lock again once the app has been in the background
// for a while — otherwise Android keeps the process alive and the tab stays
// open to anyone who picks up the phone.

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:cepte_staj/data/app_state.dart';

Future<AppState> _stateWithPin() async {
  SharedPreferences.setMockInitialValues({});
  final state = AppState();
  while (state.loading) {
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
  state.setPin('1234');
  return state;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final t0 = DateTime(2026, 10, 16, 12);

  test('relocks after a long stay in the background', () async {
    final state = await _stateWithPin();
    expect(state.personalUnlockedThisSession, isTrue);

    state.onAppBackgrounded(t0);
    state.onAppForegrounded(t0.add(const Duration(minutes: 1)));

    expect(state.personalUnlockedThisSession, isFalse);
  });

  test('stays open after a quick trip out (photo picker, share sheet)', () async {
    final state = await _stateWithPin();

    state.onAppBackgrounded(t0);
    state.onAppForegrounded(t0.add(const Duration(seconds: 10)));

    expect(state.personalUnlockedThisSession, isTrue);
  });

  test('does nothing when no PIN is set', () async {
    final state = await _stateWithPin();
    state.removePin();

    state.onAppBackgrounded(t0);
    state.onAppForegrounded(t0.add(const Duration(hours: 1)));

    expect(state.personalUnlockedThisSession, isTrue);
  });
}
