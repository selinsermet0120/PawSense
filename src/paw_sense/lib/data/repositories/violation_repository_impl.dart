import '../../domain/entities/violation_record.dart';
import '../../domain/repositories/violation_repository.dart';
import '../datasources/local/database_helper.dart';
import '../models/violation_record_model.dart';

class ViolationRepositoryImpl implements ViolationRepository {
  final DatabaseHelper _databaseHelper;

  ViolationRepositoryImpl(this._databaseHelper);

  @override
  Future<List<ViolationRecord>> getAllViolations() async {
    final db = await _databaseHelper.database;
    final maps = await db.query('violations', orderBy: 'timestamp DESC');
    return maps.map((map) => ViolationRecordModel.fromMap(map)).toList();
  }

  @override
  Future<List<ViolationRecord>> getViolationsByCatId(String catId) async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      'violations',
      where: 'cat_id = ?',
      whereArgs: [catId],
      orderBy: 'timestamp DESC',
    );
    return maps.map((map) => ViolationRecordModel.fromMap(map)).toList();
  }

  @override
  Future<List<ViolationRecord>> getViolationsInRange(
    DateTime start,
    DateTime end,
  ) async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      'violations',
      where: 'timestamp >= ? AND timestamp <= ?',
      whereArgs: [
        start.millisecondsSinceEpoch,
        end.millisecondsSinceEpoch,
      ],
      orderBy: 'timestamp DESC',
    );
    return maps.map((map) => ViolationRecordModel.fromMap(map)).toList();
  }

  @override
  Future<void> addViolation(ViolationRecord record) async {
    final db = await _databaseHelper.database;
    final model = ViolationRecordModel.fromEntity(record);
    await db.insert('violations', model.toMap());
  }

  @override
  Future<void> deleteViolation(String id) async {
    final db = await _databaseHelper.database;
    await db.delete('violations', where: 'id = ?', whereArgs: [id]);
  }
}
