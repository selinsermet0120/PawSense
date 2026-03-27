import 'dart:async';
import '../../core/enums/room_unit_state.dart';
import '../../domain/entities/room_unit.dart';
import '../../domain/repositories/ble_repository.dart';
import '../datasources/ble/ble_scanner.dart';

class BleRepositoryImpl implements BleRepository {
  final BleScanner _bleScanner;

  BleRepositoryImpl(this._bleScanner);

  @override
  Stream<List<RoomUnit>> scanForRoomUnits() {
    return _bleScanner.scanResults.map((results) {
      return results
          .where((r) => r.device.platformName.startsWith('PawSense'))
          .map((r) => RoomUnit(
                id: r.device.remoteId.str,
                name: r.device.platformName,
                macAddress: r.device.remoteId.str,
                state: RoomUnitState.idle,
              ))
          .toList();
    });
  }

  @override
  Future<void> startScan() async {
    await _bleScanner.startScan();
  }

  @override
  Future<void> stopScan() async {
    await _bleScanner.stopScan();
  }

  @override
  Stream<int> getRssiStream(String macAddress) {
    return _bleScanner.scanResults.map((results) {
      final device = results.where(
        (r) => r.device.remoteId.str == macAddress,
      );
      if (device.isEmpty) return -100;
      return device.first.rssi;
    });
  }
}
