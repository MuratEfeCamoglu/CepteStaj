**Cepte Staj --- Ürün Planı ve Yol Haritası**

**Tek satırlık tanım:** Staj defterini elle yazmak zorunda olan öğrenciler için, gün içinde hızlıca not alıp akşam kağıda geçirmesini kolaylaştıran --- ve stajı sadece bir ödev değil, hatırlanır bir deneyim haline getiren offline-first Flutter uygulaması.

**Platform:** Android öncelikli (Flutter) → sonra iOS\
**Geliştirici:** Tek kişi, bütçe yok → backend yok, tamamen cihazda (SQLite)\
**Hedef kitle:** Lise/üniversite stajyerleri, zorunlu staj yapanlar

**1. Konumlandırma: Uygulamanın iki yarısı**

Uygulama tek işe yarayan bir araç değil, **iki katmanlı** bir ürün. Bu ikilik hem konumlandırmanın hem de arayüzün temeli.

  ------------------------ ------------------------------------------------------------- ------------------------------------------------------------------------------
                           **Resmi Defter**                                              **Staj Günlüğüm** (kişisel)

  Ne için                  Kağıda geçirilecek, amire imzalatılacak metin                 Kişinin kendisi için; staj deneyiminin anısı

  İçerik                   Gün konusu, yapılan işler, kullanılan araçlar, öğrenilenler   Ruh hali, günün olayı, mentor sözleri, küçük zaferler, fotoğraflar, rozetler

  Ton / tasarım            Sade, kurumsal, okunur                                        Renkli, oyunbaz, emoji ve animasyonlu

  PDF çıktısına girer mi   **Evet**                                                      **Hayır --- asla** (ayrı, kişisel çıktısı var)

  Doldurma süresi          1--2 dakika yazı                                              15 saniye, çoğu tek dokunuş
  ------------------------ ------------------------------------------------------------- ------------------------------------------------------------------------------

**Ayrıştırıcı özellikler**

1.  **Kağıda Geçirme Modu** --- piyasada not tutan uygulama çok, \"notu deftere geçirme\" anını çözen yok: büyük punto, defter satır aralığı, paragraf paragraf \"yazdım ✓\", kalan satır sayısı, ekran açık kalır (wakelock). Ana tanıtım vaadi bu.

2.  **Sızdırmaz iki katman** --- şirket hakkındaki yorumlar, ruh hali ve fotoğraflar teknik olarak dışa aktarma akışına hiç girmez. Bu bir ayar değil, **mimari kural**.

3.  **Staj Wrapped** --- staj bitiminde otomatik, paylaşılabilir özet. Organik yayılma buradan gelir.

**2. Senin listen + eksik gördüğüm noktalar (Resmi Defter tarafı)**

**Staj kaç gün + başlangıç/bitiş tarihi + takvim**

-   Sadece \"kaç gün\" yetmez: staj defterleri **iş günü** sayar.

-   Onboarding\'de sorulacaklar: staj süresi (gün), başlangıç tarihi, **çalışılan günler** (Pzt--Cum / Pzt--Cmt / özel).

-   **Resmi tatiller** otomatik hariç tutulur (TR tatilleri gömülü tablo, dini bayramlar yıl bazlı). Kullanıcı ayrıca \"izinli / rapor\" günü işaretleyebilir.

-   Bitiş tarihi bu bilgilerden **otomatik hesaplanır** → \"tahmini bitiş: 12 Eylül\", düzenlenebilir.

-   Takvim: table_calendar ile **renk kodlu heatmap** --- dolu (yeşil), eksik (kırmızı), tatil (gri), hafta sonu (soluk), bugün (vurgulu), kağıda yazıldı (ayrı işaret).

**\"Stajın bitmesine 5 gün kaldı\"**

-   İki sayaç: **kalan iş günü** ve kalan takvim günü.

-   İlerleme halkası: 14 / 20 gün · %70.

-   Aynı kartta **eksik gün uyarısı**: \"3 gün boş\" → tıkla, eksik günler listesi.

-   İleride ana ekran widget\'ı (home_widget).

**Her gün için doldurma sayfası + kelime sayacı**

-   Kelime sayacı **hedefli**: 84 / 120 + ince progress bar (hedef ayarlardan).

