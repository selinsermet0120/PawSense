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
      zoneName: (map['zone'] as String?) ?? '',
      rssiValue: map['rssi_value'] as int,
      status: _parseSeverity(map['severity']),
      timestamp: DateTime.parse(map['created_at'] as String),
      durationSeconds: (map['deterrent_duration_sec'] as int?) ?? 0,
    );
  }

  static CatStatus _parseSeverity(dynamic value) {
    if (value is int) return CatStatus.values[value];
    if (value is String) {
      switch (value.toUpperCase()) {
        case 'DANGER':
        case 'İHLAL':
          return CatStatus.ihlal;
        case 'WARNING':
        case 'UYARI':
          return CatStatus.uyari;
        default:
          return CatStatus.guvenli;
      }
    }
    return CatStatus.guvenli;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cat_id': catId,
      'room_unit_id': roomUnitId,
      'zone': zoneName,
      'rssi_value': rssiValue,
      'severity': status.index,
    };
  }
}
