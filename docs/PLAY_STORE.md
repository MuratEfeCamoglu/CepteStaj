# Google Play'de yayınlama rehberi

Bu dosya Cepte Staj'ı Play Console'a yüklemek için gereken her şeyi tek yerde toplar: imzalama, derleme, mağaza metinleri, görseller ve Play Console formlarının cevapları.

---

## 1. Yükleme anahtarı (bir kere yapılır)

Play Console debug anahtarıyla imzalanmış paketi **reddeder**. Kendi anahtarını oluştur:

```powershell
keytool -genkey -v -keystore $env:USERPROFILE\upload-keystore.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

> `keytool` Android Studio ile gelir: `"C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe"`

Sonra `android/key.properties` dosyasını oluştur (git'e **girmez**, `.gitignore`'da):

```properties
storePassword=<anahtar deposu şifresi>
keyPassword=<anahtar şifresi>
keyAlias=upload
storeFile=C:/Users/Efe/upload-keystore.jks
```

⚠️ `.jks` dosyasını ve şifreleri **güvenli bir yerde yedekle** (ör. şifre yöneticisi). Kaybedersen güncelleme yükleyemezsin (Play App Signing açıksa Google'dan sıfırlama isteyebilirsin ama zahmetli).

## 2. Derleme

```powershell
flutter clean
flutter build appbundle --release
```

Çıktı: `build/app/outputs/bundle/release/app-release.aab` → Play Console'a bu yüklenir.

Her yeni sürümde `pubspec.yaml`'daki `version: 1.0.0+1` satırının **`+` sonrasındaki sayıyı artır** (1 → 2 → 3…). Play aynı versionCode'u ikinci kez kabul etmez. Ayarlar → Hakkında'daki sürüm numarası buradan otomatik okunur.

## 3. Mağaza girişi (Store listing)

**Uygulama adı** (en fazla 30 karakter):
> Cepte Staj — Staj Defteri

**Kısa açıklama** (en fazla 80 karakter):
> Staj defterini gün içinde not al, akşam kağıda kolayca geçir. Tamamen çevrimdışı.

**Tam açıklama** (en fazla 4000 karakter):

```
Staj defterini elle yazmak zorunda mısın? Cepte Staj gün içinde hızlıca not almanı, akşam da bu notları kağıda rahatça geçirmeni sağlar — ve stajını sadece bir ödev değil, hatırlanır bir deneyim haline getirir.

📒 RESMİ DEFTER
• Her iş günü için konu, yapılan işler ve öğrendiklerin
• Kelime sayacı ve hedef: "84 / 120 kelime · ~11 satır"
• Otomatik kaydetme — telefonu aceleyle kapatsan bile hiçbir şey kaybolmaz
• Giriş-çıkış saatleri
• Günü WhatsApp'tan tek dokunuşla gönder
• Defterini PDF ya da Word (.docx) olarak indir veya paylaş

✍️ KAĞIDA GEÇİRME MODU
Büyük punto, defter satır aralığı, paragraf paragraf "yazdım ✓" işareti ve kalan satır sayısı. Yazarken ekran kapanmaz. Notlarını deftere geçirmenin en rahat yolu.

📅 TAKVİM VE SAYAÇ
• Staj süreni, başlangıç tarihini ve çalışma günlerini gir; bitiş tarihi otomatik hesaplanır
• Resmi tatiller otomatik hariç tutulur
• "5 iş günü kaldı" sayacı ve ilerleme halkası
• Renkli takvim: dolu, eksik, tatil ve kağıda yazılan günler bir bakışta
• Boş kalan günler için nazik uyarı

🌈 STAJ GÜNLÜĞÜM (sadece senin için)
• Ruh hali, sebep etiketleri ve günün yoğunluğu — 3 dokunuşta
• Günün Olayı: en komik, en absürt ya da en trajik an
• Günün küçük zaferi
• Mentor sözlüğü, çay/kahve sayaçları, Staj Bingo ve rozetler
• Zaman Kapsülü: staj başında beklentin ve korkun, sonunda "gerçekte ne oldu?"
• Staj Wrapped: staj bitince paylaşılabilir özet

🔒 GİZLİLİK ÖNCE GELİR
• Hesap yok, sunucu yok, reklam yok — uygulama internete bile bağlanmaz
• Tüm verilerin yalnızca telefonunda
• Günlüğüm verileri Resmi Defter PDF'ine asla girmez
• Günlüğüm sekmesini PIN ile kilitleyebilirsin
• Fotoğraflar dahil yedekle / yeni telefona geri yükle

