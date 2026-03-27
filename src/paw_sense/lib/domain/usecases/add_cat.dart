import '../entities/cat_profile.dart';
import '../repositories/cat_repository.dart';

class AddCat {
  final CatRepository repository;

  AddCat(this.repository);

  Future<void> call(CatProfile cat) async {
    await repository.addCat(cat);
  }
}
