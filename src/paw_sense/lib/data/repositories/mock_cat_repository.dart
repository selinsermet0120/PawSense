import '../../domain/entities/cat_profile.dart';
import '../../domain/repositories/cat_repository.dart';

class MockCatRepository implements CatRepository {
  final List<CatProfile> _cats = [];

  @override
  Future<List<CatProfile>> getAllCats() async => List.unmodifiable(_cats);

  @override
  Future<CatProfile?> getCatById(String id) async {
    final match = _cats.where((c) => c.id == id);
    return match.isNotEmpty ? match.first : null;
  }

  @override
  Future<CatProfile?> getCatByBeaconId(String beaconId) async {
    final match = _cats.where((c) => c.beaconId == beaconId);
    return match.isNotEmpty ? match.first : null;
  }

  @override
  Future<void> addCat(CatProfile cat) async {
    _cats.add(cat);
  }

  @override
  Future<void> updateCat(CatProfile cat) async {
    final index = _cats.indexWhere((c) => c.id == cat.id);
    if (index != -1) {
      _cats[index] = cat;
    }
  }

  @override
  Future<void> deleteCat(String id) async {
    _cats.removeWhere((c) => c.id == id);
  }
}
