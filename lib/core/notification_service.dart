import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Wraps flutter_local_notifications for the single daily "doldurmayı
/// unutma" reminder. Every call is defensive (try/catch) — a notification
/// failing to schedule should never crash the app or block saving an entry.
class NotificationService {
  NotificationService._();
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _ready = false;
  static const _dailyReminderId = 1001;

  static Future<void> _ensureInitialized() async {
    if (_ready) return;
    try {
      tz_data.initializeTimeZones();
      try {
        final info = await FlutterTimezone.getLocalTimezone();
        tz.setLocalLocation(tz.getLocation(info.identifier));
      } catch (_) {
        // Fall back to whatever `tz.local` defaults to (UTC) — the
        // reminder will still fire, just possibly at a shifted hour.
      }
      const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosInit = DarwinInitializationSettings();
      const initSettings = InitializationSettings(android: androidInit, iOS: iosInit);
      await _plugin.initialize(settings: initSettings);
      _ready = true;
    } catch (e) {
      debugPrint('NotificationService init failed: $e');
    }
  }

  static Future<bool> requestPermission() async {
    await _ensureInitialized();
    try {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (android != null) {
        final granted = await android.requestNotificationsPermission();
        return granted ?? true;
      }
      final ios = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      if (ios != null) {
        final granted = await ios.requestPermissions(alert: true, badge: true, sound: true);
        return granted ?? true;
      }
      return true;
    } catch (e) {
      debugPrint('NotificationService permission request failed: $e');
      return false;
    }
  }

  /// Schedules (or reschedules) the daily reminder at [hour]:[minute].
  static Future<void> scheduleDailyReminder({required int hour, required int minute}) async {
    await _ensureInitialized();
    try {
      await _plugin.cancel(id: _dailyReminderId);
      final now = tz.TZDateTime.now(tz.local);
      var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
      if (scheduled.isBefore(now)) {
        scheduled = scheduled.add(const Duration(days: 1));
      }
      const details = NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminder',
          'Günlük hatırlatıcı',
          channelDescription: 'Bugünü doldurmayı hatırlatır',
          importance: Importance.defaultImportance,
        ),
        iOS: DarwinNotificationDetails(),
      );
      await _plugin.zonedSchedule(
        id: _dailyReminderId,
        scheduledDate: scheduled,
        notificationDetails: details,
        title: 'Cepte Staj',
        body: 'Bugünü doldurmayı unutma ✍️',
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      debugPrint('NotificationService scheduling failed: $e');
    }
  }

  static Future<void> cancelDailyReminder() async {
    await _ensureInitialized();
    try {
      await _plugin.cancel(id: _dailyReminderId);
    } catch (e) {
      debugPrint('NotificationService cancel failed: $e');
    }
  }
}
