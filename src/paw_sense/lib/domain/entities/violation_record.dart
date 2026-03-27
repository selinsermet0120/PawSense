import '../../core/enums/cat_status.dart';

class ViolationRecord {
  final String id;
  final String catId;
  final String roomUnitId;
  final String zoneName;
  final int rssiValue;
  final CatStatus status;
  final DateTime timestamp;
  final int durationSeconds;

  const ViolationRecord({
    required this.id,
    required this.catId,
    required this.roomUnitId,
    required this.zoneName,
    required this.rssiValue,
    required this.status,
    required this.timestamp,
    this.durationSeconds = 0,
  });

  ViolationRecord copyWith({
    String? id,
    String? catId,
    String? roomUnitId,
    String? zoneName,
    int? rssiValue,
    CatStatus? status,
    DateTime? timestamp,
    int? durationSeconds,
  }) {
    return ViolationRecord(
      id: id ?? this.id,
      catId: catId ?? this.catId,
      roomUnitId: roomUnitId ?? this.roomUnitId,
      zoneName: zoneName ?? this.zoneName,
      rssiValue: rssiValue ?? this.rssiValue,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
      durationSeconds: durationSeconds ?? this.durationSeconds,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ViolationRecord &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
