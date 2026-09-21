import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Local-only PIN hashing for the personal-tab lock. This isn't meant to
/// resist a serious attacker with device access (that's what OS-level
/// screen lock is for) — it just stops a curious over-the-shoulder glance
/// at the Günlüğüm tab, per the app's "sızdırmaz iki katman" rule.
class PinUtil {
  PinUtil._();

  static String hash(String pin) {
    final bytes = utf8.encode('cepte_staj_salt_v1:$pin');
    return sha256.convert(bytes).toString();
  }

  static bool verify(String pin, String storedHash) => hash(pin) == storedHash;
}
