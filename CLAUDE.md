# PawSense — Smart Cat Access Control System

## Proje Özeti

PawSense, kedilerin yasak bölgelere (mutfak, yatak odası, çalışma odası vb.) girmesini tespit eden ve uyarı üreten bir akıllı erişim kontrol sistemidir. Sistem iki ana düğümden oluşur:

1. **Collar Beacon (Tasma Modülü):** Kedinin tasmasına takılan, BLE (Bluetooth Low Energy) sinyali yayınlayan küçük bir cihaz. Raytac MDBT42Q-PAT (nRF52810) modülü kullanır, CR2032 pil ile çalışır.
2. **Room Unit (Oda Ünitesi):** Yasaklı bölge girişine yerleştirilen, BLE taraması yaparak kedinin yakınlığını RSSI ile ölçen ESP32-WROOM-32U tabanlı birim. Eşik değeri aşılınca buzzer ve LED ile uyarı verir.

## Mobil Uygulama (Geliştirme Hedefi)

Bu proje kapsamında, donanım sisteminin yanında bir **mobil uygulama** geliştirilecektir. Uygulama aşağıdaki ekranlardan ve özelliklerden oluşur.

### Ekran 1: Anasayfa (Dashboard)

- **Üst kısım:** "PawSense" başlığı, bildirim ikonu, bilgi ikonu
- **Sistem Modu kartı:** Aktif güvenlik parametreleri — üç mod gösterimi:
  - TARAMA (yeşil badge)
  - CAYDIRICI (turuncu badge)
  - BEKLE (gri badge)
- **Aktif İhlal Kontrolü bölümü:** "CANLI" etiketi ile gerçek zamanlı kedi listesi
  - Her kedi kartında:
    - Kedi profil görseli (daire avatar)
    - Kedi adı
    - Bulunduğu bölge (ör. "Mutfak Bölgesi")
    - RSSI sinyal gücü (ör. -68 dBm) — yeşil/sarı/kırmızı renk kodlu
    - Durum etiketi: GÜVENLİ (yeşil), UYARI (sarı), İHLAL/DANGER (kırmızı)
  - İhlal durumunda kart kırmızı kenarlıkla vurgulanır
- **Alt kısım:** İki kart
  - "İhlal Kaydı" — Son 24 saat analizi
  - "Ayarlar" — Hassasiyet modları
- **Alt navigasyon:** Anasayfa | Kedilerim | Geçmiş

### Ekran 2: Kedi Ayarları

- **Kedi profil alanı:** Büyük daire avatar, kedi adı (ör. "Luna"), alt başlık "Evcil Dostunuzun Akıllı Güvenlik Ayarları"
- **Beacon Tanımlama bölümü:**
  - nRF52810 Modül ID gösterimi (ör. "PX-9921-A")
  - "TARA" butonu — QR kod tarama
  - Açıklama: "Modül ID'si tasmanın iç tasmani'nde yer olan QR kodun altındaki benzersiz numaradır."
- **Ses Kütüphanesi bölümü:** Seçilebilir caydırıcı ses tipleri
  - Bip (seçili, yeşil onay)
  - Fıslama
  - Yüksek Frekans
  - Her ses tipi bir kart olarak gösterilir, ikonlu

### Ekran 3: İhlal Raporları / Geçmiş

- **İhlal Karnesi (Son 7 Gün):**
  - "En Çok İhlal Yapan" kedi gösterimi (ör. Luna)
  - "En Sık İhlal Saati" gösterimi (ör. 15:00–17:00)
  - Kedi filtre butonları: Hepsi | Luna | Oliver | Mochi
- **Olay Günlüğü:** Kronolojik sırada ihlal listesi
  - Her kayıtta: kedi avatarı, kedi adı, konum, saat, süre (ör. "25N CAYDIRICI")
  - Renkli süre etiketleri

## Tasarım Sistemi (UI/UX)

### Renk Paleti (Kesin Değerler)

