<p align="center">
  <img src="assets/icon/app_icon.png" width="112" alt="Cepte Staj ikonu">
</p>

<h1 align="center">Cepte Staj</h1>

<p align="center">
  Staj defterini elle yazmak zorunda olan öğrenciler için: gün içinde hızlıca not al,
  akşam kağıda geçir, stajını da hatırlanır bir deneyime dönüştür.
</p>

<p align="center">
  <img src="docs/screenshots/bugun.png" width="240" alt="Bugün ekranı">
  &nbsp;
  <img src="docs/screenshots/defter.png" width="240" alt="Defter ekranı">
  &nbsp;
  <img src="docs/screenshots/gunlugum.png" width="240" alt="Günlüğüm ekranı">
</p>

Cepte Staj, offline çalışan bir Flutter uygulamasıdır. Hesap açmak gerekmez, sunucu yoktur;
tüm veriler yalnızca telefonda saklanır. Uygulamanın iki katmanı vardır:

| | **Resmi Defter** | **Staj Günlüğüm** |
|---|---|---|
| Ne için | Kağıda geçirilecek, amire imzalatılacak metin | Yalnızca senin için, stajın anısı |
| İçerik | Gün konusu, yapılan işler, giriş/çıkış saati, öğrendiklerin | Ruh hali, Günün Olayı, küçük zafer, şarkı, mentor sözleri |
| PDF'e girer mi | Evet | **Hayır, asla** |

## Ekranlar

### Bugün
Kalan iş günü halkası, doldurulan gün oranı, boş kalan günler için uyarı, seri takibi ve
tek dokunuşla artan hızlı sayaçlar (☕ kahve, 🐛 çözülen hata, 🙋 sorulan soru).

### Takvim
Aylık görünümde her günün durumu bir bakışta görülür: dolu, eksik, tatil ve kağıda yazıldı ✓.
Resmi tatiller ve hafta sonları iş günü sayımına otomatik olarak dahil edilmez.

<p align="center">
  <img src="docs/screenshots/bugun.png" width="260" alt="Bugün">
  &nbsp;&nbsp;
  <img src="docs/screenshots/takvim.png" width="260" alt="Takvim">
</p>

### Defter
Günün konusu, hazır ifadeler (tek dokunuşla eklenen cümleler), dünden kopyala, giriş/çıkış
saati ve öğrendiklerin. Alttaki sayaç günlük kelime hedefini ve metnin kağıtta **kaç satır**
tutacağını gösterir. Yazdıkların otomatik kaydedilir.

### Kağıda Geçirme Modu
Defter kaydını kağıda geçirirken kullanılan tam ekran mod: büyük punto, defter çizgileri,
kalan satır sayısı ve ayarlanabilir yazı boyutu.

<p align="center">
  <img src="docs/screenshots/defter.png" width="260" alt="Defter">
  &nbsp;&nbsp;
  <img src="docs/screenshots/kagida-gecir.png" width="260" alt="Kağıda Geçirme Modu">
</p>

### Günlüğüm (kişisel)
Doldurması iş gibi hissettirmeyen kişisel katman: 5'li ruh hali, sebep etiketleri ve
iş yoğunluğu, kategorili **Günün Olayı** (🤦 utanç · 😂 komik · 😱 panik · 💀 felaket ·
🏆 gurur · 🤔 tuhaf), günün küçük zaferi ve bugünün şarkısı. Aynı sekmede son 7 günün
ruh hali grafiği, **Staj Bingo**, rozetler, mentor sözlüğü ve Zaman Kapsülü de yer alır.
Bu sekme PIN ile ayrıca kilitlenebilir.

<p align="center">
  <img src="docs/screenshots/gunlugum.png" width="260" alt="Günlüğüm">
  &nbsp;&nbsp;
  <img src="docs/screenshots/gunlugum-2.png" width="260" alt="Bingo, rozetler, mentor sözlüğü">
</p>

### Staj Wrapped ve Ayarlar
Stajının Spotify Wrapped tarzında, kaydırmalı ve paylaşılabilir özeti (Ayarlar'dan açılır). Ayarlar'da
staj tarihleri, kelime hedefi, açık/koyu tema, yazı boyutu, günlük hatırlatıcı, PIN kilidi,
**Resmi Defter PDF** çıktısı ve yedekleme/geri yükleme bulunur.

<p align="center">
  <img src="docs/screenshots/wrapped.png" width="260" alt="Staj Wrapped">
  &nbsp;&nbsp;
  <img src="docs/screenshots/ayarlar.png" width="260" alt="Ayarlar">
</p>

## Gizlilik

Kişisel katman verileri dışa aktarma akışına hiç girmez. Resmi Defter PDF'i yalnızca defter
alanlarını ve deftere eklenmesi açıkça işaretlenmiş fotoğrafları okur. Bu kural bir ayar
değildir; kod seviyesinde uygulanır ve testlerle korunur.

## Geliştirme

Standart bir Flutter projesidir (Android öncelikli).

```bash
flutter pub get
flutter run                  # bağlı cihazda çalıştır
flutter test                 # birim + widget testleri
flutter analyze              # statik analiz
flutter build apk --release  # APK: build/app/outputs/flutter-apk/
```

**Klasör yapısı**

```
lib/
  core/      iş günü hesaplayıcı, tatiller, rozet motoru, PDF, yedek, bildirim, PIN
  data/      AppState: uygulama durumu ve yerel kayıt
  models/    veri modelleri
  screens/   bugün, takvim, gün detayı, kağıda geçir, günlüğüm, wrapped, ayarlar
  theme/     renk, yazı ve boşluk token'ları
  widgets/   ortak bileşenler
test/        WorkdayCalculator, PDF export ve widget testleri
```

Renk, yazı ve boşluk token'ları `lib/theme/` altındadır. Resmi defter tarafının vurgu rengi
mürekkep teal'i (`#0C6B66`), kişisel günlük tarafınınki terra'dır (`#A8592E`).

> README'deki ekran görüntüleri örnek staj verisiyle alınmıştır.
