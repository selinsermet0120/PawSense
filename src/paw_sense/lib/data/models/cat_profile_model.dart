import '../../core/enums/deterrent_sound.dart';
import '../../domain/entities/cat_profile.dart';

class CatProfileModel extends CatProfile {
  const CatProfileModel({
    required super.id,
    required super.name,
    required super.avatarPath,
    required super.beaconId,
    super.deterrentSound,
    super.isActive,
    super.rssiThreshold,
  });

  factory CatProfileModel.fromEntity(CatProfile entity) {
    return CatProfileModel(
      id: entity.id,
      name: entity.name,
      avatarPath: entity.avatarPath,
      beaconId: entity.beaconId,
      deterrentSound: entity.deterrentSound,
      isActive: entity.isActive,
      rssiThreshold: entity.rssiThreshold,
    );
  }

  factory CatProfileModel.fromMap(
    Map<String, dynamic> map, {
    int? soundType,
  }) {
    return CatProfileModel(
      id: map['id'] as String,
      name: map['name'] as String,
      avatarPath: (map['avatar_url'] as String?) ?? '',
      beaconId: (map['beacon_id'] as String?) ?? '',
      deterrentSound: soundType != null
          ? DeterrentSound.values[soundType]
          : DeterrentSound.bip,
      isActive: true,
      rssiThreshold: (map['rssi_threshold'] as int?) ?? -55,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'avatar_url': avatarPath,
      'beacon_id': beaconId,
      'rssi_threshold': rssiThreshold,
    };
  }
}
