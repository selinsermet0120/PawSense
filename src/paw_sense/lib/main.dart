import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'data/datasources/remote/supabase_datasource.dart';
import 'data/datasources/remote/supabase_realtime_service.dart';
import 'data/repositories/cat_repository_impl.dart';
import 'data/repositories/violation_repository_impl.dart';
import 'domain/usecases/get_cats.dart';
import 'domain/usecases/add_cat.dart';
import 'domain/usecases/get_violations.dart';
import 'presentation/providers/auth_provider.dart';
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

  // Supabase repository'ler
  final client = SupabaseDatasource.client;
  final catRepository = CatRepositoryImpl(client);
  final violationRepository = ViolationRepositoryImpl(client);

  // Use cases
  final getCats = GetCats(catRepository);
  final addCat = AddCat(catRepository);
  final getViolations = GetViolations(violationRepository);

  // Realtime servisi
  final realtimeService = SupabaseRealtimeService(client);

  // Auth provider
  final authProvider = AuthProvider(client);

  // Provider'lar
  final dashboardProvider = DashboardProvider(client: client);
  final catProvider = CatProvider(
    getCats: getCats,
    addCat: addCat,
    catRepository: catRepository,
  );
  final violationProvider = ViolationProvider(getViolations: getViolations);

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
