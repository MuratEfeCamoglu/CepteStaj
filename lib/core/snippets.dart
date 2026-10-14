/// Ready-made Defter sentences, grouped by the student's field. Interns
/// range from software to medicine to teaching to vocational workshops, so
/// a single software-flavoured list helps almost nobody. Sentences are the
/// Turkish source text; [t] translates them for display.
library;

class InternshipField {
  final String key;
  final String emoji;
  final String label;
  /// Example topic shown as the hint of the Defter "Konu" field.
  final String topicHint;

  const InternshipField(this.key, this.emoji, this.label, this.topicHint);
}

const internshipFields = [
  InternshipField('software', '💻', 'Yazılım / Bilişim', 'Konu (örn. API entegrasyonu)'),
  InternshipField('engineering', '⚙️', 'Mühendislik', 'Konu (örn. üretim hattı verimlilik analizi)'),
  InternshipField('health', '🩺', 'Sağlık / Tıp', 'Konu (örn. dahiliye servisi vizitesi)'),
  InternshipField('education', '🍎', 'Eğitim / Öğretmenlik', 'Konu (örn. 6. sınıf kesirler dersi)'),
  InternshipField('business', '💼', 'İşletme / Muhasebe / Ofis', 'Konu (örn. aylık fatura kayıtları)'),
  InternshipField('law', '⚖️', 'Hukuk', 'Konu (örn. icra dosyası incelemesi)'),
  InternshipField('design', '📐', 'Mimarlık / Tasarım', 'Konu (örn. kat planı çizimi)'),
  InternshipField('technical', '🔧', 'Teknik / Meslek Lisesi', 'Konu (örn. pano bağlantısı)'),
  InternshipField('tourism', '🏨', 'Turizm / Otelcilik / Mutfak', 'Konu (örn. ön büro check-in işlemleri)'),
  InternshipField('general', '📋', 'Diğer / Genel', 'Konu (örn. bugünkü ana görev)'),
];

InternshipField fieldFor(String key) =>
    internshipFields.firstWhere((f) => f.key == key, orElse: () => internshipFields.last);

/// Sentences that fit almost any internship — shown after the field's own.
const generalSnippets = [
  'Sabah ekiple günün planını konuştuk.',
  'Sorumlumla birebir görüştüm ve geri bildirim aldım.',
  'Yeni bir konu hakkında araştırma yaptım.',
  'Bir toplantıya katılıp not aldım.',
  'Bana verilen görevi tamamlayıp kontrol ettirdim.',
  'Kurumun işleyişini ve birimlerini tanıdım.',
  'İş güvenliği / iş sağlığı kurallarını öğrendim.',
  'Dosya ve belge düzenlemesine yardım ettim.',
];

const fieldSnippets = <String, List<String>>{
  'software': [
    'Ekibin daily toplantısına katıldım.',
    'Kod incelemesine (code review) katıldım.',
    'Dokümantasyon inceledim.',
    'Bir hatayı (bug) tespit edip düzelttim.',
    'Yeni bir özellik için kod yazdım.',
    'Birim testleri yazdım.',
    'Git ile branch açıp pull request gönderdim.',
    'Veritabanı sorguları üzerinde çalıştım.',
    'Geliştirme ortamını kurdum.',
    'API uç noktalarını Postman ile test ettim.',
  ],
  'engineering': [
    'Sahada / üretim hattında gözlem yaptım.',
    'Teknik çizimleri inceledim.',
    'Bir makinenin bakım sürecine eşlik ettim.',
    'Ölçüm alıp sonuçları raporladım.',
    'Kalite kontrol sürecini inceledim.',
    'Bir proje toplantısına katıldım.',
    'Malzeme ve maliyet hesabı yaptım.',
    'CAD programında çizim yaptım.',
    'Üretim verilerini Excel\'de analiz ettim.',
    'İş güvenliği eğitimine katıldım.',
  ],
  'health': [
    'Sabah vizitesine katıldım.',
    'Hasta anamnezi aldım.',
    'Fizik muayeneye eşlik ettim.',
    'Vital bulguları ölçüp kaydettim.',
    'Hasta dosyalarını ve tetkik sonuçlarını inceledim.',
    'Tedavi planını sorumlu hekimle değerlendirdim.',
    'Poliklinikte hasta takibine eşlik ettim.',
    'Steril çalışma kurallarını uyguladım.',
    'Nöbet devrine katıldım.',
    'İlaç hazırlama ve uygulama sürecini gözlemledim.',
  ],
  'education': [
    'Derse gözlemci olarak katıldım.',
    'Ders planı hazırladım.',
    'Bir dersi kendim anlattım.',
    'Öğrencilerin ödevlerini kontrol ettim.',
    'Ders için materyal hazırladım.',
    'Sınıf yönetimi tekniklerini gözlemledim.',
    'Öğretmenler toplantısına katıldım.',
    'Bireysel destek gereken öğrencilerle çalıştım.',
    'Ölçme-değerlendirme sorusu hazırladım.',
    'Nöbetçi öğretmene eşlik ettim.',
  ],
  'business': [
    'Fatura ve belgeleri sisteme girdim.',
    'Muhasebe kayıtlarını kontrol ettim.',
    'Excel\'de rapor hazırladım.',
    'Müşteri görüşmesine eşlik ettim.',
    'Gelen-giden evrak kaydı yaptım.',
    'Satış ve stok verilerini inceledim.',
    'Sunum hazırlamaya yardım ettim.',
    'E-posta yazışmalarını takip ettim.',
    'Banka ve ödeme işlemlerini öğrendim.',
    'Toplantı için not ve tutanak hazırladım.',
  ],
  'law': [
    'Duruşmaya katıldım.',
    'Dava dosyasını inceledim.',
    'Dilekçe taslağı hazırladım.',
    'Adliyede kalem işlemlerini takip ettim.',
    'İçtihat ve mevzuat araştırması yaptım.',
    'Müvekkil görüşmesine eşlik ettim.',
    'UYAP üzerinden dosya sorguladım.',
    'Sözleşme taslağını inceledim.',
  ],
  'design': [
    'Proje çizimleri üzerinde çalıştım.',
    'Şantiye ziyaretine katıldım.',
    'AutoCAD\'de plan çizdim.',
    '3B model / görselleştirme hazırladım.',
    'Malzeme seçimi araştırması yaptım.',
    'Müşteri sunumuna katıldım.',
    'Revizyonları çizimlere işledim.',
    'Maket hazırlamaya yardım ettim.',
  ],
  'technical': [
    'Atölyede usta öğreticiye yardım ettim.',
    'Elektrik panosu bağlantısı yaptım.',
    'Arızalı bir cihazın tespitini yaptım.',
    'Ölçü aletleriyle ölçüm yaptım.',
    'Motor / araç bakımına katıldım.',
    'Tezgâhta parça işledim.',
    'Kaynak işlemini gözlemledim.',
    'Takım ve malzeme düzenini sağladım.',
    'İş güvenliği ekipmanlarını kullandım.',
  ],
  'tourism': [
    'Ön büroda check-in / check-out işlemlerine yardım ettim.',
    'Misafir taleplerini karşıladım.',
    'Rezervasyon sistemini öğrendim.',
    'Mutfakta hazırlık (mise en place) yaptım.',
    'Servis düzenine katıldım.',
    'Kat hizmetleri sürecini inceledim.',
    'Menü maliyet hesabını öğrendim.',
    'Hijyen kurallarını uyguladım.',
  ],
  'general': [],
};

/// The field's own sentences first, then the general ones.
List<String> snippetsFor(String field) => [...?fieldSnippets[field], ...generalSnippets];
