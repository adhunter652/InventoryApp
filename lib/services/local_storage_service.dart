import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/goal.dart';
import '../models/activity.dart';

class LocalStorageService {
  static Database? _database;
  static const String _goalsTable = 'goals';
  static const String _activitiesTable = 'activities';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'goals_tracker.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create goals table
    await db.execute('''
      CREATE TABLE $_goalsTable(
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        createdAt INTEGER NOT NULL,
        targetDate INTEGER,
        category TEXT NOT NULL,
        isCompleted INTEGER NOT NULL,
        progress INTEGER NOT NULL,
        notes TEXT
      )
    ''');

    // Create activities table
    await db.execute('''
      CREATE TABLE $_activitiesTable(
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        date INTEGER NOT NULL,
        goalId TEXT NOT NULL,
        duration INTEGER NOT NULL,
        category TEXT NOT NULL,
        notes TEXT,
        isCompleted INTEGER NOT NULL,
        FOREIGN KEY (goalId) REFERENCES $_goalsTable (id)
      )
    ''');
  }

  // Goal operations
  Future<void> insertGoal(Goal goal) async {
    final db = await database;
    await db.insert(
      _goalsTable,
      goal.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Goal>> getGoals() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(_goalsTable);
    return List.generate(maps.length, (i) => Goal.fromMap(maps[i]));
  }

  Future<Goal?> getGoal(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _goalsTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Goal.fromMap(maps.first);
    }
    return null;
  }

  Future<void> updateGoal(Goal goal) async {
    final db = await database;
    await db.update(
      _goalsTable,
      goal.toMap(),
      where: 'id = ?',
      whereArgs: [goal.id],
    );
  }

  Future<void> deleteGoal(String id) async {
    final db = await database;
    await db.delete(_goalsTable, where: 'id = ?', whereArgs: [id]);
  }

  // Activity operations
  Future<void> insertActivity(Activity activity) async {
    final db = await database;
    await db.insert(
      _activitiesTable,
      activity.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Activity>> getActivities() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(_activitiesTable);
    return List.generate(maps.length, (i) => Activity.fromMap(maps[i]));
  }

  Future<List<Activity>> getActivitiesByGoal(String goalId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _activitiesTable,
      where: 'goalId = ?',
      whereArgs: [goalId],
    );
    return List.generate(maps.length, (i) => Activity.fromMap(maps[i]));
  }

  Future<List<Activity>> getActivitiesByDate(DateTime date) async {
    final db = await database;
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final List<Map<String, dynamic>> maps = await db.query(
      _activitiesTable,
      where: 'date >= ? AND date < ?',
      whereArgs: [
        startOfDay.millisecondsSinceEpoch,
        endOfDay.millisecondsSinceEpoch,
      ],
    );
    return List.generate(maps.length, (i) => Activity.fromMap(maps[i]));
  }

  Future<Activity?> getActivity(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _activitiesTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Activity.fromMap(maps.first);
    }
    return null;
  }

  Future<void> updateActivity(Activity activity) async {
    final db = await database;
    await db.update(
      _activitiesTable,
      activity.toMap(),
      where: 'id = ?',
      whereArgs: [activity.id],
    );
  }

  Future<void> deleteActivity(String id) async {
    final db = await database;
    await db.delete(_activitiesTable, where: 'id = ?', whereArgs: [id]);
  }

  // Utility methods
  Future<void> close() async {
    final db = await database;
    await db.close();
  }

  Future<void> clearAllData() async {
    final db = await database;
    await db.delete(_activitiesTable);
    await db.delete(_goalsTable);
  }
}

