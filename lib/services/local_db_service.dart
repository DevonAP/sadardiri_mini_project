import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/test_result_model.dart';

class LocalDbService {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'sadar_diri.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE test_results(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            userId TEXT,
            score INTEGER,
            selfieUrl TEXT,
            date TEXT
          )
        ''');
        // Tabel instrumen pertanyaan bisa ditambahkan di sini
      },
    );
  }

  Future<int> insertResult(TestResult result) async {
    final db = await database;
    return await db.insert('test_results', result.toMap());
  }

  Future<List<TestResult>> getResults(String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'test_results',
      where: 'userId = ?',
      whereArgs: [userId],
    );
    return List.generate(maps.length, (i) => TestResult.fromMap(maps[i]));
  }
}