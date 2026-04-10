import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/enums/cat_status.dart';
import '../../core/enums/system_mode.dart';
import '../../data/datasources/local/notification_service.dart';
import '../../data/datasources/remote/supabase_realtime_service.dart';
import '../../data/models/violation_record_model.dart';
import '../../domain/entities/cat_profile.dart';

class LiveCatData {
  final String catId;
  final String catName;
  final String zoneName;
  final int rssi;
  final CatStatus status;

  const LiveCatData({
    required this.catId,
    required this.catName,
    required this.zoneName,
    required this.rssi,
    required this.status,
  });
}

class DashboardProvider extends ChangeNotifier {
  final SupabaseClient _client;
  final NotificationService _notificationService;
  final bool Function() _isNotificationsEnabled;

  SystemMode _currentMode = SystemMode.tarama;
  bool _isLive = true;
  List<LiveCatData> _liveCats = [];

  /// Kedi ID → profil eşleştirmesi (CatProvider'dan güncellenir)
  Map<String, CatProfile> _catMap = {};

  /// Son ihlal verileri (kedi ID → ihlal bilgisi)
  Map<String, LiveCatData> _violationStatus = {};

  DashboardProvider({
    required SupabaseClient client,
    required NotificationService notificationService,
    required bool Function() isNotificationsEnabled,
  })  : _client = client,
        _notificationService = notificationService,
        _isNotificationsEnabled = isNotificationsEnabled;

  SystemMode get currentMode => _currentMode;
  bool get isLive => _isLive;
  List<LiveCatData> get liveCats => _liveCats;

  /// CatProvider'dan kedi listesini güncelle ve kartları yeniden oluştur
  void updateCatMap(List<CatProfile> cats) {
    _catMap = {for (final cat in cats) cat.id: cat};
    _rebuildLiveCats();
  }

  /// Supabase'den kedileri doğrudan yükle (user_id filtresi yok)
  Future<void> loadCats() async {
    try {
      final data = await _client.from('cats').select();
      _catMap = {};
      for (final row in data) {
        final id = row['id'] as String;
        _catMap[id] = CatProfile(
          id: id,
          name: row['name'] as String,
          avatarPath: (row['avatar_url'] as String?) ?? '',
          beaconId: (row['beacon_id'] as String?) ?? '',
          rssiThreshold: (row['rssi_threshold'] as int?) ?? -55,
        );
      }
    } catch (e) {
      debugPrint('DashboardProvider.loadCats hata: $e');
    }
    _rebuildLiveCats();
  }

  /// Tüm kedileri göster, ihlal verisi varsa overlay et
  void _rebuildLiveCats() {
    _liveCats = _catMap.values.map((cat) {
      // Bu kedi için aktif ihlal var mı?
      final violation = _violationStatus[cat.id];
      if (violation != null) {
        return LiveCatData(
          catId: cat.id,
          catName: cat.name,
          zoneName: violation.zoneName,
          rssi: violation.rssi,
          status: violation.status,
        );
      }
      // İhlal yoksa GÜVENLİ
      return LiveCatData(
        catId: cat.id,
        catName: cat.name,
        zoneName: '—',
        rssi: 0,
        status: CatStatus.guvenli,
      );
    }).toList();
    notifyListeners();
  }

  void setMode(SystemMode mode) {
    _currentMode = mode;
    notifyListeners();
  }

  void toggleLive() {
    _isLive = !_isLive;
    notifyListeners();
  }

  void setLiveCats(List<LiveCatData> cats) {
    _liveCats = cats;
    notifyListeners();
  }

  /// Supabase'den her kedi için son ihlal kaydını yükle
  Future<void> loadLiveCats() async {
    try {
      final data = await _client
          .from('violations')
          .select()
          .order('created_at', ascending: false);

      // Her kedi için en son kaydı al
      _violationStatus = {};
      for (final row in data) {
        final catId = row['cat_id'] as String;
        if (!_violationStatus.containsKey(catId)) {
          try {
            final record = ViolationRecordModel.fromMap(row);
            final catName = _catMap[record.catId]?.name ?? 'Bilinmeyen';
            _violationStatus[catId] = LiveCatData(
              catId: record.catId,
              catName: catName,
              zoneName: record.zoneName,
              rssi: record.rssiValue,
              status: record.status,
            );
          } catch (e) {
            debugPrint('Violation parse hata: $e');
          }
        }
      }
    } catch (e) {
      debugPrint('DashboardProvider.loadLiveCats hata: $e');
    }

    _rebuildLiveCats();
  }

  /// Room unit durumlarından sistem modunu belirle
  Future<void> loadSystemMode() async {
    try {
      final data = await _client.from('room_units').select('status');
      if (data.isEmpty) return;

      bool hasActive = false;
      bool hasCooldown = false;

      for (final row in data) {
        final status = (row['status'] as String?) ?? 'idle';
        if (status == 'active') hasActive = true;
        if (status == 'cooldown') hasCooldown = true;
      }

      if (hasActive) {
        _currentMode = SystemMode.tarama;
      } else if (hasCooldown) {
        _currentMode = SystemMode.caydirici;
      } else {
        _currentMode = SystemMode.bekle;
      }
      notifyListeners();
    } catch (e) {
      debugPrint('DashboardProvider.loadSystemMode hata: $e');
    }
  }

  /// Realtime aboneliklerini başlat
  void subscribeToRealtime(SupabaseRealtimeService service) {
    // Violations tablosunu dinle → canlı kedi kartları
    service.subscribe(
      subscriberName: 'dashboard',
      table: 'violations',
      onInsert: (payload) {
        debugPrint('Yeni ihlal kaydı geldi: ${payload.newRecord}');
        _handleNewViolation(payload.newRecord);
      },
      onUpdate: (payload) {
        debugPrint('İhlal kaydı güncellendi: ${payload.newRecord}');
        _handleNewViolation(payload.newRecord);
      },
    );

    // Room units tablosunu dinle → sistem modu
    service.subscribe(
      subscriberName: 'dashboard',
      table: 'room_units',
      onUpdate: (payload) {
        debugPrint('Room unit durumu değişti: ${payload.newRecord}');
        loadSystemMode();
      },
    );

    // Cats tablosunu dinle → kedi listesini güncelle
    service.subscribe(
      subscriberName: 'dashboard_cats',
      table: 'cats',
      onInsert: (payload) {
        debugPrint('Dashboard: Yeni kedi eklendi');
        loadCats();
      },
      onUpdate: (payload) {
        debugPrint('Dashboard: Kedi güncellendi');
        loadCats();
      },
      onDelete: (payload) {
        debugPrint('Dashboard: Kedi silindi');
        loadCats();
      },
    );
  }

  /// Yeni ihlal kaydını işle ve canlı kartları güncelle
  void _handleNewViolation(Map<String, dynamic> record) {
    try {
      final violation = ViolationRecordModel.fromMap(record);
      final catName = _catMap[violation.catId]?.name ?? 'Bilinmeyen';

      _violationStatus[violation.catId] = LiveCatData(
        catId: violation.catId,
        catName: catName,
        zoneName: violation.zoneName,
        rssi: violation.rssiValue,
        status: violation.status,
      );

      // Bildirim gönder (uyarı veya ihlal durumlarında)
      if (_isNotificationsEnabled() &&
          violation.status != CatStatus.guvenli) {
        _notificationService.showViolationNotification(
          catName: catName,
          zoneName: violation.zoneName,
          rssiValue: violation.rssiValue,
        );
      }

      _rebuildLiveCats();
    } catch (e) {
      debugPrint('DashboardProvider._handleNewViolation hata: $e');
    }
  }
}
