import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

/// Looks up a shared Spotify link's track name via Spotify's public oEmbed
/// endpoint (no account, no API key). Only the link itself is sent — this
/// is the app's one network call, made when the user shares a song in.
/// Any failure (offline, timeout, odd link) just returns null and the user
/// can type the name instead.
class SongLookup {
  SongLookup._();

  static Future<String?> titleFor(String url) async {
    if (!url.contains('spotify')) return null;
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 6);
    try {
      final uri = Uri.https('open.spotify.com', '/oembed', {'url': await _expand(client, url)});
      final req = await client.getUrl(uri);
      final res = await req.close().timeout(const Duration(seconds: 8));
      if (res.statusCode != 200) return null;
      final body = await res.transform(utf8.decoder).join();
      final title = (jsonDecode(body) as Map)['title'];
      return title is String && title.trim().isNotEmpty ? title.trim() : null;
    } catch (e) {
      debugPrint('SongLookup failed: $e');
      return null;
    } finally {
      client.close(force: true);
    }
  }

  /// Short spotify.link URLs redirect to open.spotify.com; oEmbed only
  /// understands the long form.
  static Future<String> _expand(HttpClient client, String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null || uri.host == 'open.spotify.com') return url;
    final req = await client.getUrl(uri);
    final res = await req.close().timeout(const Duration(seconds: 8));
    await res.drain<void>();
    final hops = res.redirects;
    return hops.isEmpty ? url : hops.last.location.toString();
  }
}
