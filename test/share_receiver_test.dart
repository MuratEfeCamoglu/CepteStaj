import 'package:cepte_staj/core/share_receiver.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Spotify "Check out … by … on Spotify" becomes "title - artist" plus link', () {
    final s = parseSharedSong(
      'Check out "Bohemian Rhapsody" by Queen on Spotify https://open.spotify.com/track/abc?si=1',
    )!;
    expect(s.title, 'Bohemian Rhapsody - Queen');
    expect(s.url, 'https://open.spotify.com/track/abc?si=1');
  });

  test('link-only share keeps the link with an empty title', () {
    final s = parseSharedSong('https://open.spotify.com/track/abc')!;
    expect(s.title, isEmpty);
    expect(s.url, 'https://open.spotify.com/track/abc');
  });

  test('title in the subject, link in the text', () {
    final s = parseSharedSong('https://spotify.link/xyz', subject: 'Sezen Aksu · Gidiyorum')!;
    expect(s.title, 'Sezen Aksu - Gidiyorum');
    expect(s.url, 'https://spotify.link/xyz');
  });

  test('shares without a music link are not songs', () {
    expect(parseSharedSong('Tarkan - Kuzu Kuzu'), isNull);
    expect(parseSharedSong('Bu habere bak https://haber.example.com/x'), isNull);
    expect(parseSharedSong('   '), isNull);
  });

  test('real Spotify share: link only, HTML-escaped ampersand', () {
    final s = parseSharedSong('https://open.spotify.com/track/0vk?si=_V&amp;utm_source=native-share-menu')!;
    expect(s.title, isEmpty);
    expect(s.url, 'https://open.spotify.com/track/0vk?si=_V&utm_source=native-share-menu');
  });

  test('titles containing filler words survive', () {
    expect(parseSharedSong('Stand by Me - Ben E. King https://open.spotify.com/track/a')!.title, 'Stand by Me - Ben E. King');
    expect(parseSharedSong('Listen To Your Heart - Roxette https://open.spotify.com/track/b')!.title,
        'Listen To Your Heart - Roxette');
  });
}
