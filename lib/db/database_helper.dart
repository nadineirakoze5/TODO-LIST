import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/task_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    _database ??= await _initDB('tasks.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        date TEXT,
        time TEXT,
        priority TEXT,
        category TEXT,
        repeat TEXT,
        checklist TEXT,
        isDone INTEGER
      )
    ''');
  }

  /// Insert task into SQLite
  Future<int> insertTask(TaskModel task) async {
    final db = await instance.database;
    return await db.insert('tasks', task.toSqliteMap());
  }

  /// Get all tasks from SQLite
  Future<List<TaskModel>> getTasks() async {
    final db = await instance.database;
    final result = await db.query('tasks');
    return result.map((map) => TaskModel.fromSqlite(map)).toList();
  }

  /// Update task in SQLite
  Future<int> updateTask(TaskModel task) async {
    final db = await instance.database;
    if (task.localId == null) return 0; // safety check
    return await db.update(
      'tasks',
      task.toSqliteMap(),
      where: 'id = ?',
      whereArgs: [task.localId],
    );
  }

  /// Delete task by local ID
  Future<int> deleteTask(int localId) async {
    final db = await instance.database;
    return await db.delete('tasks', where: 'id = ?', whereArgs: [localId]);
  }

  /// Optional: Clear all tasks (for testing)
  Future<void> clearTasks() async {
    final db = await instance.database;
    await db.delete('tasks');
  }
}
