import '../entities/violation_record.dart';

abstract class ViolationRepository {
  Future<List<ViolationRecord>> getAllViolations();
  Future<List<ViolationRecord>> getViolationsByCatId(String catId);
  Future<List<ViolationRecord>> getViolationsInRange(
    DateTime start,
    DateTime end,
  );
  Future<void> addViolation(ViolationRecord record);
  Future<void> deleteViolation(String id);
}
