import '../../core/enums/room_unit_state.dart';
import '../../core/constants/ble_constants.dart';

class RoomUnit {
  final String id;
  final String name;
  final String macAddress;
  final RoomUnitState state;
  final int rssiThresholdDanger;
  final int rssiThresholdNear;
  final int cooldownSeconds;

  const RoomUnit({
    required this.id,
    required this.name,
    required this.macAddress,
    this.state = RoomUnitState.idle,
    this.rssiThresholdDanger = BleConstants.rssiThresholdDanger,
    this.rssiThresholdNear = BleConstants.rssiThresholdNear,
    this.cooldownSeconds = BleConstants.cooldownDurationSeconds,
  });

  RoomUnit copyWith({
    String? id,
    String? name,
    String? macAddress,
    RoomUnitState? state,
    int? rssiThresholdDanger,
    int? rssiThresholdNear,
    int? cooldownSeconds,
  }) {
    return RoomUnit(
      id: id ?? this.id,
      name: name ?? this.name,
      macAddress: macAddress ?? this.macAddress,
      state: state ?? this.state,
      rssiThresholdDanger: rssiThresholdDanger ?? this.rssiThresholdDanger,
      rssiThresholdNear: rssiThresholdNear ?? this.rssiThresholdNear,
      cooldownSeconds: cooldownSeconds ?? this.cooldownSeconds,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RoomUnit &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
