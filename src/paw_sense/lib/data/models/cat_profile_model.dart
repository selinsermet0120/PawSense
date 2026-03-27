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
  });

  factory CatProfileModel.fromEntity(CatProfile entity) {
    return CatProfileModel(
      id: entity.id,
      name: entity.name,
      avatarPath: entity.avatarPath,
      beaconId: entity.beaconId,
      deterrentSound: entity.deterrentSound,
      isActive: entity.isActive,
    );
  }

  factory CatProfileModel.fromMap(Map<String, dynamic> map) {
    return CatProfileModel(
      id: map['id'] as String,
      name: map['name'] as String,
      avatarPath: map['avatar_path'] as String,
      beaconId: map['beacon_id'] as String,
      deterrentSound: DeterrentSound.values[map['deterrent_sound'] as int],
      isActive: (map['is_active'] as int) == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'avatar_path': avatarPath,
      'beacon_id': beaconId,
      'deterrent_sound': deterrentSound.index,
      'is_active': isActive ? 1 : 0,
    };
  }
}
