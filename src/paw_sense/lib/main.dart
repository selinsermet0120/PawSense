import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'app.dart';
<<<<<<< HEAD
import 'data/datasources/remote/supabase_datasource.dart';
import 'data/datasources/remote/supabase_realtime_service.dart';
=======
import 'data/datasources/ble/ble_scanner.dart';
import 'data/datasources/local/notification_service.dart';
import 'data/datasources/remote/supabase_datasource.dart';
import 'data/datasources/remote/supabase_realtime_service.dart';
import 'data/repositories/ble_repository_impl.dart';
>>>>>>> 184ff44f924bd06e13a586a090c5eb8a61f31d0c
import 'data/repositories/cat_repository_impl.dart';
import 'data/repositories/violation_repository_impl.dart';
import 'domain/usecases/get_cats.dart';
import 'domain/usecases/add_cat.dart';
import 'domain/usecases/get_violations.dart';
<<<<<<< HEAD
import 'presentation/providers/auth_provider.dart';
=======
import 'domain/usecases/start_ble_scan.dart';
import 'domain/usecases/evaluate_rssi.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/ble_provider.dart';
>>>>>>> 184ff44f924bd06e13a586a090c5eb8a61f31d0c
import 'presentation/providers/dashboard_provider.dart';
import 'presentation/providers/cat_provider.dart';
import 'presentation/providers/settings_provider.dart';
import 'presentation/providers/violation_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('tr_TR', null);

  // Supabase başlat
  await SupabaseDatasource.initialize();

  // Settings'i yükle
  final settingsProvider = SettingsProvider();
  await settingsProvider.load();

<<<<<<< HEAD
=======
  // Bildirim servisini başlat
  final notificationService = NotificationService();
  await notificationService.initialize();

>>>>>>> 184ff44f924bd06e13a586a090c5eb8a61f31d0c
  // Supabase repository'ler
  final client = SupabaseDatasource.client;
  final catRepository = CatRepositoryImpl(client);
  final violationRepository = ViolationRepositoryImpl(client);

  // Use cases
  final getCats = GetCats(catRepository);
  final addCat = AddCat(catRepository);
  final getViolations = GetViolations(violationRepository);

<<<<<<< HEAD
=======
  // BLE
  final bleScanner = BleScanner();
  final bleRepository = BleRepositoryImpl(bleScanner);
  final startBleScan = StartBleScan(bleRepository);
  final evaluateRssi = EvaluateRssi();

>>>>>>> 184ff44f924bd06e13a586a090c5eb8a61f31d0c
  // Realtime servisi
  final realtimeService = SupabaseRealtimeService(client);

  // Auth provider
  final authProvider = AuthProvider(client);

  // Provider'lar
<<<<<<< HEAD
  final dashboardProvider = DashboardProvider(client: client);
=======
  final dashboardProvider = DashboardProvider(
    client: client,
    notificationService: notificationService,
    isNotificationsEnabled: () => settingsProvider.notificationsEnabled,
  );
>>>>>>> 184ff44f924bd06e13a586a090c5eb8a61f31d0c
  final catProvider = CatProvider(
    getCats: getCats,
    addCat: addCat,
    catRepository: catRepository,
  );
  final violationProvider = ViolationProvider(getViolations: getViolations);
<<<<<<< HEAD
=======
  final bleProvider = BleProvider(
    startBleScan: startBleScan,
    evaluateRssi: evaluateRssi,
    bleScanner: bleScanner,
  );
>>>>>>> 184ff44f924bd06e13a586a090c5eb8a61f31d0c

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
<<<<<<< HEAD
=======
        ChangeNotifierProvider.value(value: bleProvider),
>>>>>>> 184ff44f924bd06e13a586a090c5eb8a61f31d0c
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
