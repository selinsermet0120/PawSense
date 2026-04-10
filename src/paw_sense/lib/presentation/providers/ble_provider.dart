import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../core/enums/cat_status.dart';
import '../../core/enums/room_unit_state.dart' as enums;
import '../../core/constants/ble_constants.dart';
import '../../domain/usecases/start_ble_scan.dart';
import '../../domain/usecases/evaluate_rssi.dart';
import '../../data/datasources/ble/ble_scanner.dart';

class BleDeviceInfo {
  final String id;
  final String name;
  final int rssi;
  final CatStatus status;

  const BleDeviceInfo({
    required this.id,
    required this.name,
    required this.rssi,
    required this.status,
  });
}

class BleProvider extends ChangeNotifier {
  final StartBleScan _startBleScan;
  final EvaluateRssi _evaluateRssi;
  final BleScanner _bleScanner;

  bool _isScanning = false;
  enums.RoomUnitState _unitState = enums.RoomUnitState.idle;
  final Map<String, BleDeviceInfo> _detectedDevices = {};
  Timer? _cooldownTimer;
  StreamSubscription? _scanSubscription;

  BleProvider({
    required StartBleScan startBleScan,
    required EvaluateRssi evaluateRssi,
    required BleScanner bleScanner,
  })  : _startBleScan = startBleScan,
        _evaluateRssi = evaluateRssi,
        _bleScanner = bleScanner;

  bool get isScanning => _isScanning;
  enums.RoomUnitState get unitState => _unitState;
  List<BleDeviceInfo> get discoveredDevices => _detectedDevices.values.toList();

  /// BLE taraması başlat ve bulunan cihazları güncelle
  Future<void> startBeaconScan() async {
    if (kIsWeb) return;

    _detectedDevices.clear();
    _isScanning = true;
    _unitState = enums.RoomUnitState.active;
    notifyListeners();

    // Sonuçları dinle
    _scanSubscription?.cancel();
    _scanSubscription = _bleScanner.scanResults.listen((results) {
      for (final r in results) {
        final id = r.device.remoteId.str;
        final name = r.device.platformName.isNotEmpty
            ? r.device.platformName
            : r.advertisementData.advName.isNotEmpty
                ? r.advertisementData.advName
                : 'Bilinmeyen Cihaz';
        final rssi = r.rssi;
        final status = _evaluateRssi(rssi);

        _detectedDevices[id] = BleDeviceInfo(
          id: id,
          name: name,
          rssi: rssi,
          status: status,
        );
      }
      notifyListeners();
    });

    // Taramayı başlat
    await _startBleScan();
  }

  /// BLE taramasını durdur
  Future<void> stopBeaconScan() async {
    await _startBleScan.stop();
    await _scanSubscription?.cancel();
    _scanSubscription = null;
    _isScanning = false;
    _unitState = enums.RoomUnitState.idle;
    notifyListeners();
  }

  /// BLE kullanılabilir mi kontrol et
  Future<bool> isBleAvailable() async {
    return await _bleScanner.isAvailable();
  }

  Future<void> startScanning() async {
    await _startBleScan();
    _isScanning = true;
    _unitState = enums.RoomUnitState.active;
    notifyListeners();
  }

  Future<void> stopScanning() async {
    await _startBleScan.stop();
    _isScanning = false;
    _unitState = enums.RoomUnitState.idle;
    _detectedDevices.clear();
    notifyListeners();
  }

  void updateDeviceRssi(String macAddress, String name, int rssi) {
    final status = _evaluateRssi(rssi);
    _detectedDevices[macAddress] = BleDeviceInfo(
      id: macAddress,
      name: name,
      rssi: rssi,
      status: status,
    );
    notifyListeners();
  }

  void enterCooldown() {
    _unitState = enums.RoomUnitState.cooldown;
    notifyListeners();

    _cooldownTimer?.cancel();
    _cooldownTimer = Timer(
      Duration(seconds: BleConstants.cooldownDurationSeconds),
      () {
        _unitState = enums.RoomUnitState.idle;
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    _scanSubscription?.cancel();
    super.dispose();
  }
}
