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
      state: RoomUnitState.values[map['state'] as int],
      rssiThresholdDanger: map['rssi_threshold_danger'] as int,
      rssiThresholdNear: map['rssi_threshold_near'] as int,
      cooldownSeconds: map['cooldown_seconds'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'mac_address': macAddress,
      'state': state.index,
      'rssi_threshold_danger': rssiThresholdDanger,
      'rssi_threshold_near': rssiThresholdNear,
      'cooldown_seconds': cooldownSeconds,
    };
  }
}
