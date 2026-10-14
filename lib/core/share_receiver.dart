import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// A song shared into the app — title may be empty when the sharing app
/// only sent a link (see SongLookup). A null [url] means the share wasn't
/// a music link at all and should be ignored.
class SharedSong {
  final String title;
  final String? url;
  const SharedSong({required this.title, this.url});

  bool get isMusic => url != null;
}

/// Text shared into the app from another app's share sheet (Android only;
/// see MainActivity.kt). Used for Spotify → Share → Cepte Staj.
class ShareReceiver {
  ShareReceiver._();

  static const _channel = MethodChannel('cepte_staj/share');

  /// Calls [onSong] for a share that launched the app, and for every share
  /// that arrives while it's running.
  static Future<void> listen(ValueChanged<SharedSong> onSong) async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'shared') _deliver(call.arguments, onSong);
    });
    try {
      _deliver(await _channel.invokeMethod('takePending'), onSong);
    } on MissingPluginException {
      // Tests / other platforms: no native side.
    } on PlatformException {
      // Nothing worth surfacing — the share is simply ignored.
    }
  }

  static void _deliver(Object? args, ValueChanged<SharedSong> onSong) {
    if (args is! Map) return;
    final song = parseSharedSong(args['text'] as String? ?? '', subject: args['subject'] as String?);
    onSong(song ?? const SharedSong(title: '', url: null));
  }
}

final _url = RegExp(r'https?://\S+');
final _musicHosts = RegExp(r'^(open\.spotify\.com|spotify\.link|music\.youtube\.com|music\.apple\.com|(www\.)?deezer\.com|deezer\.page\.link)$');

bool _isMusicUrl(String url) => _musicHosts.hasMatch(Uri.tryParse(url)?.host ?? '');

/// Pulls a "title - artist" and a link out of whatever a music app put in
/// the share intent. Spotify's wording varies by version and language
/// ("Check out "X" by Y on Spotify", just the link, the title in the
/// subject...), so this strips the known filler rather than matching one
/// exact format. Returns null unless the share carries a music link —
/// the share sheet offers Cepte Staj for any text, and a news article must
/// not overwrite today's song.
SharedSong? parseSharedSong(String text, {String? subject}) {
  final url = [..._url.allMatches(text), ..._url.allMatches(subject ?? '')]
      .map((m) => m.group(0)!.replaceAll('&amp;', '&'))
      .where(_isMusicUrl)
      .firstOrNull;
  if (url == null) return null;
  var rest = [subject ?? '', text].join(' ').replaceAll(_url, ' ');
  rest = rest
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim()
      // Only filler that introduces a quoted title, so "Listen To Your Heart" stays.
      .replaceFirst(RegExp(r'''^(check out|listen to|şuna göz at|bunu dinle)\s*:?\s*(?=["“])''', caseSensitive: false), '')
      .replaceFirst(RegExp(r"\s*((on|in) (spotify|youtube music|apple music|deezer)|spotify'da|spotify’da)\s*:?$", caseSensitive: false), '')
      .trim();

  // "Song" by Artist  →  Song - Artist
  final quoted = RegExp(r'''^["“”]\s*(.+?)\s*["“”]\s*(?:by|·|-|,)\s*(.+)$''').firstMatch(rest);
  if (quoted != null) {
    rest = '${quoted.group(1)} - ${quoted.group(2)}';
  } else {
    rest = rest.replaceAll(RegExp(r'\s+·\s+'), ' - ');
  }
  rest = rest.replaceAll(RegExp(r'''^[\s"“”'·:\-]+|[\s"“”'·:\-]+$'''), '');

  // The same title often arrives twice (subject and text).
  final half = rest.length ~/ 2;
  if (rest.length > 6 && rest.length.isOdd && rest.substring(0, half) == rest.substring(half + 1)) {
    rest = rest.substring(0, half);
  }

  if (rest.length > 120) rest = '${rest.substring(0, 117)}...';
  return SharedSong(title: rest, url: url);
}
