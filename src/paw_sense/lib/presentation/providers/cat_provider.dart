import 'package:flutter/foundation.dart';
import '../../domain/entities/cat_profile.dart';
import '../../domain/usecases/get_cats.dart';
import '../../domain/usecases/add_cat.dart';

class CatProvider extends ChangeNotifier {
  final GetCats _getCats;
  final AddCat _addCat;

  List<CatProfile> _cats = [];
  bool _isLoading = false;

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

    _cats = await _getCats();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addCat(CatProfile cat) async {
    await _addCat(cat);
    await loadCats();
  }
}
