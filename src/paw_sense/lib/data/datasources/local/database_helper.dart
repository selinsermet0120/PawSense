import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'pawsense.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE cats (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        avatar_path TEXT NOT NULL,
        beacon_id TEXT NOT NULL UNIQUE,
        deterrent_sound INTEGER NOT NULL DEFAULT 0,
        is_active INTEGER NOT NULL DEFAULT 1
      )
    ''');

    await db.execute('''
      CREATE TABLE violations (
        id TEXT PRIMARY KEY,
        cat_id TEXT NOT NULL,
        room_unit_id TEXT NOT NULL,
        zone_name TEXT NOT NULL,
        rssi_value INTEGER NOT NULL,
        status INTEGER NOT NULL,
        timestamp INTEGER NOT NULL,
        duration_seconds INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (cat_id) REFERENCES cats (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE room_units (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        mac_address TEXT NOT NULL UNIQUE,
        state INTEGER NOT NULL DEFAULT 0,
        rssi_threshold_danger INTEGER NOT NULL DEFAULT -52,
        rssi_threshold_near INTEGER NOT NULL DEFAULT -60,
        cooldown_seconds INTEGER NOT NULL DEFAULT 5
      )
    ''');

    await db.execute(
      'CREATE INDEX idx_violations_cat_id ON violations (cat_id)',
    );
    await db.execute(
      'CREATE INDEX idx_violations_timestamp ON violations (timestamp)',
    );
  }
}