Lise ve üniversite stajyerleri, zorunlu staj yapan herkes için.
```

**Kategori:** Eğitim (Education) — alternatif: Verimlilik (Productivity)
**Etiketler:** staj, staj defteri, günlük, not, öğrenci

**İletişim e-postası:** camoglumuratefe@gmail.com
**Gizlilik politikası URL'si:**
`https://github.com/MuratEfeCamoglu/CepteStaj/blob/main/docs/PRIVACY_POLICY.md`
(Repo herkese açık olmalı. Özel tutacaksan politikayı GitHub Pages, Google Sites veya Notion'da herkese açık bir sayfaya koy.)

### Görseller (`docs/play-store/` içinde hazır)

| Play alanı | Dosya | Ölçü |
|---|---|---|
| Uygulama simgesi | `icon-512.png` | 512×512 |
| Öne çıkan grafik | `feature-graphic-1024x500.png` | 1024×500 |
| Telefon ekran görüntüleri (2–8 adet) | `screenshots/01-…08-….png` | 1080×2160 |

> Mevcut ekran görüntüleri eski yazı tipiyle (Roboto) alınmış. Uygulama artık Inter / Plus Jakarta Sans kullanıyor; yayından önce gerçek cihazda/emülatörde yenilerini çekip aynı klasöre koyman önerilir. Play kuralı: uzun kenar kısa kenarın en fazla 2 katı olmalı.

## 4. Play Console formları — hazır cevaplar

### Uygulama içeriği → Gizlilik politikası
Yukarıdaki URL.

### Reklamlar
**Hayır**, uygulama reklam içermiyor.

### Uygulama erişimi
**Tüm işlevler özel erişim gerektirmeden kullanılabilir.** (Giriş/hesap yok. PIN kilidi kullanıcının isteğe bağlı açtığı bir özellik.)

### İçerik derecelendirmesi (IARC anketi)
- Kategori: **Yardımcı program, Verimlilik, İletişim veya Diğer**
- Şiddet, cinsellik, küfür, uyuşturucu, kumar: **Hayır**
- Kullanıcılar birbirleriyle iletişim kurabiliyor mu / içerik paylaşabiliyor mu: **Hayır** (paylaşım yalnızca sistemin paylaş menüsüyle, kullanıcının kendi dosyası)
- Konum paylaşımı: **Hayır** · Dijital ürün satın alma: **Hayır**
→ Beklenen sonuç: **Herkes / PEGI 3**

### Hedef kitle ve içerik
- Hedef yaş grupları: **16–17** ve **18 ve üzeri** (lise stajyerleri + üniversite).
  13 yaş altını **seçme** — seçersen "Aileler" politikası devreye girer ve ek gereklilikler gelir.
- Uygulama çocuklara hitap ediyor mu: **Hayır**

### Veri güvenliği (Data safety)
- Uygulamanız gerekli kullanıcı veri türlerinden herhangi birini toplıyor veya paylaşıyor mu? → **Hayır**
  - Gerekçe: Uygulamanın internet izni yok; tüm veriler cihazda kalıyor. Kullanıcının kendi başlattığı paylaşım (PDF/yedek dosyasını paylaş menüsüyle göndermek) Google'ın tanımına göre "toplama" sayılmaz.
- Sonuç kartında **"Veri toplanmıyor" / "Üçüncü taraflarla veri paylaşılmıyor"** görünür.

### Hükümet uygulaması / Finansal özellikler / Sağlık
Hepsi **Hayır**.

### İzin beyanları
Manifest yalnızca `POST_NOTIFICATIONS`, `RECEIVE_BOOT_COMPLETED` ve `VIBRATE` istiyor (Kağıda Geçirme Modu'nda ekranı açık tutmak izin gerektirmez); hiçbiri için özel beyan formu gerekmez. (Kesin alarm, konum, SMS, tüm dosyalara erişim vb. hassas izin **yok**.)

## 5. Yayın akışı

1. Play Console → **Uygulama oluştur** (varsayılan dil: Türkçe – tr-TR, Uygulama, Ücretsiz).
2. Yukarıdaki "Uygulama içeriği" formlarını doldur.
3. **Test → Dahili test** kanalına ilk `.aab`'yi yükle, kendi hesabınla telefona kur, uçtan uca dene.
4. **Yeni kişisel geliştirici hesabıysan:** üretime çıkmadan önce **kapalı test** zorunludur — en az **12 test kullanıcısı**, **14 gün** boyunca kesintisiz katılmalı. Arkadaşlarını/sınıf arkadaşlarını Google Grubu ile ekle. (Bu kural 13 Kasım 2023'ten sonra açılan kişisel hesaplar için geçerli.)
5. Kapalı test bitince **Üretim** → sürüm oluştur → incelemeye gönder (ilk inceleme birkaç gün sürebilir).

## 6. Yayın öncesi son kontrol listesi

- [ ] `android/key.properties` var, `flutter build appbundle --release` hatasız
- [ ] `pubspec.yaml` versionCode artırıldı
- [ ] Gerçek bir Android telefonda release sürümü kurulup denendi:
  - [ ] Onboarding → tarih seçici Türkçe, hafta Pazartesi'den başlıyor
  - [ ] Hatırlatıcı saati gelince bildirim geliyor, durum çubuğunda simge beyaz silüet olarak görünüyor
  - [ ] Kamera ve galeriden fotoğraf ekleme çalışıyor
  - [ ] Resmi Defter PDF oluşuyor, Türkçe karakterler (ğ ş ı İ) doğru
  - [ ] Gün detayı → Paylaş: WhatsApp açılıyor; PDF ve Word "indir" ile İndirilenler'e kaydediliyor, Word dosyası telefonda/bilgisayarda açılıyor
  - [ ] Yedekle → (uygulamayı silip kur) → Geri yükle: kayıtlar **ve fotoğraflar** geri geliyor
  - [ ] Kağıda Geçirme Modu açıkken ekran kararmıyor
  - [ ] Açık ve koyu temada durum çubuğu simgeleri okunuyor
- [ ] Gizlilik politikası URL'si tarayıcıda giriş yapmadan açılıyor
- [ ] Yeni ekran görüntüleri çekildi (isteğe bağlı ama önerilir)
