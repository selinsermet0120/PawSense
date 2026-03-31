import 'package:flutter/foundation.dart';
import '../../data/datasources/remote/supabase_realtime_service.dart';
import '../../domain/entities/cat_profile.dart';
import '../../domain/usecases/get_cats.dart';
import '../../domain/usecases/add_cat.dart';

class CatProvider extends ChangeNotifier {
  final GetCats _getCats;
  final AddCat _addCat;

  List<CatProfile> _cats = [];
  bool _isLoading = false;

  /// Kedi listesi değiştiğinde çağrılacak callback
  /// (DashboardProvider'ın catMap'ini güncellemek için)
  void Function(List<CatProfile>)? onCatsChanged;

  CatProvider({
    required GetCats getCats,
    required AddCat addCat,
  })  : _getCats = getCats,
        _addCat = addCat;

  List<CatProfile> get cats => _cats;
  bool get isLoading => _isLoading;

  Future<void> loadCats() async {
    _isLoading = true;
    notifyListeners();

    try {
      _cats = await _getCats();
    } catch (e) {
      debugPrint('CatProvider.loadCats hata: $e');
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
    }
    await loadCats();
  }

  /// Cats tablosu realtime aboneliği
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
