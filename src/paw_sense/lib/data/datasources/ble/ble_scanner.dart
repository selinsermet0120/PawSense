import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BleScanner {
  StreamSubscription<List<ScanResult>>? _scanSubscription;
  final _resultsController = StreamController<List<ScanResult>>.broadcast();

  Stream<List<ScanResult>> get scanResults => _resultsController.stream;

  Future<void> startScan({Duration timeout = const Duration(seconds: 15)}) async {
    if (kIsWeb) return;

    // Önceki taramayı temizle
    await stopScan();

    await FlutterBluePlus.startScan(
      timeout: timeout,
      androidUsesFineLocation: true,
    );

    _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
      _resultsController.add(results);
    });
  }

  Future<void> stopScan() async {
    if (kIsWeb) return;

    try {
      await FlutterBluePlus.stopScan();
    } catch (_) {}
    await _scanSubscription?.cancel();
    _scanSubscription = null;
  }

  Future<bool> isAvailable() async {
    if (kIsWeb) return false;
    return await FlutterBluePlus.isSupported;
  }

  Stream<bool> get isScanning => kIsWeb
      ? Stream.value(false)
      : FlutterBluePlus.isScanning;

  void dispose() {
    _scanSubscription?.cancel();
    _resultsController.close();
  }
}
