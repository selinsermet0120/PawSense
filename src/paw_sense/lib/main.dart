import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'data/datasources/ble/ble_scanner.dart';
import 'data/datasources/local/notification_service.dart';
import 'data/datasources/remote/supabase_datasource.dart';
import 'data/datasources/remote/supabase_realtime_service.dart';
import 'data/repositories/ble_repository_impl.dart';
import 'data/repositories/cat_repository_impl.dart';
import 'data/repositories/violation_repository_impl.dart';
import 'domain/usecases/get_cats.dart';
import 'domain/usecases/add_cat.dart';
import 'domain/usecases/get_violations.dart';
import 'domain/usecases/start_ble_scan.dart';
import 'domain/usecases/evaluate_rssi.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/ble_provider.dart';
import 'presentation/providers/dashboard_provider.dart';
import 'presentation/providers/cat_provider.dart';
import 'presentation/providers/settings_provider.dart';
import 'presentation/providers/violation_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('tr_TR', null);

  // Supabase başlat — tüm bağlantı hatalarını detaylı logla.
  // Kritik bağlantı hatasında crash yerine kullanıcıya bilgilendirici ekran göster.
  try {
    await SupabaseDatasource.initialize();
  } catch (e, st) {
    developer.log(
      '❌ Supabase başlatma sırasında kritik hata oluştu.',
      name: 'main',
      error: e,
      stackTrace: st,
      level: 1200,
    );
    if (kDebugMode) {
      debugPrint('[main][FATAL] Supabase başlatma hatası: $e');
      debugPrint(st.toString());
    }
    runApp(_SupabaseInitErrorApp(error: e));
    return;
  }

  // Settings'i yükle (Supabase client ile — kullanıcı metadata'sından da okur)
  final settingsProvider = SettingsProvider(client: SupabaseDatasource.client);
  await settingsProvider.load();

  // Bildirim servisini başlat
  final notificationService = NotificationService();
  await notificationService.initialize();


  // Supabase repository'ler
  final client = SupabaseDatasource.client;
  final catRepository = CatRepositoryImpl(client);
  final violationRepository = ViolationRepositoryImpl(client);

  // Use cases
  final getCats = GetCats(catRepository);
  final addCat = AddCat(catRepository);
  final getViolations = GetViolations(violationRepository);

  // BLE
  final bleScanner = BleScanner();
  final bleRepository = BleRepositoryImpl(bleScanner);
  final startBleScan = StartBleScan(bleRepository);
  final evaluateRssi = EvaluateRssi();


  // Realtime servisi
  final realtimeService = SupabaseRealtimeService(client);

  // Auth provider
  final authProvider = AuthProvider(client);

  // Provider'lar
  final dashboardProvider = DashboardProvider(
    client: client,
    notificationService: notificationService,
    isNotificationsEnabled: () => settingsProvider.notificationsEnabled,
  );
  final catProvider = CatProvider(
    getCats: getCats,
    addCat: addCat,
    catRepository: catRepository,
  );
  final violationProvider = ViolationProvider(getViolations: getViolations);
  final bleProvider = BleProvider(
    startBleScan: startBleScan,
    evaluateRssi: evaluateRssi,
    bleScanner: bleScanner,
  );

  // Kedi listesi değiştiğinde dashboard'un catMap'ini güncelle
  catProvider.onCatsChanged = (cats) {
    dashboardProvider.updateCatMap(cats);
  };

  // İlk verileri yükle (kullanıcı oturum açıksa)
  if (authProvider.isLoggedIn) {
    await catProvider.loadCats();
    await dashboardProvider.loadCats();
    dashboardProvider.loadLiveCats();
    dashboardProvider.loadSystemMode();
    violationProvider.loadViolations();

    catProvider.subscribeToRealtime(realtimeService);
    dashboardProvider.subscribeToRealtime(realtimeService);
    violationProvider.subscribeToRealtime(realtimeService);
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: settingsProvider),
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider.value(value: dashboardProvider),
        ChangeNotifierProvider.value(value: catProvider),
        ChangeNotifierProvider.value(value: violationProvider),
        ChangeNotifierProvider.value(value: bleProvider),
      ],
      child: PawSenseApp(
        realtimeService: realtimeService,
        dashboardProvider: dashboardProvider,
        catProvider: catProvider,
        violationProvider: violationProvider,
      ),
    ),
  );
}

String _supabaseFriendlyError(Object e) {
  final msg = e.toString().toLowerCase();
  if (msg.contains('socket') ||
      msg.contains('network') ||
      msg.contains('failed host lookup') ||
      msg.contains('timeout') ||
      msg.contains('connection')) {
    return 'Sunucuya ulaşılamıyor. İnternet bağlantınızı kontrol edip tekrar deneyin.';
  }
  if (msg.contains('.env') || msg.contains('supabase_url') || msg.contains('supabase_anon_key')) {
    return 'Yapılandırma eksik: Supabase URL veya anahtarı bulunamadı.';
  }
  return 'Sunucu başlatılamadı. Lütfen daha sonra tekrar deneyin.';
}

class _SupabaseInitErrorApp extends StatelessWidget {
  final Object error;
  const _SupabaseInitErrorApp({required this.error});

  @override
  Widget build(BuildContext context) {
    final message = _supabaseFriendlyError(error);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFFEBF0EF),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.cloud_off_outlined,
                      size: 64, color: Color(0xFFB07A4E)),
                  const SizedBox(height: 16),
                  const Text(
                    'PawSense bağlantı kuramadı',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    message,
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.refresh),
                    label: const Text('Tekrar Dene'),
                    onPressed: () => main(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
