# 🐾 PawSense: Smart Cat Access Control System

PawSense, kedilerin mutfak tezgahı, çalışma masası gibi kısıtlı alanlara (Restricted Zones) girmesini engelleyen ve bu ihlalleri raporlayan akıllı bir erişim kontrol sistemidir.

## ✨ Özellikler (Velvet Paw Edition)
- **Çoklu Kedi Takibi:** Birden fazla kediyi aynı anda izleme ve yönetme.
- **Kişiselleştirilmiş Profiller:** Her kedi için isim, fotoğraf ve tasma (Beacon ID) tanımlama.
- **Özel Caydırıcı Sesler:** Her kedi için farklı frekansta (Bip, Fıslama, Ultrasonik) caydırıcı ses seçimi.
- **İhlal Günlüğü:** Geçmiş ihlalleri (saat, bölge, süre) detaylı istatistiklerle raporlama.
- **Dost Canlısı Arayüz:** Pastel tonlarda (Velvet Paw style), kullanıcıyı yormayan modern tasarım.

## 🛠️ Teknik Altyapı (DSD v2.0)
Sistem, Bluetooth Low Energy (BLE) teknolojisi ve RSSI (sinyal gücü) tabanlı mesafe kestirimi üzerine kuruludur.

### Donanım Bileşenleri:
- **Collar Beacon:** Raytac MDBT42Q-PAT (nRF52810 SoC).
- **Room Unit:** ESP32-WROOM-32U + Harici 2.4 GHz Anten.
- **Deterrent:** 20mm Piezo Buzzer (4kHz).

### Mesafe ve Karar Mantığı:
| Durum | RSSI Eşiği | Açıklama |
| :--- | :--- | :--- |
| **DANGER** | > -52 dBm | İhlal Tespit Edildi (Caydırıcı 2s Aktif) |
| **NEAR** | -52 to -60 dBm | Yakınlaşma Uyarısı |
| **FAR** | < -60 dBm | Güvenli / İhlal Yok  |

## 🚀 Kurulum
1. Flutter SDK yüklü olduğundan emin olun.
2. Depoyu klonlayın: `git clone https://github.com/kullanici-adin/pawsense_app.git`
3. Bağımlılıkları yükleyin: `flutter pub get`
4. Uygulamayı başlatın: `flutter run`

---
**Geliştirici Ekibi:** Dilara Acar, Tevfik Efe Aydın, Selin Şermet 
**Danışman:** Dr. Suat Seçgin
