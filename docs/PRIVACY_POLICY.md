# Cepte Staj — Gizlilik Politikası

**Son güncelleme:** 16 Ekim 2026

Cepte Staj, staj defterini telefonunda tutman için yapılmış, tamamen cihaz üzerinde çalışan bir uygulamadır. Bu politika hangi verileri nasıl işlediğini açıklar.

## Kısaca

- **Hiçbir veri toplamıyoruz.** Uygulamanın sunucusu yoktur; hesap, reklam, analiz (analytics) veya çökme raporlama aracı içermez.
- **Yazdıkların internete gönderilmez.** Uygulamanın internet izni tek bir iş için vardır: Spotify'dan bir şarkıyı "Paylaş → Cepte Staj" ile gönderdiğinde, şarkının adını öğrenmek için o bağlantı Spotify'a (open.spotify.com) sorulur. Bu istekte yalnızca paylaştığın Spotify bağlantısı bulunur; defterin, günlüğün ya da başka bir verin gönderilmez. Bu özelliği kullanmazsan uygulama hiç internete bağlanmaz.
- Yazdığın her şey (defter kayıtları, günlük, ruh hali, fotoğraflar, ayarlar) **yalnızca senin telefonunda** saklanır.

## Cihazında saklanan veriler

| Veri | Amaç | Nerede |
|---|---|---|
| Staj bilgileri (staj adı, şirket, tarihler, çalışma günleri) | İş günü sayacı ve takvim | Uygulamanın kendi depolama alanı |
| Resmi Defter kayıtları (konu, yapılan işler, öğrendiklerin, giriş-çıkış saati) | Defterini doldurman ve kağıda geçirmen | Uygulamanın kendi depolama alanı |
| Günlüğüm kayıtları (ruh hali, Günün Olayı, zafer, mentor sözleri, sayaçlar, bingo, rozetler) | Kişisel staj anıların | Uygulamanın kendi depolama alanı |
| Fotoğraflar | Gün kayıtlarına eklediğin görseller | Uygulama klasörüne kopyalanır |
| PIN (isteğe bağlı) | Günlüğüm sekmesini kilitlemek | Yalnızca karma (hash) olarak saklanır |

Bu verilere geliştirici dahil hiç kimse erişemez.

## İzinler

- **Bildirimler:** Seçtiğin saatte "bugünü doldurmayı unutma" hatırlatması göstermek için. İstersen Ayarlar'dan kapatabilirsin.
- **Cihaz yeniden başladığında çalışma (RECEIVE_BOOT_COMPLETED):** Telefon yeniden başladıktan sonra günlük hatırlatmayı yeniden kurmak için.
- **Kamera / galeri:** Yalnızca sen "Kamera" ya da "Galeri" düğmesine bastığında, sistemin kendi kamera ve fotoğraf seçici ekranları açılır. Uygulama galerine kendi başına erişmez.

## Veriler cihazdan ne zaman çıkar?

Yalnızca **senin başlattığın** durumlarda:

- Bir günü **WhatsApp'ta gönder** ya da başka bir uygulamada paylaş dediğinde, o günün yalnızca defter yazısı seçtiğin uygulamaya gider.
- **Resmi Defter PDF / Word** dosyasını indirdiğinde, dosya senin seçtiğin klasöre kaydedilir.
- **Resmi Defter PDF / Word** ya da **yedek dosyası** (tüm kayıtlarını ve fotoğraflarını içeren .zip) oluşturup paylaş ekranından bir uygulama seçtiğinde, dosya seçtiğin uygulamaya gider. Resmi Defter (PDF, Word ya da mesaj) Günlüğüm (kişisel) verilerini **asla** içermez; yalnızca deftere eklemeyi açıkça seçtiğin fotoğraflar PDF'e girer.
- **Staj Wrapped** özetini paylaştığında, ekranda gördüğün metin seçtiğin uygulamaya gönderilir.
- Android'in **sistem yedeklemesi** telefonunda açıksa, Android uygulama verilerini kendi Google hesabındaki şifreli yedeğe dahil edebilir. Bu, Google'ın telefon yedekleme hizmetidir; Cepte Staj'ın bu verilere erişimi yoktur.

## Verilerini silme

- Ayarlar → **Tüm verileri sıfırla** ile her şeyi telefonundan kaldırabilirsin.
- Uygulamayı kaldırmak da tüm verileri siler.

## Çocukların gizliliği

Cepte Staj 13 yaş altındaki çocuklara yönelik değildir ve kimseden kişisel veri toplamaz.

## Değişiklikler

Bu politika değişirse güncel hali bu sayfada yayımlanır ve yukarıdaki tarih güncellenir.

## İletişim

Sorular için: camoglumuratefe@gmail.com
