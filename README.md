# Cepte Staj

An internship-notebook app built from the "Kağıt ve Mürekkep" (Paper &
Ink) visual design. Tracks internship work days against a physical
notebook: a digital "Defter" entry per day, a mode for copying that entry
onto paper, a calendar overview, and a private "Günlüğüm" journal that
never syncs to the notebook.

## Screens

- **Açılış** — splash / wordmark
- **Bugün** — home: work-days-remaining ring, streak, quick counters
- **Takvim** — month calendar (filled / missing / holiday / copied-to-paper)
- **Gün Detayı** — Defter / Fotoğraf / Günlüğüm tabs for a single day
- **Kağıda Geçirme Modu** — line-by-line walkthrough for copying a Defter
  entry onto the physical notebook
- **Günlüğüm** — private tab: mood chart, bingo, badges, mentor quotes
- **Staj Wrapped** — end-of-internship summary story

## Design tokens

Colors, type (Plus Jakarta Sans + Inter via `google_fonts`), spacing and
radii live in `lib/theme/`. The notebook side of the app is accented ink
teal (`#01696F`); the private journal side is accented terra
(`#B4501F`).

## Running

This is a standard Flutter app. All screens use mock/demo data in
`lib/data/app_state.dart` (no backend) — reset it any time from
Ayarlar → "Demo verisini sıfırla".

```
flutter pub get
flutter run
```

Run tests / static analysis:

```
flutter test
flutter analyze
```
