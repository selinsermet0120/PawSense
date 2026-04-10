import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Yerel bildirim yönetim servisi.
/// Uygulama arka planda olsa bile bildirim gösterir.
class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Bildirim kanalı ve ayarlarını başlat.
  Future<void> initialize() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const initSettings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(initSettings);

    // Android 13+ bildirim izni iste
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    _initialized = true;
    debugPrint('NotificationService başlatıldı');
  }

  /// İhlal bildirimi göster.
  /// Örnek: "Luna mutfağa girmeye çalışıyor! (-45 dBm)"
  Future<void> showViolationNotification({
    required String catName,
    required String zoneName,
    required int rssiValue,
    int? notificationId,
  }) async {
    if (!_initialized) return;

    const androidDetails = AndroidNotificationDetails(
      'paw_sense_violations',
      'İhlal Bildirimleri',
      channelDescription: 'Kedi ihlal tespit bildirimleri',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    const details = NotificationDetails(android: androidDetails);

    final id = notificationId ?? DateTime.now().millisecondsSinceEpoch ~/ 1000;

    await _plugin.show(
      id,
      'PawSense - İhlal Tespit Edildi!',
      '$catName $zoneName bölgesine girmeye çalışıyor! ($rssiValue dBm)',
      details,
    );
  }
}
