import '../../core/enums/deterrent_sound.dart';

class CatProfile {
  final String id;
  final String name;
  final String avatarPath;
  final String beaconId;
  final DeterrentSound deterrentSound;
  final bool isActive;

  const CatProfile({
    required this.id,
    required this.name,
    required this.avatarPath,
    required this.beaconId,
    this.deterrentSound = DeterrentSound.bip,
    this.isActive = true,
  });

  CatProfile copyWith({
    String? id,
    String? name,
    String? avatarPath,
    String? beaconId,
    DeterrentSound? deterrentSound,
    bool? isActive,
  }) {
    return CatProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarPath: avatarPath ?? this.avatarPath,
      beaconId: beaconId ?? this.beaconId,
      deterrentSound: deterrentSound ?? this.deterrentSound,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CatProfile &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
