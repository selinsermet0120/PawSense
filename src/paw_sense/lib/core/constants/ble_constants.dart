class BleConstants {
  BleConstants._();

  /// RSSI eşik değerleri (dBm)
  /// DANGER: > -52  → İhlal, 2 sn caydırıcı aktif
  /// NEAR:   -52 ile -60 → Yakınlaşma uyarısı
  /// FAR:    < -60  → Güvenli
  static const int rssiThresholdDanger = -52;
  static const int rssiThresholdNear = -60;

  /// Caydırıcı aktif süresi (saniye)
  static const int deterrentDurationSeconds = 2;

  /// Cooldown süresi (saniye)
  static const int cooldownDurationSeconds = 5;

  /// BLE tarama aralığı (milisaniye)
  static const int scanIntervalMs = 1000;
}
