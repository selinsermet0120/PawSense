import '../../domain/entities/violation_record.dart';
import '../../domain/repositories/violation_repository.dart';

class MockViolationRepository implements ViolationRepository {
  final List<ViolationRecord> _violations = [];

  @override
  Future<List<ViolationRecord>> getAllViolations() async {
    final sorted = List<ViolationRecord>.from(_violations)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return sorted;
  }

  @override
  Future<List<ViolationRecord>> getViolationsByCatId(String catId) async {
    final filtered = _violations.where((v) => v.catId == catId).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return filtered;
  }

  @override
  Future<List<ViolationRecord>> getViolationsInRange(
    DateTime start,
    DateTime end,
  ) async {
    final filtered = _violations
        .where((v) =>
            v.timestamp.isAfter(start) && v.timestamp.isBefore(end))
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return filtered;
  }

  @override
  Future<void> addViolation(ViolationRecord record) async {
    _violations.add(record);
  }

  @override
  Future<void> deleteViolation(String id) async {
    _violations.removeWhere((v) => v.id == id);
  }
}
