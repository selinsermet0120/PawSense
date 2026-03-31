import '../../core/enums/room_unit_state.dart';
import '../../domain/entities/room_unit.dart';

class RoomUnitModel extends RoomUnit {
  const RoomUnitModel({
    required super.id,
    required super.name,
    required super.macAddress,
    super.state,
    super.rssiThresholdDanger,
    super.rssiThresholdNear,
    super.cooldownSeconds,
  });

  factory RoomUnitModel.fromEntity(RoomUnit entity) {
    return RoomUnitModel(
      id: entity.id,
      name: entity.name,
      macAddress: entity.macAddress,
      state: entity.state,
      rssiThresholdDanger: entity.rssiThresholdDanger,
      rssiThresholdNear: entity.rssiThresholdNear,
      cooldownSeconds: entity.cooldownSeconds,
    );
  }

  factory RoomUnitModel.fromMap(Map<String, dynamic> map) {
    return RoomUnitModel(
      id: map['id'] as String,
      name: map['name'] as String,
      macAddress: map['mac_address'] as String,
      state: RoomUnitState.idle,
      rssiThresholdDanger: (map['rssi_danger'] as int?) ?? -52,
      rssiThresholdNear: (map['rssi_near'] as int?) ?? -60,
      cooldownSeconds: 5,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'mac_address': macAddress,
      'rssi_danger': rssiThresholdDanger,
      'rssi_near': rssiThresholdNear,
    };
  }
}
