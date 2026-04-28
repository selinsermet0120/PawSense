import 'package:flutter/foundation.dart';
import '../../data/datasources/remote/supabase_realtime_service.dart';
import '../../domain/entities/violation_record.dart';
import '../../domain/usecases/get_violations.dart';

class ViolationProvider extends ChangeNotifier {
  final GetViolations _getViolations;

  List<ViolationRecord> _allViolations = [];
  String? _selectedCatId;
  bool _isLoading = false;
  String? _errorMessage;

  ViolationProvider({required GetViolations getViolations})
      : _getViolations = getViolations;

  String? get errorMessage => _errorMessage;
  void clearError() {
    _errorMessage = null;
  }

  /// Filtrelenmiş liste (geçmiş ekranı için)
  List<ViolationRecord> get violations {
    if (_selectedCatId != null) {
      return _allViolations
          .where((v) => v.catId == _selectedCatId)
          .toList();
    }
    return _allViolations;
  }

  /// Tüm ihlaller (filtre uygulanmamış — davranış analizi için)
  List<ViolationRecord> get allViolations => _allViolations;

  String? get selectedCatId => _selectedCatId;
  bool get isLoading => _isLoading;

  Future<void> loadViolations() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _allViolations = await _getViolations(catId: null);
    } catch (e) {
      debugPrint('ViolationProvider.loadViolations hata: $e');
      _errorMessage = _friendlyError(e, 'Geçmiş yüklenemedi');
      _allViolations = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadViolationsInRange(DateTime start, DateTime end) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _allViolations = await _getViolations.inRange(start, end);
    } catch (e) {
      debugPrint('ViolationProvider.loadViolationsInRange hata: $e');
      _errorMessage = _friendlyError(e, 'Geçmiş yüklenemedi');
      _allViolations = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  String _friendlyError(Object e, String prefix) {
    final msg = e.toString().toLowerCase();
    if (msg.contains('socket') ||
        msg.contains('network') ||
        msg.contains('failed host lookup') ||
        msg.contains('timeout')) {
      return '$prefix: internet bağlantınızı kontrol edin.';
    }
    return '$prefix: sunucu hatası.';
  }

  void filterByCat(String? catId) {
    _selectedCatId = catId;
    notifyListeners();
  }

  /// Violations tablosu realtime aboneliği — Geçmiş ekranı otomatik güncellenir
  void subscribeToRealtime(SupabaseRealtimeService service) {
    service.subscribe(
      subscriberName: 'violations',
      table: 'violations',
      onInsert: (payload) {
        debugPrint('Yeni ihlal (geçmiş): ${payload.newRecord}');
        loadViolations();
      },
      onUpdate: (payload) {
        debugPrint('İhlal güncellendi (geçmiş): ${payload.newRecord}');
        loadViolations();
      },
      onDelete: (payload) {
        debugPrint('İhlal silindi (geçmiş): ${payload.oldRecord}');
        loadViolations();
      },
    );
  }
}
