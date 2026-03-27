import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'data/datasources/local/demo_data.dart';
import 'data/repositories/mock_cat_repository.dart';
import 'data/repositories/mock_violation_repository.dart';
import 'domain/usecases/get_cats.dart';
import 'domain/usecases/add_cat.dart';
import 'domain/usecases/get_violations.dart';
import 'presentation/providers/dashboard_provider.dart';
import 'presentation/providers/cat_provider.dart';
import 'presentation/providers/violation_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('tr_TR', null);

  // In-memory repositories (web uyumlu)
  final catRepository = MockCatRepository();
  final violationRepository = MockViolationRepository();

  // Demo verileri yükle
  for (final cat in DemoData.cats) {
    await catRepository.addCat(cat);
  }
  for (final violation in DemoData.violations) {
    await violationRepository.addViolation(violation);
  }

  // Use cases
  final getCats = GetCats(catRepository);
  final addCat = AddCat(catRepository);
  final getViolations = GetViolations(violationRepository);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => DashboardProvider()..loadDemoLiveData(),
        ),
        ChangeNotifierProvider(
          create: (_) => CatProvider(
            getCats: getCats,
            addCat: addCat,
          )..loadCats(),
        ),
        ChangeNotifierProvider(
          create: (_) => ViolationProvider(
            getViolations: getViolations,
          )..loadViolations(),
        ),
      ],
      child: const PawSenseApp(),
    ),
  );
}
