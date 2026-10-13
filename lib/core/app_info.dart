import 'package:package_info_plus/package_info_plus.dart';

/// App version from pubspec.yaml (`version:`), read once at startup so the
/// About screen never drifts from what's actually published.
class AppInfo {
  AppInfo._();

  static String version = '1.0.0';

  static Future<void> load() async {
    try {
      version = (await PackageInfo.fromPlatform()).version;
    } catch (_) {
      // Keep the fallback (e.g. in widget tests with no platform plugin).
    }
  }
}
