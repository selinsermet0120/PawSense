import '../entities/room_unit.dart';

abstract class BleRepository {
  Stream<List<RoomUnit>> scanForRoomUnits();
  Future<void> startScan();
  Future<void> stopScan();
  Stream<int> getRssiStream(String macAddress);
}
