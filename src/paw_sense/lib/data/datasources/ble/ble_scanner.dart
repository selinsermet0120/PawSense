import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BleScanner {
  StreamSubscription<List<ScanResult>>? _scanSubscription;
  final _resultsController = StreamController<List<ScanResult>>.broadcast();

  Stream<List<ScanResult>> get scanResults => _resultsController.stream;

  Future<void> startScan() async {
    await FlutterBluePlus.startScan(
      timeout: const Duration(seconds: 30),
      androidUsesFineLocation: true,
    );

    _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
      _resultsController.add(results);
    });
  }

  Future<void> stopScan() async {
    await FlutterBluePlus.stopScan();
    await _scanSubscription?.cancel();
    _scanSubscription = null;
  }

  Future<bool> isAvailable() async {
    return await FlutterBluePlus.isSupported;
  }

  Stream<bool> get isScanning => FlutterBluePlus.isScanning;

  void dispose() {
    _scanSubscription?.cancel();
    _resultsController.close();
  }
}
