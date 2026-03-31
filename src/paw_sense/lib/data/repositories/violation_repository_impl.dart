import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/violation_record.dart';
import '../../domain/repositories/violation_repository.dart';
import '../models/violation_record_model.dart';

class ViolationRepositoryImpl implements ViolationRepository {
  final SupabaseClient _client;

  ViolationRepositoryImpl(this._client);

  @override
  Future<List<ViolationRecord>> getAllViolations() async {
    final data = await _client
        .from('violations')
        .select()
        .order('created_at', ascending: false);
    return data.map((map) => ViolationRecordModel.fromMap(map)).toList();
  }

  @override
  Future<List<ViolationRecord>> getViolationsByCatId(String catId) async {
    final data = await _client
        .from('violations')
        .select()
        .eq('cat_id', catId)
        .order('created_at', ascending: false);
    return data.map((map) => ViolationRecordModel.fromMap(map)).toList();
  }

  @override
  Future<List<ViolationRecord>> getViolationsInRange(
    DateTime start,
    DateTime end,
  ) async {
    final data = await _client
        .from('violations')
        .select()
        .gte('created_at', start.toIso8601String())
        .lte('created_at', end.toIso8601String())
        .order('created_at', ascending: false);
    return data.map((map) => ViolationRecordModel.fromMap(map)).toList();
  }

  @override
  Future<void> addViolation(ViolationRecord record) async {
    final model = ViolationRecordModel.fromEntity(record);
    await _client.from('violations').insert(model.toMap());
  }

  @override
  Future<void> deleteViolation(String id) async {
    await _client.from('violations').delete().eq('id', id);
  }
}
