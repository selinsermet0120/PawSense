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
    final data = await _client
        .from('cat_sounds')
        .select('cat_id, sound_type')
        .inFilter('cat_id', catIds);
    final map = <String, int>{};
    for (final row in data) {
      map[row['cat_id'] as String] = row['sound_type'] as int;
    }
    return map;
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
    await _client.from('cats').insert(model.toMap());
    await _client.from('cat_sounds').insert({
      'cat_id': cat.id,
      'sound_type': cat.deterrentSound.index,
    });
  }

  @override
  Future<void> updateCat(CatProfile cat) async {
    final model = CatProfileModel.fromEntity(cat);
    await _client.from('cats').update(model.toMap()).eq('id', cat.id);
    await _client
        .from('cat_sounds')
        .update({'sound_type': cat.deterrentSound.index})
        .eq('cat_id', cat.id);
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
