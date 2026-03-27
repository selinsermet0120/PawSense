import 'package:flutter/foundation.dart';
import '../../core/enums/cat_status.dart';
import '../../core/enums/system_mode.dart';

class LiveCatData {
  final String catId;
  final String catName;
  final String zoneName;
  final int rssi;
  final CatStatus status;

  const LiveCatData({
    required this.catId,
    required this.catName,
    required this.zoneName,
    required this.rssi,
    required this.status,
  });
}

class DashboardProvider extends ChangeNotifier {
  SystemMode _currentMode = SystemMode.tarama;
  bool _isLive = true;
  List<LiveCatData> _liveCats = [];

  SystemMode get currentMode => _currentMode;
  bool get isLive => _isLive;
  List<LiveCatData> get liveCats => _liveCats;

  void setMode(SystemMode mode) {
    _currentMode = mode;
    notifyListeners();
  }

  void toggleLive() {
    _isLive = !_isLive;
    notifyListeners();
  }

  void setLiveCats(List<LiveCatData> cats) {
    _liveCats = cats;
    notifyListeners();
  }

  void loadDemoLiveData() {
    _liveCats = const [
      LiveCatData(
        catId: 'cat_1',
        catName: 'Luna',
        zoneName: 'Mutfak Bölgesi',
        rssi: -45,
        status: CatStatus.ihlal,
      ),
      LiveCatData(
        catId: 'cat_2',
        catName: 'Oliver',
        zoneName: 'Yatak Odası',
        rssi: -56,
        status: CatStatus.uyari,
      ),
      LiveCatData(
        catId: 'cat_3',
        catName: 'Mochi',
        zoneName: 'Çalışma Odası',
        rssi: -68,
        status: CatStatus.guvenli,
      ),
    ];
    notifyListeners();
  }
}
