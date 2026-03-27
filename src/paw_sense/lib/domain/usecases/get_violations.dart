import '../entities/violation_record.dart';
import '../repositories/violation_repository.dart';

class GetViolations {
  final ViolationRepository repository;

  GetViolations(this.repository);

  Future<List<ViolationRecord>> call({String? catId}) async {
    if (catId != null) {
      return await repository.getViolationsByCatId(catId);
    }
    return await repository.getAllViolations();
  }

  Future<List<ViolationRecord>> inRange(DateTime start, DateTime end) async {
    return await repository.getViolationsInRange(start, end);
  }
}
