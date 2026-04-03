import 'dart:typed_data';
import '../entities/cat_profile.dart';

abstract class CatRepository {
  Future<List<CatProfile>> getAllCats();
  Future<CatProfile?> getCatById(String id);
  Future<CatProfile?> getCatByBeaconId(String beaconId);
  Future<void> addCat(CatProfile cat);
  Future<void> updateCat(CatProfile cat);
  Future<void> deleteCat(String id);
  Future<String?> uploadCatImage(String catId, Uint8List imageBytes, String fileName);
}
