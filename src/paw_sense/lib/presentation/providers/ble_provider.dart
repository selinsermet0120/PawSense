import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../core/enums/cat_status.dart';
import '../../core/enums/room_unit_state.dart' as enums;
import '../../core/constants/ble_constants.dart';
import '../../domain/usecases/start_ble_scan.dart';
import '../../domain/usecases/evaluate_rssi.dart';

class BleDeviceStatus {
  final String macAddress;
  final String name;
  final int rssi;
  final CatStatus status;

  const BleDeviceStatus({
    required this.macAddress,
    required this.name,
    required this.rssi,
    required this.status,
  });
}

class BleProvider extends ChangeNotifier {
  final StartBleScan _startBleScan;
  final EvaluateRssi _evaluateRssi;

  bool _isScanning = false;
  enums.RoomUnitState _unitState = enums.RoomUnitState.idle;
  final Map<String, BleDeviceStatus> _detectedDevices = {};
  Timer? _cooldownTimer;

  BleProvider({
    required StartBleScan startBleScan,
    required EvaluateRssi evaluateRssi,
  })  : _startBleScan = startBleScan,
        _evaluateRssi = evaluateRssi;

  bool get isScanning => _isScanning;
  enums.RoomUnitState get unitState => _unitState;
  Map<String, BleDeviceStatus> get detectedDevices =>
      Map.unmodifiable(_detectedDevices);

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
    _detectedDevices[macAddress] = BleDeviceStatus(
      macAddress: macAddress,
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
    super.dispose();
  }
}
