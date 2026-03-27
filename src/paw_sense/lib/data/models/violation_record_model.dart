import '../../core/enums/cat_status.dart';
import '../../domain/entities/violation_record.dart';

class ViolationRecordModel extends ViolationRecord {
  const ViolationRecordModel({
    required super.id,
    required super.catId,
    required super.roomUnitId,
    required super.zoneName,
    required super.rssiValue,
    required super.status,
    required super.timestamp,
    super.durationSeconds,
  });

  factory ViolationRecordModel.fromEntity(ViolationRecord entity) {
    return ViolationRecordModel(
      id: entity.id,
      catId: entity.catId,
      roomUnitId: entity.roomUnitId,
      zoneName: entity.zoneName,
      rssiValue: entity.rssiValue,
      status: entity.status,
      timestamp: entity.timestamp,
      durationSeconds: entity.durationSeconds,
    );
  }

  factory ViolationRecordModel.fromMap(Map<String, dynamic> map) {
    return ViolationRecordModel(
      id: map['id'] as String,
      catId: map['cat_id'] as String,
      roomUnitId: map['room_unit_id'] as String,
      zoneName: map['zone_name'] as String,
      rssiValue: map['rssi_value'] as int,
      status: CatStatus.values[map['status'] as int],
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
      durationSeconds: map['duration_seconds'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cat_id': catId,
      'room_unit_id': roomUnitId,
      'zone_name': zoneName,
      'rssi_value': rssiValue,
      'status': status.index,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'duration_seconds': durationSeconds,
    };
  }
}
