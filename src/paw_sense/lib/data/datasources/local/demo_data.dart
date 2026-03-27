import '../../../core/enums/cat_status.dart';
import '../../../core/enums/deterrent_sound.dart';
import '../../../domain/entities/cat_profile.dart';
import '../../../domain/entities/violation_record.dart';

class DemoData {
  DemoData._();

  static const List<CatProfile> cats = [
    CatProfile(
      id: 'cat_1',
      name: 'Luna',
      avatarPath: '',
      beaconId: 'PX-9921-A',
      deterrentSound: DeterrentSound.bip,
      isActive: true,
    ),
    CatProfile(
      id: 'cat_2',
      name: 'Oliver',
      avatarPath: '',
      beaconId: 'PX-8832-B',
      deterrentSound: DeterrentSound.fislama,
      isActive: true,
    ),
    CatProfile(
      id: 'cat_3',
      name: 'Mochi',
      avatarPath: '',
      beaconId: 'PX-7743-C',
      deterrentSound: DeterrentSound.yuksekFrekans,
      isActive: true,
    ),
  ];

  static List<ViolationRecord> get violations {
    final now = DateTime.now();
    return [
      ViolationRecord(
        id: 'v1',
        catId: 'cat_1',
        roomUnitId: 'room_1',
        zoneName: 'Mutfak Bölgesi',
        rssiValue: -45,
        status: CatStatus.ihlal,
        timestamp: now.subtract(const Duration(hours: 1, minutes: 15)),
        durationSeconds: 25,
      ),
      ViolationRecord(
        id: 'v2',
        catId: 'cat_2',
        roomUnitId: 'room_2',
        zoneName: 'Yatak Odası',
        rssiValue: -55,
        status: CatStatus.uyari,
        timestamp: now.subtract(const Duration(hours: 2, minutes: 30)),
        durationSeconds: 12,
      ),
      ViolationRecord(
        id: 'v3',
        catId: 'cat_1',
        roomUnitId: 'room_1',
        zoneName: 'Mutfak Bölgesi',
        rssiValue: -48,
        status: CatStatus.ihlal,
        timestamp: now.subtract(const Duration(hours: 4)),
        durationSeconds: 18,
      ),
      ViolationRecord(
        id: 'v4',
        catId: 'cat_3',
        roomUnitId: 'room_3',
        zoneName: 'Çalışma Odası',
        rssiValue: -50,
        status: CatStatus.ihlal,
        timestamp: now.subtract(const Duration(hours: 5, minutes: 45)),
        durationSeconds: 30,
      ),
      ViolationRecord(
        id: 'v5',
        catId: 'cat_2',
        roomUnitId: 'room_1',
        zoneName: 'Mutfak Bölgesi',
        rssiValue: -58,
        status: CatStatus.uyari,
        timestamp: now.subtract(const Duration(hours: 8)),
        durationSeconds: 8,
      ),
      ViolationRecord(
        id: 'v6',
        catId: 'cat_1',
        roomUnitId: 'room_2',
        zoneName: 'Yatak Odası',
        rssiValue: -42,
        status: CatStatus.ihlal,
        timestamp: now.subtract(const Duration(days: 1, hours: 3)),
        durationSeconds: 22,
      ),
      ViolationRecord(
        id: 'v7',
        catId: 'cat_3',
        roomUnitId: 'room_1',
        zoneName: 'Mutfak Bölgesi',
        rssiValue: -65,
        status: CatStatus.guvenli,
        timestamp: now.subtract(const Duration(days: 1, hours: 6)),
        durationSeconds: 0,
      ),
      ViolationRecord(
        id: 'v8',
        catId: 'cat_1',
        roomUnitId: 'room_3',
        zoneName: 'Çalışma Odası',
        rssiValue: -47,
        status: CatStatus.ihlal,
        timestamp: now.subtract(const Duration(days: 2)),
        durationSeconds: 15,
      ),
    ];
  }
}
