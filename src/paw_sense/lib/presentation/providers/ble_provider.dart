import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
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
  StreamSubscription<bool>? _isScanningSubscription;

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

  /// Bluetooth açık mı kontrol et, kapalıysa açılmasını iste
  Future<bool> _ensureBluetoothReady() async {
    try {
      var adapterState = await FlutterBluePlus.adapterState.first
          .timeout(const Duration(seconds: 3));
      if (adapterState != BluetoothAdapterState.on) {
        if (Platform.isAndroid) {
          try {
            await FlutterBluePlus.turnOn();
            adapterState = await FlutterBluePlus.adapterState
                .firstWhere((s) => s == BluetoothAdapterState.on)
                .timeout(const Duration(seconds: 5));
          } catch (_) {
            return false;
          }
        } else {
          return false;
        }
      }
      return true;
    } catch (_) {
      // Emülatör veya BLE desteklemeyen cihazda timeout/exception
      return false;
    }
  }

  /// BLE taraması başlat ve bulunan cihazları güncelle
  Future<void> startBeaconScan() async {
    if (kIsWeb) {
      _runMockScan();
      return;
    }

    // BLE fiziksel olarak destekleniyor mu?
    final bleSupported = await _bleScanner.isAvailable();
    if (!bleSupported) {
      _runMockScan();
      return;
    }

    // Bluetooth hazır mı kontrol et (emülatörde timeout → false)
    final ready = await _ensureBluetoothReady();
    if (!ready) {
      _runMockScan();
      return;
    }

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

    // Tarama bittiğinde state'i güncelle
    _isScanningSubscription?.cancel();
    _isScanningSubscription = _bleScanner.isScanning.listen((scanning) {
      if (!scanning && _isScanning) {
        _isScanning = false;
        _unitState = enums.RoomUnitState.idle;
        notifyListeners();
      }
    });

    // Taramayı başlat
    await _startBleScan();
  }

  /// Emülatör / BLE desteklemeyen cihazlar için sahte tarama
  void _runMockScan() {
    _detectedDevices.clear();
    _isScanning = true;
    _unitState = enums.RoomUnitState.active;
    notifyListeners();

    const mockDevices = [
      _MockDevice(id: 'PX-9921-A', name: 'PawSense-Luna', rssi: -48),
      _MockDevice(id: 'PX-4412-B', name: 'PawSense-Mochi', rssi: -62),
      _MockDevice(id: 'PX-7734-C', name: 'PawSense-Oliver', rssi: -73),
    ];

    for (int i = 0; i < mockDevices.length; i++) {
      final device = mockDevices[i];
      Future.delayed(Duration(milliseconds: 600 + i * 500), () {
        if (!_isScanning) return;
        _detectedDevices[device.id] = BleDeviceInfo(
          id: device.id,
          name: device.name,
          rssi: device.rssi,
          status: _evaluateRssi(device.rssi),
        );
        notifyListeners();
      });
    }

    Future.delayed(const Duration(seconds: 3), () {
      if (_isScanning) {
        _isScanning = false;
        _unitState = enums.RoomUnitState.idle;
        notifyListeners();
      }
    });
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
    if (kIsWeb) return;
    final ready = await _ensureBluetoothReady();
    if (!ready) return;

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
    _isScanningSubscription?.cancel();
    super.dispose();
  }
}

class _MockDevice {
  final String id;
  final String name;
  final int rssi;

  const _MockDevice({
    required this.id,
    required this.name,
    required this.rssi,
  });
}