-   **Tahmini satır sayısı** göster (\"\~11 satır\") --- kağıda geçirirken en çok merak edilen şey.

-   Otomatik kaydetme (debounce 2 sn + focus kaybı). Stajyer telefonu aceleyle kapatır.

-   **Dünden kopyala** --- çoğu gün işler benzer.

-   **Hazır ifade kütüphanesi (snippet)** --- \"Ekibin daily toplantısına katıldım.\" gibi cümleler tek dokunuşla eklenir; kullanıcı kendi cümlesini kaydedebilir.

-   **Sesle not** (speech_to_text, cihaz üstünde, ücretsiz).

-   Alanlar: gün konusu, yapılan işler, kullanılan araç/teknoloji (etiket), giriş-çıkış saati (ops.), öğrendiklerim.

**Gün başlığı = stajın konusu**

Serbest metin + **son kullanılan başlıklardan öneri** (autocomplete).

**Resim koyma sayfası**

-   Galeri/kamera (image_picker), günde çok resim, dosya uygulama dizinine kopyalanır (galeriden silinirse kaybolmasın).

-   **Fotoğraftan metin (OCR)** --- google_mlkit_text_recognition, offline ve ücretsiz: tahtadaki/ekrandaki yazıyı nota dönüştür.

-   Her resme caption.

-   Resimler **varsayılan olarak kişisel katmanda**. Deftere ek olarak kullanılacaksa kullanıcı açıkça işaretler.

**3. Kişisel Katman: \"Staj Günlüğüm\"**

Buranın tek kuralı: **doldurmak iş gibi hissettirmeyecek.** Neredeyse her şey dokunmayla, en fazla tek cümleyle geçilir. Yazma zorunluluğu yok; boş bırakılan alan asla suçlayıcı bir uyarı üretmez.

**3.1 Ruh hali --- tek emojiden fazlası**

-   5\'li ölçek: 😫 😕 😐 🙂 🤩 (1--5 değer).

-   Hemen altında **sebep etiketleri** (çoktan seçmeli çipler, hepsi opsiyonel):\
    yoğun · sıkıldım · yeni şey öğrendim · mentor iyiydi · kimse iş vermedi · ekip güzeldi · yorgunum · gurur duydum · kaos · trafik/yol

-   İkinci eksen: **yoğunluk** (boş / normal / yoğun). Ruh hali + yoğunluk birlikte anlamlı bir harita çıkarır (\"yoğun ama mutlu günler\" vs \"boş ve sıkıcı günler\").

-   Bu üç şey toplam **3 dokunuş** --- günlük doldurmanın çekirdeği bu.

**3.2 Günün Olayı (senin \"trajik olay\" fikrinin büyütülmüş hali)**

-   İsim uygulamada **\"Günün Olayı\"**, alt yazı: *\"Bugün başına gelen en absürt, komik ya da trajik şey.\"*

-   Serbest metin **+ kategori etiketi**: 🤦 utanç · 😂 komik · 😱 panik · 💀 felaket · 🏆 gurur · 🤔 tuhaf

-   Kategori, staj sonu özetinde gruplanmayı sağlar: \"3 panik, 7 komik, 1 felaket.\"

-   Yazmak istemeyene çıkış kapısı: sadece kategoriyi seçip geçebilir.

**3.3 Günün küçük zaferi**

Tek satır: *\"Bugün iyi giden bir şey\"*. Olumsuz günlerde dengeleyici; staj sonunda 20 satırlık gurur listesi oluşur. Psikolojik olarak uygulamayı sevdiren detay bu.

**3.4 Mentor Sözlüğü**

Mentorun/ustanın söylediği unutulmaz laflar koleksiyonu --- kim söyledi + söz. Staj sonunda alıntı kartları olarak çıkar. Uygulamanın en çok paylaşılacak içeriği muhtemelen bu olur.

**3.5 Sayaçlar**

Gün içinde tek dokunuşla artan küçük sayaçlar: ☕ kahve/çay, 🍽 öğle yemeği nerede, 🐛 çözülen hata, 🙋 sorduğum soru. Kullanıcı kendi sayacını da ekleyebilir. Staj sonunda: *\"42 bardak çay, 18 soru, 9 hata.\"*

**3.6 Staj Bingo --- görev kartları**

5x5 (ya da daha küçük) bingo kartı, staj başında verilir. Örnek kareler:

-   İlk kez toplantıda konuştum

-   Bir şeyi bozdum ve düzelttim

-   Ekiple öğle yemeğine çıktım

-   Mentoruma \"anlamadım\" dedim

-   Kendi başıma bir görevi bitirdim

-   Bir kere geç kaldım

-   Birine bir şey öğrettim

-   Production\'a bir şey gönderdim

İşaretlendikçe konfeti (confetti), satır tamamlanınca rozet. Kullanıcı kendi karelerini ekleyebilir/kartı yenileyebilir. **Bu özellik stajın \"oyunlaşmış\" tarafı** --- özellikle can sıkıcı stajlarda kullanıcıyı uygulamaya bağlar.

**3.7 Rozetler ve seri**

-   Rozetler: İlk Gün · 7 Gün Seri · Yarı Yol · 1000 Kelime · İlk Fotoğraf · Bingo Satırı · Hiç Gün Kaçırmadın · Gece Yazarı (23:00\'ten sonra doldurdun) · Erken Kuş

-   Kazanınca küçük animasyon + bildirim. Rozet ekranı staj karnesine beslenir.

-   **Seri (streak)** ateş ikonuyla; ama bozulunca ceza dili kullanma (\"seri sıfırlandı\" yerine \"yeni seri başlıyor\").

**3.8 Gün fotoğrafı → kolaj**

Günde bir \"selfie / masamdan görünüm\" alanı. Staj sonunda **kolaj / timelapse şeridi** üretilir (image paketiyle yerel kompozisyon, sunucu gerekmez).

**3.9 Bugünün şarkısı**

Tek satır serbest metin. Staj sonunda çalma listesi olarak listelenir. Sıfır maliyet, yüksek nostalji.

**3.10 Staj kadrosu**

Mentor, ekip arkadaşları, diğer stajyerler --- isim + rol + kısa not. Staj sonunda \"bu insanlarla çalıştın\" kartı ve *\"LinkedIn\'de eklemeyi unutma\"* hatırlatması.

**3.11 Zaman Kapsülü**

Staj **başında** iki soru: *\"Bu stajdan ne bekliyorsun?\"* ve *\"Neyden korkuyorsun?\"* → kilitlenir, staj **bitince** açılır ve yanına *\"gerçekte ne oldu?\"* yazılır. Duygusal olarak en güçlü özellik; maliyeti neredeyse sıfır.

**3.12 Haftalık özet**

Her Pazar akşamı bildirim + kart: *\"Bu hafta ortalama ruh halin 3.8 (geçen hafta 3.1). En iyi günün Çarşamba. 2 rozet kazandın.\"*

**3.13 Staj Wrapped --- final özet**

Spotify Wrapped mantığında kaydırmalı kart serisi:\
Toplam gün ve kelime → Ruh hali eğrisi → En iyi ve en zor günün → En çok kullandığın etiketler → Günün Olayı kategorileri → Mentor sözlerinden 3 alıntı → Sayaçlar (42 çay) → Rozetler → Bingo kartın → Fotoğraf kolajı → Zaman kapsülü: beklentin vs gerçek

Son kart **paylaşılabilir tek görsel** olarak dışa aktarılır (widget\'ı görsele render et + share_plus). Kullanıcı neyin görsele gireceğini seçer --- mentor sözleri ve şirket adı varsayılan olarak **kapalı**.

**3.14 Gizlilik: mimari kural**

-   Kişisel katman verisi **dışa aktarma sorgusuna hiç dahil edilmez**. Export fonksiyonu day_entries.body, title, learned ve include_in_export=true fotoğrafları okur; kişisel alanlara erişimi yoktur. Yanlışlıkla sızma ihtimalini kod seviyesinde kaldır.

-   İki ayrı çıktı: **\"Resmi Defter PDF\"** (paylaşmak için) ve **\"Anı Kitabı PDF\"** (yalnızca kendisi için, kişisel katmanı içerir, paylaşım ekranında ayrı uyarı).

-   Kişisel sekme **PIN/biyometrik ile ayrıca kilitlenebilir** (resmi taraf açık kalabilir).

-   Onboarding\'de tek ekranlık şeffaflık notu: *\"Verileriniz yalnızca telefonunuzda. Gizli şirket bilgisi yazmayın.\"*

**4. Ekran haritası**

Onboarding\
├─ 1. Hoş geldin + gizlilik notu\
├─ 2. Staj bilgileri: ad/şirket, süre (gün), başlangıç tarihi\
├─ 3. Çalışma günleri + tatil hariç tutma → tahmini bitiş\
├─ 4. Günlük kelime hedefi + hatırlatma saati\
└─ 5. Zaman Kapsülü: beklentin ve korkun\
\
Ana Sekmeler\
├─ Bugün → sayaç kartı · seri · bugünü doldur kısayolu · sayaç butonları\
├─ Takvim → aylık heatmap → gün detayı\
├─ Günlüğüm → ruh hali grafiği · bingo · rozetler · mentor sözlüğü · kadro · kolaj\
└─ Ayarlar → profiller, hedefler, bildirim, kilit, yedek, dışa aktar\
\
Gün Detayı (sekmeli)\
├─ Defter → konu, yapılan işler, etiket, kelime+satır sayacı, snippet, sesle not\
├─ Fotoğraf → grid, caption, OCR\
└─ Günlüğüm → ruh hali + sebep çipleri + yoğunluk · Günün Olayı (kategorili)\
· Günün Zaferi · mentor sözü ekle · bugünün şarkısı · gün fotoğrafı\
\[Üst bar\] Kağıda Geçir · PDF · \"yazıldı ✓\" · \"imzalandı ✓\"\
\
Kağıda Geçirme Modu (tam ekran)\
büyük punto · defter satırı · paragraf paragraf ✓ · kalan satır · ekran açık\
\
Staj Wrapped → kaydırmalı kartlar → paylaşılabilir görsel

**5. Teknik plan**

**Yığın**

  ----------------------- ----------------------- -------------------------------------------------
  Katman                  Seçim                   Gerekçe

  Framework               Flutter 3.x             Senin tercihin, tek kod tabanı

  State                   **Riverpod**            Tek geliştirici için sade, test edilebilir

  Yönlendirme             go_router               Derin bağlantı, widget\'tan açılış

  Veritabanı              **Drift** (sqflite)     Tipli sorgu + migration; ilişkisel yapıya uygun

  Ayarlar                 shared_preferences      Basit anahtar-değer

  Dosyalar                path_provider           Resimler uygulama klasöründe, yol DB\'de
  ----------------------- ----------------------- -------------------------------------------------

**Paketler**

table_calendar, image_picker, google_mlkit_text_recognition, speech_to_text, flutter_local_notifications, timezone, pdf, printing, share_plus, local_auth, fl_chart, home_widget, wakelock_plus, confetti, image (kolaj), screenshot (Wrapped kartını görsele çevirmek için), intl, archive, permission_handler.

**Veri modeli (Drift)**

internships\
id, name, company, department, supervisor,\
total_days, start_date, end_date,\
work_days_mask, exclude_holidays,\
daily_word_goal, words_per_line, is_active\
\
day_entries \-- RESMİ + KİŞİSEL aynı satırda, ama ayrı alanlar\
id, internship_id, date (UNIQUE with internship_id),\
\-- resmi\
title, body, word_count, learned, check_in, check_out,\
status (draft\|done\|skipped), copied_to_paper, signed,\
\-- kişisel\
mood (1..5), workload (1..3),\
incident, incident_category,\
daily_win, song, day_photo_path,\
created_at, updated_at\
\
mood_reasons day_entry_id, reason_key \-- çoka-çok, çip etiketleri\
photos id, day_entry_id, file_path, caption, include_in_export, ocr_text\
tags / day_tags id, internship_id, name, color / day_entry_id, tag_id\
snippets id, internship_id, text, use_count, is_default\
quotes id, internship_id, day_entry_id?, person, text, created_at\
counters id, internship_id, key, label, emoji \-- kahve, hata\...\
counter_logs id, counter_id, date, amount\
bingo_tasks id, internship_id, text, is_done, done_at, position\
achievements id, internship_id, key, earned_at\
people id, internship_id, name, role, note\
capsule id, internship_id, expectation, fear, reflection, opened_at\
holidays id, date, name, country \-- gömülü seed

Not: word_count\'u türetilmiş olsa da sakla --- grafikler tek sorguda çalışsın.

**Klasör yapısı (feature-first)**

lib/\
main.dart\
app/ router · theme (resmi + kişisel tema aksanı) · l10n\
core/ db/ (drift) · utils/ (workday, wordcount) · widgets/\
features/\
onboarding/ internship/ today/ day_entry/ photos/ calendar/\
journal/ \-- mood, incident, quotes, counters, bingo, achievements, people\
paper_mode/ export/ stats/ wrapped/ settings/ backup/

**Dikkat edilecek detaylar**

-   **WorkdayCalculator**: iş günü sayımı + tatil hariç tutma tek yerde, **birim testli**. Buradaki hata tüm sayaçları bozar.

-   **Export sorgusu kişisel alanları hiç seçmesin** --- 3.14\'teki kuralı repository seviyesinde uygula ve buna da test yaz.

-   Rozet motoru: her kayıt sonrası çalışan saf fonksiyon (List\<Achievement\> evaluate(state)), yan etkisiz → kolay test.

-   Bildirim zamanlaması için timezone şart (Android yerel saat sorunları).

-   Android 13+ POST_NOTIFICATIONS iznini onboarding\'de nazikçe iste.

-   Kişisel sekmenin teması resmi taraftan görsel olarak **belirgin şekilde farklı** olsun --- kullanıcı hangi katmanda olduğunu bir bakışta anlamalı, bu aynı zamanda gizlilik güveni verir.

**6. Yol haritası**

**MVP (v1.0) --- \~3 hafta**

Bir stajyerin baştan sona kullanabileceği en küçük sürüm.

-   Onboarding + staj kurulumu (süre, tarih, çalışma günleri, tatil hariç)

-   Sayaç + ilerleme kartı, eksik gün uyarısı

-   Takvim heatmap → gün detayı

-   **Defter sekmesi**: konu, metin, kelime + satır sayacı, otomatik kaydetme

-   **Günlüğüm sekmesi (çekirdek)**: ruh hali + sebep çipleri + yoğunluk, Günün Olayı (kategorili), Günün Zaferi

-   Fotoğraf ekleme (caption\'lı)

-   Karanlık mod, TR arayüz

**v1.1 --- kağıt sürümü (\~1 hafta)**

Kağıda Geçirme Modu · \"yazıldı ✓\" takibi · günlük hatırlatma bildirimi · dünden kopyala · snippet kütüphanesi · arama

**v1.2 --- çıktı ve güven (\~1 hafta)**

Resmi Defter PDF (gün / aralık / tümü) + paylaş + yazdır · yedekle/geri yükle (zip) · PIN/biyometrik kilit (kişisel sekme için ayrı kilit)

**v1.3 --- eğlence sürümü (\~1--2 hafta)**

Staj Bingo · rozetler + seri · sayaçlar (çay, hata, soru) · mentor sözlüğü · bugünün şarkısı · haftalık özet bildirimi · ruh hali grafiği (fl_chart)

**v2 --- hatıra sürümü**

**Staj Wrapped** (kaydırmalı kartlar + paylaşılabilir görsel) · Zaman Kapsülü açılışı · gün fotoğrafı kolajı · staj kadrosu · etiket istatistikleri · sesle not · fotoğraftan OCR · çoklu staj profili · Anı Kitabı PDF · ana ekran widget\'ı · amir imza takibi · iOS

**Fikir havuzu**

Okul/bölüm defter şablonları · İngilizce dil desteği · opsiyonel AI yardımcısı (kullanıcının kendi API anahtarıyla kısa notu resmi defter diline çevirme) · isteğe bağlı Google Drive yedeği · bingo kartlarını arkadaşla paylaşma

**7. Ölçüt ve riskler**

**Birincil ölçüt:** doldurulan gün oranı (dolu gün / geçen iş günü). %70 üzeri ise ürün işini yapıyor.\
**İkincil ölçüt:** kişisel katmanın doldurulma oranı --- resmi taraftan yüksekse konumlandırmayı oraya kaydırmayı düşün.

  ------------------------------------------------------------- -----------------------------------------------------------------------------------------------
  Risk                                                          Azaltma

  Kişisel katman \"bir sürü boş alan\" gibi görünür, bunaltır   Varsayılanda sadece ruh hali + Günün Olayı + Zafer görünsün; diğerleri \"+ ekle\" ile açılsın

  Kullanıcı iki gün sonra bırakır                               Bildirim + tek dokunuşla doldurma + seri/rozet + snippet ile süreyi 30 saniyeye indir

  Kapsam şişer, MVP bitmez                                      v1.0 dışındaki her fikir fikir havuzunda kalır, koda girmez

  Kişisel not yanlışlıkla PDF\'e sızar                          Export\'ta kişisel alanlara erişim yok (repository kuralı) + regresyon testi

  Tarih/iş günü hataları                                        WorkdayCalculator birim testleri

  Veri kaybı → kötü yorumlar                                    v1.2 yedekleme + her yazmada otomatik kayıt

  Maliyet                                                       Tek masraf Google Play tek seferlik 25 USD. iOS için Mac + yıllık 99 USD → Android\'le başla
  ------------------------------------------------------------- -----------------------------------------------------------------------------------------------

**8. Sıradaki adım**

1.  WorkdayCalculator + Drift şeması (uygulamanın kalbi, 1 akşam).

2.  Onboarding → Bugün → Gün Detayı (Defter + Günlüğüm sekmeleri) akışını uçtan uca çalıştır; arayüz kaba olsun.

3.  Kendi ya da bir arkadaşının stajını 1 hafta bu uygulamayla doldur --- eksikler kendiliğinden çıkar.

4.  Sonra Kağıda Geçirme Modu → PDF → eğlence katmanı.
