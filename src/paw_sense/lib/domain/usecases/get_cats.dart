import '../entities/cat_profile.dart';
import '../repositories/cat_repository.dart';

class GetCats {
  final CatRepository repository;

  GetCats(this.repository);

  Future<List<CatProfile>> call() async {
    return await repository.getAllCats();
  }
}