- **Primary:** `#4ECDC4` — Teal/Mint yeşili. Ana butonlar, aktif navigasyon, başlık vurguları
- **Secondary:** `#FFCBA4` — Sıcak şeftali/turuncu. İkincil kartlar, kedi ayarları arka planı
- **Tertiary:** `#E6E6FA` — Açık lavanta. Üçüncül alanlar, pasif bileşenler
- **Neutral:** `#FFFDD0` — Krem/açık sarı. Genel sayfa arka planı
- **Durum renkleri:**
  - Güvenli: Yeşil
  - Uyarı: Turuncu/Sarı
  - İhlal/Tehlike: Kırmızı/Pembe — kart kenarlığı kırmızıya döner
- **Kartlar:** Beyaz, yuvarlatılmış köşeler (border-radius ~16px), hafif gölge
- **Metin:** Koyu gri/siyah

### Tipografi

- **Headline:** Büyük, bold, modern sans-serif
- **Body:** Normal ağırlık, okunabilir boyut
- **Label:** Küçük boyut, badge ve etiketlerde kullanılır
- Badge'ler: küçük, rounded, bold metin

### Buton Stilleri

- **Primary:** Dolgulu teal (`#4ECDC4`), beyaz metin, rounded
- **Secondary:** Beyaz arka plan, teal kenarlık, teal metin
- **Inverted:** Koyu arka plan, açık metin
- **Outlined:** Sadece kenarlık, dolgusuz

### UI Bileşenleri

- **Arama kutusu:** Rounded, solda arama ikonu, açık arka plan
- **Alt navigasyon bar:** İkon + metin, aktif sekme teal renkle vurgulanır, 3 sekme (Anasayfa, Kedilerim, Geçmiş)
- **İkonlar:** Minimal, outline tarzı; aktif olanlar dolgulu teal daire içinde
- **Etiketler (Label):** İkon + metin, açık renkli arka plan, rounded
- **Kedi avatarları:** Daire şeklinde
- **Aksiyon ikonları:** Daire içinde, renkli arka plan (teal, kahverengi, lavanta, kırmızı)

### Genel Stil

- Yumuşak, dostane, "pet-friendly" hissi
- Rounded kartlar ve butonlar
- Pastel renk paleti
- Krem/sarımsı genel arka plan (`#FFFDD0`)

## Teknik Mimari (Donanım — Referans)

### Collar Beacon

- Modül: Raytac MDBT42Q-PAT (nRF52810 SoC)
- Güç: CR2032 pil + slide switch
- Decoupling: 100µF + 100nF kapasitörler
- İşlev: BLE advertisement yayını (sabit ID, ayarlanabilir interval)

### Room Unit

- Modül: ESP32-WROOM-32U + harici 2.4GHz anten
- İşlev: Sürekli BLE taraması, RSSI değerlendirme, eşik kontrolü
- Çıkışlar: 20mm piezo buzzer (2N2222 transistör ile sürülür), kırmızı/yeşil LED'ler
- State machine: IDLE → SCANNING → DETECT → ALERT → COOLDOWN → IDLE

### Yazılım Akışı

1. Beacon BLE advertisement yayınlar
2. Room unit RSSI ölçer
3. Eşik aşılırsa → onay penceresi kontrol edilir
4. Onay sağlanırsa → ALERT durumu: buzzer + LED aktif
5. Cooldown süresi sonrası idle'a dönüş
6. Tüm olaylar mobil uygulamaya bildirilir

## Dosya Yapısı

```
PawSense/
├── CLAUDE.md          ← Bu dosya
├── referans/
│   ├── PawSense_DSD_v2_1.docx   ← Tasarım spesifikasyon dokümanı
│   ├── ui-tasarim.png            ← Mobil uygulama UI referans görseli
│   └── style-guide.png           ← Renk paleti, tipografi ve bileşen referansı
├── src/                          ← Uygulama kaynak kodu
└── ...
```

## Önemli Notlar

- UI tasarımı `referans/ui-tasarim.png` dosyasındaki görsele mümkün olduğunca sadık kalmalıdır.
- Renk kodları ve bileşen stilleri `referans/style-guide.png` dosyasındaki design system'e uygun olmalıdır.
- Uygulama Türkçe olmalıdır.
- Kedi avatarları, renkler ve kart düzeni görseldeki gibi olmalıdır.
- Tasarım spesifikasyonunun tam metni `referans/PawSense_DSD_v2_1.docx` dosyasındadır.
