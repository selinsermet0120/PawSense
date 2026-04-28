import 'package:flutter/foundation.dart';
import '../../data/datasources/remote/supabase_realtime_service.dart';
import '../../domain/entities/cat_profile.dart';
import '../../domain/repositories/cat_repository.dart';
import '../../domain/usecases/get_cats.dart';
import '../../domain/usecases/add_cat.dart';

class CatProvider extends ChangeNotifier {
  final GetCats _getCats;
  final AddCat _addCat;
  final CatRepository _catRepository;

  List<CatProfile> _cats = [];
  bool _isLoading = false;
  String? _errorMessage;

  void Function(List<CatProfile>)? onCatsChanged;

  CatProvider({
    required GetCats getCats,
    required AddCat addCat,
    required CatRepository catRepository,
  })  : _getCats = getCats,
        _addCat = addCat,
        _catRepository = catRepository;

  List<CatProfile> get cats => _cats;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void clearError() {
    _errorMessage = null;
  }

  Future<void> loadCats() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _cats = await _getCats();
    } catch (e) {
      debugPrint('CatProvider.loadCats hata: $e');
      _errorMessage = _friendlyError(e, 'Kediler yüklenemedi');
      _cats = [];
    }

    _isLoading = false;
    notifyListeners();
    onCatsChanged?.call(_cats);
  }

  Future<void> addCat(CatProfile cat) async {
    try {
      await _addCat(cat);
    } catch (e) {
      debugPrint('CatProvider.addCat hata: $e');
      _errorMessage = _friendlyError(e, 'Kedi eklenemedi');
      notifyListeners();
      rethrow;
    }
    await loadCats();
  }

  /// Fotoğraflı kedi ekleme: önce Supabase Storage'a yükle, sonra avatar_url ile kaydet
  Future<void> addCatWithImage({
    required CatProfile cat,
    required Uint8List? imageBytes,
    required String? fileName,
  }) async {
    String avatarUrl = '';

    try {
      if (imageBytes != null && fileName != null) {
        final url = await _catRepository.uploadCatImage(cat.id, imageBytes, fileName);
        if (url != null) avatarUrl = url;
      }

      final catWithAvatar = cat.copyWith(avatarPath: avatarUrl);
      await _addCat(catWithAvatar);
    } catch (e) {
      debugPrint('CatProvider.addCatWithImage hata: $e');
      _errorMessage = _friendlyError(e, 'Kedi eklenemedi');
      notifyListeners();
      rethrow;
    }
    await loadCats();
  }

  /// Kedi bilgilerini güncelle (opsiyonel yeni fotoğraf ile).
  Future<void> updateCat({
    required CatProfile cat,
    Uint8List? imageBytes,
    String? fileName,
  }) async {
    try {
      var updated = cat;
      if (imageBytes != null && fileName != null) {
        final url = await _catRepository.uploadCatImage(cat.id, imageBytes, fileName);
        if (url != null) updated = cat.copyWith(avatarPath: url);
      }
      await _catRepository.updateCat(updated);
    } catch (e) {
      debugPrint('CatProvider.updateCat hata: $e');
      _errorMessage = _friendlyError(e, 'Kedi güncellenemedi');
      notifyListeners();
      rethrow;
    }
    await loadCats();
  }

  /// Kedi kaydını sil.
  Future<void> deleteCat(String catId) async {
    try {
      await _catRepository.deleteCat(catId);
    } catch (e) {
      debugPrint('CatProvider.deleteCat hata: $e');
      _errorMessage = _friendlyError(e, 'Kedi silinemedi');
      notifyListeners();
      rethrow;
    }
    await loadCats();
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

  void subscribeToRealtime(SupabaseRealtimeService service) {
    service.subscribe(
      subscriberName: 'cats',
      table: 'cats',
      onInsert: (payload) {
        debugPrint('Yeni kedi eklendi: ${payload.newRecord}');
        loadCats();
      },
      onUpdate: (payload) {
        debugPrint('Kedi güncellendi: ${payload.newRecord}');
        loadCats();
      },
      onDelete: (payload) {
        debugPrint('Kedi silindi: ${payload.oldRecord}');
        loadCats();
      },
    );
  }
}
