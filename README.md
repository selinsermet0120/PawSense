# 🐾 PawSense: Smart Cat Access Control System

[cite_start]PawSense, kedilerin mutfak tezgahı, çalışma masası gibi kısıtlı alanlara (Restricted Zones) girmesini engelleyen ve bu ihlalleri raporlayan akıllı bir erişim kontrol sistemidir[cite: 46, 48].

## ✨ Özellikler (Velvet Paw Edition)
- **Çoklu Kedi Takibi:** Birden fazla kediyi aynı anda izleme ve yönetme.
- **Kişiselleştirilmiş Profiller:** Her kedi için isim, fotoğraf ve tasma (Beacon ID) tanımlama.
- **Özel Caydırıcı Sesler:** Her kedi için farklı frekansta (Bip, Fıslama, Ultrasonik) caydırıcı ses seçimi.
- **İhlal Günlüğü:** Geçmiş ihlalleri (saat, bölge, süre) detaylı istatistiklerle raporlama.
- **Dost Canlısı Arayüz:** Pastel tonlarda (Velvet Paw style), kullanıcıyı yormayan modern tasarım.

## 🛠️ Teknik Altyapı (DSD v2.0)
[cite_start]Sistem, Bluetooth Low Energy (BLE) teknolojisi ve RSSI (sinyal gücü) tabanlı mesafe kestirimi üzerine kuruludur[cite: 49, 96].

### [cite_start]Donanım Bileşenleri[cite: 54, 111]:
- [cite_start]**Collar Beacon:** Raytac MDBT42Q-PAT (nRF52810 SoC)[cite: 54, 64].
- [cite_start]**Room Unit:** ESP32-WROOM-32U + Harici 2.4 GHz Anten[cite: 54, 66].
- [cite_start]**Deterrent:** 20mm Piezo Buzzer (4kHz)[cite: 60, 111].

### [cite_start]Mesafe ve Karar Mantığı[cite: 85, 86]:
| Durum | RSSI Eşiği | Açıklama |
| :--- | :--- | :--- |
| **DANGER** | > -52 dBm | [cite_start]İhlal Tespit Edildi (Caydırıcı 2s Aktif) [cite: 85, 86, 136] |
| **NEAR** | -52 to -60 dBm | [cite_start]Yakınlaşma Uyarısı [cite: 85, 86] |
| **FAR** | < -60 dBm | [cite_start]Güvenli / İhlal Yok [cite: 85, 86] |

## 🚀 Kurulum
1. Flutter SDK yüklü olduğundan emin olun.
2. Depoyu klonlayın: `git clone https://github.com/kullanici-adin/pawsense_app.git`
3. Bağımlılıkları yükleyin: `flutter pub get`
4. Uygulamayı başlatın: `flutter run`

---
[cite_start]**Geliştirici Ekibi:** Dilara Acar, Tevfik Efe Aydın, Selin Şermet [cite: 3, 4, 5]
[cite_start]**Danışman:** Dr. Suat Seçgin [cite: 2]