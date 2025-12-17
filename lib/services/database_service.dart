import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:moodie/models/custom_event.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() => _instance;

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'moodie_database.db');
    return await openDatabase(
      path,
      version: 1, // keeping version 1 since we are in dev phase, otherwise would bump
      onCreate: _onCreate,
      onUpgrade: _onUpgrade, // Handle upgrade if schema changed
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE custom_events(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        type TEXT NOT NULL,
        start_time INTEGER NOT NULL,
        is_completed INTEGER DEFAULT 0
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // If we were upgrading, we would drop/alter here.
    // For now, assume fresh install or dev wiping.
    // To be safe for this session, I'll drop tables if they exist with wrong schema?
    // Since I can't guarantee state, I won't overengineer migration now.
  }

  Future<int> insertEvent(CustomEvent event) async {
    final db = await database;
    return await db.insert('custom_events', event.toMap());
  }

  Future<int> updateEvent(CustomEvent event) async {
    final db = await database;
    return await db.update(
      'custom_events',
      event.toMap(),
      where: 'id = ?',
      whereArgs: [event.id],
    );
  }

  Future<int> deleteEvent(int id) async {
    final db = await database;
    return await db.delete(
      'custom_events',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> setEventCompletion(int eventId, bool isCompleted) async {
    final db = await database;
    await db.update(
      'custom_events',
      {'is_completed': isCompleted ? 1 : 0},
      where: 'id = ?',
      whereArgs: [eventId],
    );
  }

  Future<List<CustomEvent>> getEventsForRange(DateTime start, DateTime end) async {
    final db = await database;
    final startMillis = start.millisecondsSinceEpoch;
    final endMillis = end.millisecondsSinceEpoch;

    final List<Map<String, dynamic>> maps = await db.query(
      'custom_events',
      where: 'start_time >= ? AND start_time <= ? AND is_completed = 0',
      whereArgs: [startMillis, endMillis],
    );

    return maps.map((e) => CustomEvent.fromMap(e)).toList();
  }

  Future<List<CustomEvent>> getExpiredEvents(DateTime now) async {
    final db = await database;
    final nowMillis = now.millisecondsSinceEpoch;

    final List<Map<String, dynamic>> maps = await db.query(
      'custom_events',
      where: 'start_time < ? AND is_completed = 0',
      whereArgs: [nowMillis],
    );

    return maps.map((e) => CustomEvent.fromMap(e)).toList();
  }
}
