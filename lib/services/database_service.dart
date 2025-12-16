import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:moodie/models/custom_event.dart';
import 'package:moodie/models/app_event.dart';

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
      version: 1,
      onCreate: _onCreate,
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
        recurrence_type TEXT NOT NULL,
        recurrence_interval INTEGER,
        recurrence_days TEXT,
        recurrence_end_date INTEGER,
        recurrence_count INTEGER,
        is_completed INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE event_completions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        event_id INTEGER NOT NULL,
        instance_date INTEGER NOT NULL,
        is_completed INTEGER NOT NULL,
        FOREIGN KEY(event_id) REFERENCES custom_events(id) ON DELETE CASCADE
      )
    ''');
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

  Future<void> setEventCompletion(int eventId, DateTime instanceDate, bool isCompleted) async {
    final db = await database;
    // Check if it's a non-recurring event first?
    // Actually, simpler to check the event definition.
    final List<Map<String, dynamic>> maps = await db.query(
      'custom_events',
      where: 'id = ?',
      whereArgs: [eventId],
    );

    if (maps.isEmpty) return;
    final event = CustomEvent.fromMap(maps.first);
    final normalizedDate = _normalizeDate(instanceDate);

    if (event.recurrenceType == RecurrenceType.none) {
      // Update the main table
      await db.update(
        'custom_events',
        {'is_completed': isCompleted ? 1 : 0},
        where: 'id = ?',
        whereArgs: [eventId],
      );
    } else {
      // Update event_completions table
      // First check if an entry exists
      final List<Map<String, dynamic>> completions = await db.query(
        'event_completions',
        where: 'event_id = ? AND instance_date = ?',
        whereArgs: [eventId, normalizedDate.millisecondsSinceEpoch],
      );

      if (completions.isNotEmpty) {
        await db.update(
          'event_completions',
          {'is_completed': isCompleted ? 1 : 0},
          where: 'id = ?',
          whereArgs: [completions.first['id']],
        );
      } else {
        await db.insert('event_completions', {
          'event_id': eventId,
          'instance_date': normalizedDate.millisecondsSinceEpoch,
          'is_completed': isCompleted ? 1 : 0,
        });
      }
    }
  }

  Future<List<CustomEventInstance>> getEventsForRange(DateTime start, DateTime end) async {
    final db = await database;
    final startMillis = start.millisecondsSinceEpoch;
    final endMillis = end.millisecondsSinceEpoch;

    // Fetch candidate events:
    // 1. Non-recurring events within range
    // 2. Recurring events that started before end of range
    // We filter recurring logic in Dart code for simplicity
    final List<Map<String, dynamic>> maps = await db.query(
      'custom_events',
      where: '(recurrence_type = ? AND start_time >= ? AND start_time <= ?) OR (recurrence_type != ? AND start_time <= ?)',
      whereArgs: [
        RecurrenceType.none.toString(), startMillis, endMillis,
        RecurrenceType.none.toString(), endMillis
      ],
    );

    final events = maps.map((e) => CustomEvent.fromMap(e)).toList();
    final List<CustomEventInstance> instances = [];

    for (final event in events) {
      if (event.recurrenceType == RecurrenceType.none) {
        instances.add(CustomEventInstance(
          event: event,
          instanceDate: event.startTime,
          isCompletedInstance: event.isCompleted,
        ));
      } else {
        instances.addAll(await _expandRecurringEvent(db, event, start, end));
      }
    }

    // Sort by date
    instances.sort((a, b) => a.date.compareTo(b.date));
    return instances;
  }

  Future<List<CustomEventInstance>> getExpiredEvents(DateTime now) async {
    // Get all events that started before now
    final db = await database;
    final nowMillis = now.millisecondsSinceEpoch;

    // Fetch all events that could possibly have instances before now
    final List<Map<String, dynamic>> maps = await db.query(
      'custom_events',
      where: 'start_time < ?',
      whereArgs: [nowMillis],
    );

    final events = maps.map((e) => CustomEvent.fromMap(e)).toList();
    final List<CustomEventInstance> instances = [];

    // For expired, we want essentially "From Beginning of Time" to "now"
    // But realistically, maybe last year?
    // Let's assume user doesn't want to see tasks from 10 years ago.
    // But requirement says "all overdue tasks".
    // We'll limit to a reasonable past, e.g., 1 year ago, or just generate all since start.
    // Since start_time is the start, we can generate from there.

    for (final event in events) {
      if (event.recurrenceType == RecurrenceType.none) {
        if (!event.isCompleted) {
          instances.add(CustomEventInstance(
            event: event,
            instanceDate: event.startTime,
            isCompletedInstance: false,
          ));
        }
      } else {
        // Generate all instances from start_time up to now
        final recurringInstances = await _expandRecurringEvent(db, event, event.startTime, now);
        // Filter only incomplete ones
        instances.addAll(recurringInstances.where((i) => !i.isCompleted));
      }
    }

    instances.sort((a, b) => a.date.compareTo(b.date));
    return instances;
  }

  Future<List<CustomEventInstance>> _expandRecurringEvent(
    Database db,
    CustomEvent event,
    DateTime rangeStart,
    DateTime rangeEnd
  ) async {
    final List<CustomEventInstance> instances = [];

    // Normalize range to dates
    DateTime current = _normalizeDate(event.startTime);
    final DateTime end = _normalizeDate(rangeEnd);
    final DateTime start = _normalizeDate(rangeStart);

    // Safety check to avoid infinite loops if start_time is in future (though query handles it)
    if (current.isAfter(end)) return [];

    // Pre-fetch completions for this event to avoid N queries
    final List<Map<String, dynamic>> completionMaps = await db.query(
      'event_completions',
      where: 'event_id = ?',
      whereArgs: [event.id],
    );

    // Map instance_date (millis) to is_completed
    final Map<int, bool> completions = {
      for (var m in completionMaps) m['instance_date'] as int: (m['is_completed'] as int) == 1
    };

    int count = 0;
    while (current.isBefore(end) || current.isAtSameMomentAs(end)) {
      // Check count limit
      if (event.recurrenceCount != null && count >= event.recurrenceCount!) break;

      // Check date limit
      if (event.recurrenceEndDate != null && current.isAfter(_normalizeDate(event.recurrenceEndDate!))) break;

      // Check if current matches pattern
      bool matches = false;
      if (event.recurrenceType == RecurrenceType.daily) {
        matches = true; // Assuming interval handled in loop increment
      } else if (event.recurrenceType == RecurrenceType.weekly) {
        // weekday is 1(Mon)..7(Sun). recurrenceDays should store these.
        if (event.recurrenceDays != null && event.recurrenceDays!.contains(current.weekday)) {
          matches = true;
        }
      }

      if (matches) {
        // Only add if within the requested range
        if (current.isAfter(start) || current.isAtSameMomentAs(start)) {
          final isCompleted = completions[current.millisecondsSinceEpoch] ?? false;
          instances.add(CustomEventInstance(
            event: event,
            instanceDate: current,
            isCompletedInstance: isCompleted,
          ));
        }
        count++; // Increment count of occurrences (even if outside range start, it counts towards limit)
      }

      // Increment date
      if (event.recurrenceType == RecurrenceType.daily) {
        current = current.add(Duration(days: event.recurrenceInterval));
      } else if (event.recurrenceType == RecurrenceType.weekly) {
        current = current.add(const Duration(days: 1)); // Iterate daily to check weekdays
        // Optimization: Could jump to next weekday, but daily iteration is safe/simple
      } else {
        break; // Should not happen
      }
    }

    return instances;
  }

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}
