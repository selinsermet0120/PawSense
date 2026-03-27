import 'package:flutter/foundation.dart';
import '../../domain/entities/violation_record.dart';
import '../../domain/usecases/get_violations.dart';

class ViolationProvider extends ChangeNotifier {
  final GetViolations _getViolations;

  List<ViolationRecord> _violations = [];
  String? _selectedCatId;
  bool _isLoading = false;

  ViolationProvider({required GetViolations getViolations})
      : _getViolations = getViolations;

  List<ViolationRecord> get violations => _violations;
  String? get selectedCatId => _selectedCatId;
  bool get isLoading => _isLoading;

  Future<void> loadViolations() async {
    _isLoading = true;
    notifyListeners();

    _violations = await _getViolations(catId: _selectedCatId);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadViolationsInRange(DateTime start, DateTime end) async {
    _isLoading = true;
    notifyListeners();

    _violations = await _getViolations.inRange(start, end);

    _isLoading = false;
    notifyListeners();
  }

  void filterByCat(String? catId) {
    _selectedCatId = catId;
    loadViolations();
  }
}
