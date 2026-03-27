import '../repositories/ble_repository.dart';

class StartBleScan {
  final BleRepository repository;

  StartBleScan(this.repository);

  Future<void> call() async {
    await repository.startScan();
  }

  Future<void> stop() async {
    await repository.stopScan();
  }
}
