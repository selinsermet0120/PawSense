import '../../core/enums/cat_status.dart';
import '../../core/constants/ble_constants.dart';

class EvaluateRssi {
  EvaluateRssi();

  /// RSSI değerine göre kedi durumunu belirler.
  /// RSSI > -52  → İHLAL (DANGER)
  /// -52 ≥ RSSI ≥ -60 → UYARI (NEAR)
  /// RSSI < -60  → GÜVENLİ (FAR)
  CatStatus call(int rssi) {
    if (rssi > BleConstants.rssiThresholdDanger) {
      return CatStatus.ihlal;
    } else if (rssi >= BleConstants.rssiThresholdNear) {
      return CatStatus.uyari;
    } else {
      return CatStatus.guvenli;
    }
  }
}
