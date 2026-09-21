# Cepte Staj

Staj defterini elle doldurmak zorunda olan stajyerler için geliştirilmiş,
**offline-first** bir Flutter uygulaması. Gün içinde hızlıca not almanı,
akşam bu notu fiziksel deftere geçirmeni kolaylaştırır — ve stajı sadece
bir zorunluluk değil, hatırlanır bir deneyime dönüştürür.

Sunucu / backend yok: tüm veriler yalnızca cihazda tutulur.

## Uygulamanın iki katmanı

Cepte Staj, ortak bir gün kaydı üzerinde iki ayrı amaca hizmet eder:

| | **Resmi Defter** | **Staj Günlüğüm** (kişisel) |
|---|---|---|
| Ne için | Kağıda geçirilecek, amire imzalatılacak metin | Kendin için; stajın anısı |
| İçerik | Gün konusu, yapılan işler, kullanılan araçlar, öğrenilenler | Ruh hali, günün olayı, mentor sözleri, küçük zaferler, fotoğraflar, rozetler |
| PDF çıktısına girer mi | Evet | **Hayır — asla** |

Bu ayrım bir ayar değil, **mimari bir kural**: PDF dışa aktarma sorgusu
(`lib/core/pdf_export.dart`) yalnızca resmi alanları (`topic`, `body`,
`learned`, `checkIn`/`checkOut` ve `includeInExport = true` işaretli
fotoğrafları) okur; ruh hali, günün olayı, günlük notu, şarkı gibi kişisel
alanlara hiçbir zaman erişmez.

## Ekranlar

- **Açılış (`splash`)** — logo / wordmark, kayıtlı veriyi yükler
- **Onboarding** — staj adı/şirket, süre, başlangıç tarihi, çalışma
  günleri, tatil hariç tutma, günlük kelime hedefi ve hatırlatma saati
- **Bugün (`home`)** — kalan iş günü ilerleme halkası, seri (streak),
  eksik gün uyarısı, hızlı sayaç çipleri (kahve, hata, soru vb.)
- **Takvim (`calendar`)** — aylık, renk kodlu heatmap: dolu / eksik /
  tatil / hafta sonu / kağıda geçirilmiş / bugün
- **Gün Detayı (`day_detail`)** — bir güne ait üç sekme:
  - **Defter** — konu, yapılan işler, giriş/çıkış saati, etiketler,
    kelime + tahmini satır sayacı, otomatik kayıt
  - **Fotoğraf** — galeri/kamera ile ekleme, açıklama, dışa aktarıma
    dahil etme işareti
  - **Günlüğüm** — 5'li ruh hali ölçeği + sebep etiketleri + yoğunluk,
    kategorili "Günün Olayı", "Günün Zaferi", mentor sözü, günün şarkısı
- **Kağıda Geçirme Modu (`paper_mode`)** — büyük punto, paragraf paragraf
  "yazdım ✓" takibi, kalan satır sayısı, ekran uyanık kalır (wakelock)
- **Günlüğüm (`journal`)** — kişisel katmanın özet ekranı: ruh hali
  grafiği, Staj Bingo kartı, rozetler ve seri, mentor sözlüğü
- **Staj Wrapped (`wrapped`)** — staj sonu için kaydırmalı, Spotify
  Wrapped tarzı özet kartları
- **Ayarlar (`settings`)** — staj bilgilerini düzenleme, tema (açık/koyu),
  yazı boyutu, kişisel sekme için PIN kilidi, bildirim saati, yedekle/geri
  yükle, "Demo verisini sıfırla"
- **PIN Kilit (`pin_lock`)** — kişisel katmanı ayrıca korumak için
  isteğe bağlı kilit ekranı

## Ayrıştırıcı özellikler

- **Kağıda Geçirme Modu** — "not tutma"yı değil, "notu deftere geçirme"
  anını çözer: büyük punto, defter satır aralığına yakın tahmini satır
  sayısı, paragraf paragraf ilerleme ve ekranın kararmaması.
- **Sızdırmaz iki katman** — kişisel veriler (ruh hali, günün olayı,
  fotoğraflar vb.) kod seviyesinde dışa aktarma akışına hiç girmez; bu bir
  kullanıcı ayarı değil, `PdfExportService` düzeyinde uygulanan bir
  kısıtlamadır.
- **Staj Bingo, rozetler ve seri** — `lib/core/achievements.dart`'taki saf
  (yan etkisiz) rozet motoru her kayıttan sonra çalışır: İlk Gün, 7 Gün
  Seri, Yarı Yol, 1000 Kelime, İlk Fotoğraf, Bingo Satırı, Hiç Gün
  Kaçırmadın, Gece Yazarı, Erken Kuş.
