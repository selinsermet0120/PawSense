import '../../domain/entities/cat_profile.dart';
import '../../domain/repositories/cat_repository.dart';
import '../datasources/local/database_helper.dart';
import '../models/cat_profile_model.dart';

class CatRepositoryImpl implements CatRepository {
  final DatabaseHelper _databaseHelper;

  CatRepositoryImpl(this._databaseHelper);

  @override
  Future<List<CatProfile>> getAllCats() async {
    final db = await _databaseHelper.database;
    final maps = await db.query('cats');
    return maps.map((map) => CatProfileModel.fromMap(map)).toList();
  }

  @override
  Future<CatProfile?> getCatById(String id) async {
    final db = await _databaseHelper.database;
    final maps = await db.query('cats', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return CatProfileModel.fromMap(maps.first);
  }

  @override
  Future<CatProfile?> getCatByBeaconId(String beaconId) async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      'cats',
      where: 'beacon_id = ?',
      whereArgs: [beaconId],
    );
    if (maps.isEmpty) return null;
    return CatProfileModel.fromMap(maps.first);
  }

  @override
  Future<void> addCat(CatProfile cat) async {
    final db = await _databaseHelper.database;
    final model = CatProfileModel.fromEntity(cat);
    await db.insert('cats', model.toMap());
  }

  @override
  Future<void> updateCat(CatProfile cat) async {
    final db = await _databaseHelper.database;
    final model = CatProfileModel.fromEntity(cat);
    await db.update('cats', model.toMap(), where: 'id = ?', whereArgs: [cat.id]);
  }

  @override
  Future<void> deleteCat(String id) async {
    final db = await _databaseHelper.database;
    await db.delete('cats', where: 'id = ?', whereArgs: [id]);
  }
}
