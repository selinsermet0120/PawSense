import 'dart:developer' as developer;
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/cat_profile.dart';
import '../../domain/repositories/cat_repository.dart';
import '../models/cat_profile_model.dart';

class CatRepositoryImpl implements CatRepository {
  final SupabaseClient _client;

  CatRepositoryImpl(this._client);

  Future<Map<String, int>> _getSoundTypes(List<String> catIds) async {
    if (catIds.isEmpty) return {};
    try {
      final data = await _client
          .from('cat_sounds')
          .select('cat_id, sound_type')
          .inFilter('cat_id', catIds);
      final map = <String, int>{};
      for (final row in data) {
        final catId = row['cat_id'] as String;
        final raw = row['sound_type'];
        final int? parsed = raw is int
            ? raw
            : (raw is num
                ? raw.toInt()
                : (raw is String ? int.tryParse(raw) : null));
        if (parsed != null) {
          map[catId] = parsed;
        }
      }
      return map;
    } catch (e) {
      developer.log(
        'cat_sounds okunamadı, varsayılan ses kullanılacak: $e',
        name: 'CatRepository',
      );
      return {};
    }
  }

  @override
  Future<List<CatProfile>> getAllCats() async {
    final data = await _client.from('cats').select();
    final catIds = data.map((m) => m['id'] as String).toList();
    final soundMap = await _getSoundTypes(catIds);
    return data.map((map) {
      final id = map['id'] as String;
      return CatProfileModel.fromMap(map, soundType: soundMap[id]);
    }).toList();
  }

  @override
  Future<CatProfile?> getCatById(String id) async {
    final data =
        await _client.from('cats').select().eq('id', id).maybeSingle();
    if (data == null) return null;
    final soundMap = await _getSoundTypes([id]);
    return CatProfileModel.fromMap(data, soundType: soundMap[id]);
  }

  @override
  Future<CatProfile?> getCatByBeaconId(String beaconId) async {
    final data = await _client
        .from('cats')
        .select()
        .eq('beacon_id', beaconId)
        .maybeSingle();
    if (data == null) return null;
    final id = data['id'] as String;
    final soundMap = await _getSoundTypes([id]);
    return CatProfileModel.fromMap(data, soundType: soundMap[id]);
  }

  @override
  Future<void> addCat(CatProfile cat) async {
    final model = CatProfileModel.fromEntity(cat);
    final basePayload = Map<String, dynamic>.from(model.toMap());
    final userId = _client.auth.currentUser?.id;
    final payloadWithUser = {
      ...basePayload,
      'user_id': ?userId,
    };

    try {
      await _client.from('cats').insert(payloadWithUser);
    } on PostgrestException catch (e) {
      // Şema user_id kolonunu içermiyorsa, kolonsuz tekrar dene
      final msg = e.message.toLowerCase();
      final isUserIdSchemaIssue = msg.contains('user_id') &&
          (msg.contains('column') ||
              msg.contains('schema') ||
              e.code == '42703' ||
              e.code == 'PGRST204');
      if (userId != null && isUserIdSchemaIssue) {
        developer.log(
          'cats tablosunda user_id yok, user_id olmadan ekleniyor: ${e.message}',
          name: 'CatRepository',
        );
        await _client.from('cats').insert(basePayload);
      } else {
        rethrow;
      }
    }

    try {
      await _client.from('cat_sounds').insert({
        'cat_id': cat.id,
        'sound_type': cat.deterrentSound.index,
      });
    } catch (e) {
      developer.log(
        'cat_sounds insert hatası göz ardı edildi: $e',
        name: 'CatRepository',
      );
    }
  }

  @override
  Future<void> updateCat(CatProfile cat) async {
    final model = CatProfileModel.fromEntity(cat);
    await _client.from('cats').update(model.toMap()).eq('id', cat.id);
    try {
      final existing = await _client
          .from('cat_sounds')
          .select('cat_id')
          .eq('cat_id', cat.id)
          .maybeSingle();
      if (existing == null) {
        await _client.from('cat_sounds').insert({
          'cat_id': cat.id,
          'sound_type': cat.deterrentSound.index,
        });
      } else {
        await _client
            .from('cat_sounds')
            .update({'sound_type': cat.deterrentSound.index})
            .eq('cat_id', cat.id);
      }
    } catch (e) {
      developer.log(
        'cat_sounds update hatası göz ardı edildi: $e',
        name: 'CatRepository',
      );
    }
  }

  @override
  Future<void> deleteCat(String id) async {
    await _client.from('cats').delete().eq('id', id);
  }

  @override
  Future<String?> uploadCatImage(String catId, Uint8List imageBytes, String fileName) async {
    try {
      final path = '$catId/$fileName';
      await _client.storage
          .from('cat-images')
          .uploadBinary(path, imageBytes, fileOptions: const FileOptions(upsert: true));
      return _client.storage.from('cat-images').getPublicUrl(path);
    } catch (e) {
      return null;
    }
  }
}