- **İş günü hesaplayıcı** — `lib/core/workday_calculator.dart`, Türkiye
  resmi tatillerini (`lib/core/holidays.dart`) ve seçilen çalışma günlerini
  hesaba katarak kalan/geçmiş iş günlerini, ilerleme yüzdesini ve tahmini
  bitiş tarihini hesaplar. Birim testli (`test/workday_calculator_test.dart`).

## Design tokens

Renkler, tipografi (`google_fonts` ile Plus Jakarta Sans + Inter), boşluk
ve köşe yarıçapı değerleri `lib/theme/` altında tanımlıdır. Nötr
(neredeyse beyaz/siyah) bir taban üzerine tek bir vurgu rengi kullanılır:
resmi defter tarafı ink teal (`#0C6B66`), kişisel günlük tarafı ise daha
sakin bir terra/kil tonu (`#A8592E`) ile ayırt edilir. Kartlar kenarlık
yerine zemin tonu farkıyla ayrışır; açık ve koyu tema ikisi de desteklenir.

## Mimari ve veri modeli

- **State yönetimi:** `provider` ile tek bir `ChangeNotifier`
  (`lib/data/app_state.dart`) — tüm ekranlar bu tek kaynağı okur/yazar.
- **Kalıcılık:** Backend/SQLite yok; `lib/core/local_store.dart` tüm
  uygulama durumunu tek bir JSON blob olarak `shared_preferences` içine
  yazar. Uygulama arka plana alındığında bekleyen değişiklikler hemen
  diske yazılır (debounce + lifecycle flush).
- **Veri modelleri:** `lib/models/models.dart` içinde `Internship`,
  `DayEntry` (resmi + kişisel alanlar aynı kayıtta ama ayrı işlevlerde),
  `DayPhoto`, `QuickCounter`, `MentorQuote`, `BingoTask`, `AppBadge`.
- **PDF dışa aktarma:** `lib/core/pdf_export.dart`, yalnızca resmi
  alanları okuyup Türkçe karakter destekli (Roboto, `assets/fonts/`) bir
  "Resmi Defter" PDF'i üretir ve `share_plus` ile paylaşır.
- **Yedekleme:** `lib/core/backup_service.dart`, kişisel katman dahil tüm
  durumu bir `.json` dosyası olarak dışa aktarır/geri yükler — bu, dışa
  aktarma PDF'inden farklı olarak kullanıcının kendisi için bir yedektir.
- **Bildirimler:** `lib/core/notification_service.dart`,
  `flutter_local_notifications` + `timezone` ile günlük hatırlatmayı
  zamanlar.
- **PIN kilidi:** `lib/core/pin.dart`, kişisel sekme için `crypto` (SHA-256)
  ile tuzlanmış PIN doğrulaması yapar.

### Klasör yapısı

```
lib/
  main.dart                 # Uygulama girişi, tema + Provider kurulumu
  core/                      # Backend'siz iş mantığı: iş günü hesabı,
                              # rozetler, PDF, yedekleme, bildirim, PIN
  data/app_state.dart        # Tek ChangeNotifier — uygulamanın tüm durumu
  models/models.dart         # Veri modelleri (JSON serileştirme dahil)
  screens/                   # Her ekran kendi klasöründe
  features/onboarding/       # Onboarding akışı
  theme/                     # Renkler, tipografi, boşluk, tema
  widgets/                   # Paylaşılan bileşenler (buton, ilerleme
                              # halkası, çizgili kağıt arka planı, vb.)
```

## Çalıştırma

Tüm ekranlar `lib/data/app_state.dart` üzerinden yönetilen tek bir durumu
kullanır; backend gerekmez. Demo verisini istediğin an Ayarlar →
**"Demo verisini sıfırla"** ile başa döndürebilirsin.

```bash
flutter pub get
flutter run
```

Testleri ve statik analizi çalıştırmak için:

```bash
flutter test
flutter analyze
```

`test/` altında iş günü hesaplayıcı (`workday_calculator_test.dart`) ve
PDF dışa aktarma (`pdf_export_test.dart`) için birim testleri, ayrıca bir
widget testi bulunur.

## Gizlilik

Tüm veriler yalnızca cihazda saklanır, hiçbir sunucuya gönderilmez.
Kişisel katman (Günlüğüm) PDF dışa aktarımına asla dahil edilmez ve
isteğe bağlı olarak ayrı bir PIN ile kilitlenebilir.
