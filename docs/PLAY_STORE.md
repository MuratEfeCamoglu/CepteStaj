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

Metinlerin hepsi kopyalanmaya hazır olarak ayrı dosyalarda:

- **Türkçe (varsayılan):** [`docs/play-store/listing-tr.md`](play-store/listing-tr.md): ad, kısa ve tam açıklama
- **İngilizce (en-US çevirisi):** [`docs/play-store/listing-en.md`](play-store/listing-en.md): uygulama İngilizce telefonlarda **Intern Diary** adıyla görünür, mağaza adı da onunla aynı

**Kategori:** Eğitim (Education). Alternatif: Verimlilik (Productivity)

**İletişim e-postası:** camoglumuratefe@gmail.com
**Gizlilik politikası URL'si:**
`https://github.com/MuratEfeCamoglu/CepteStaj/blob/main/docs/PRIVACY_POLICY.md`
(Repo herkese açık olmalı. Özel tutacaksan politikayı GitHub Pages, Google Sites veya Notion'da herkese açık bir sayfaya koy.)

### Görseller (`docs/play-store/` içinde hazır)

| Play alanı | Türkçe | İngilizce | Ölçü |
|---|---|---|---|
| Uygulama simgesi | `icon-512.png` | aynı | 512×512 |
| Öne çıkan grafik | `feature-graphic-1024x500.png` | `feature-graphic-en-1024x500.png` | 1024×500 |
| Telefon ekran görüntüleri | `screenshots/tr/01…08` | `screenshots/en/01…07` | 1080×1920 |

Ekran görüntüleri gerçek telefondan, örnek (demo) bir stajla çekildi ve başlıklı mağaza görsellerine dönüştürüldü. Uzun kenar kısa kenarın 2 katını geçmiyor, yani Play kuralına uyuyor.

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
  - Gerekçe: Tüm veriler cihazda kalıyor. Tek ağ isteği, kullanıcının Spotify'dan paylaştığı şarkı bağlantısının adını Spotify'a sormak (yalnızca o bağlantı gider, kullanıcı verisi gitmez). Kullanıcının kendi başlattığı paylaşım (PDF/yedek dosyasını paylaş menüsüyle göndermek) Google'ın tanımına göre "toplama" sayılmaz.
- Sonuç kartında **"Veri toplanmıyor" / "Üçüncü taraflarla veri paylaşılmıyor"** görünür.

### Hükümet uygulaması / Finansal özellikler / Sağlık
Hepsi **Hayır**.

### İzin beyanları
Uygulama `POST_NOTIFICATIONS`, `RECEIVE_BOOT_COMPLETED`, `VIBRATE` (bildirim eklentisinden) ve `INTERNET` (yalnızca Spotify'dan paylaşılan şarkının adını öğrenmek için) istiyor; hiçbiri için özel beyan formu gerekmez. (Kesin alarm, konum, SMS, tüm dosyalara erişim vb. hassas izin **yok**.)

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
  - [ ] Günlüğüm PIN kilidi: uygulamadan 30 saniyeden uzun çıkınca tekrar PIN soruyor
  - [ ] Telefon dili İngilizceyken simgenin altında "Intern Diary" yazıyor
  - [ ] Açık ve koyu temada durum çubuğu simgeleri okunuyor
- [ ] Gizlilik politikası URL'si tarayıcıda giriş yapmadan açılıyor
- [x] Yeni ekran görüntüleri çekildi (`docs/play-store/screenshots/tr` ve `en`)
