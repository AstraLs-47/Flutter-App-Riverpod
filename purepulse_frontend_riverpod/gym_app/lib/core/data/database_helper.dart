// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

/// A functional wrapper using SharedPreferences to simulate a SQL database.
/// This provides persistence across Web and Mobile without requiring sqflite.
class SharedPreferencesDatabase {
  static const String _dbPrefix = 'db_table_';

  Future<void> execute(String sql) async {
    // No-op for schema creation as JSON storage is schema-less.
    return;
  }

  Future<List<Map<String, dynamic>>> query(
    String table, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString('$_dbPrefix$table');
    if (data == null) return [];

    try {
      final List<dynamic> decoded = json.decode(data);
      if (decoded.isNotEmpty) {
        return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Database Error: Failed to decode table $table: $e');
      return [];
    }
  }

  Future<int> insert(
    String table,
    Map<String, dynamic> values, {
    dynamic conflictAlgorithm,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final String key = '$_dbPrefix$table';
    final List<Map<String, dynamic>> currentData = await query(table);

    // Simulate "ConflictAlgorithm.replace" by checking for existing ID
    final id = values['id'];
    if (id != null) {
      currentData.removeWhere((item) => item['id'].toString() == id.toString());
    }
    currentData.add(values);

    await prefs.setString(key, json.encode(currentData));
    return 1;
  }

  Future<int> delete(
    String table, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final String key = '$_dbPrefix$table';

    if (where == null) {
      await prefs.remove(key);
      return 1;
    }

    // Specific deletion logic (usually by ID in this app)
    final List<Map<String, dynamic>> currentData = await query(table);
    if (where.contains('id = ?') && whereArgs != null && whereArgs.isNotEmpty) {
      final targetId = whereArgs[0].toString();
      final originalLength = currentData.length;
      currentData.removeWhere((item) => item['id'].toString() == targetId);
      if (currentData.length != originalLength) {
        await prefs.setString(key, json.encode(currentData));
        return 1;
      }
    }

    return 0;
  }

  SharedPreferencesBatch batch() {
    return SharedPreferencesBatch(this);
  }
}

class SharedPreferencesBatch {
  final SharedPreferencesDatabase _db;
  final List<Map<String, dynamic>> _ops = [];
  final List<String> _tables = [];

  SharedPreferencesBatch(this._db);

  void insert(
    String table,
    Map<String, dynamic> values, {
    dynamic conflictAlgorithm,
  }) {
    _ops.add(values);
    _tables.add(table);
  }

  Future<List<dynamic>> commit({bool? noResult}) async {
    if (_ops.isEmpty) return [];

    final Map<String, List<Map<String, dynamic>>> tableOps = {};
    for (int i = 0; i < _tables.length; i++) {
      tableOps.putIfAbsent(_tables[i], () => []).add(_ops[i]);
    }

    for (var entry in tableOps.entries) {
      final table = entry.key;
      final List<Map<String, dynamic>> data = await _db.query(table);
      for (var row in entry.value) {
        final id = row['id'];
        if (id != null) {
          data.removeWhere((item) => item['id'].toString() == id.toString());
        }
        data.add(row);
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('db_table_$table', json.encode(data));
    }
    return [];
  }
}

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  sqflite.Database? _sqliteDb;
  SharedPreferencesDatabase? _sharedPrefsDb;

  Future<void> _initDb() async {
    if (kIsWeb) {
      _sharedPrefsDb = SharedPreferencesDatabase();
    } else {
      final documentsDirectory = await getApplicationDocumentsDirectory();
      final path = p.join(documentsDirectory.path, "purepulse.db");
      _sqliteDb = await sqflite.openDatabase(
        path,
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE products (
              id TEXT PRIMARY KEY,
              name TEXT,
              description TEXT,
              category TEXT,
              image_url TEXT,
              is_active INTEGER,
              cached_at INTEGER
            )
          ''');
          await db.execute('''
            CREATE TABLE exercises (
              id TEXT PRIMARY KEY,
              name TEXT,
              description TEXT,
              image_url TEXT,
              category_name TEXT,
              duration TEXT,
              warmup TEXT,
              main_workout TEXT,
              rest TEXT,
              cached_at INTEGER
            )
          ''');
          await db.execute('''
            CREATE TABLE announcements (
              id TEXT PRIMARY KEY,
              title TEXT,
              description TEXT,
              date TEXT,
              cached_at INTEGER
            )
          ''');
          await db.execute('''
            CREATE TABLE progress_entries (
              id TEXT PRIMARY KEY,
              exercise_name TEXT,
              entry_date TEXT,
              duration_minutes INTEGER,
              sets INTEGER,
              reps INTEGER,
              weight REAL,
              intensity TEXT,
              notes TEXT,
              achievement TEXT,
              cached_at INTEGER
            )
          ''');
          await db.execute('''
            CREATE TABLE health_metrics (
              id TEXT PRIMARY KEY,
              blood_pressure_systolic INTEGER,
              blood_pressure_diastolic INTEGER,
              resting_heart_rate INTEGER,
              blood_sugar REAL,
              weight REAL,
              height REAL,
              bmi REAL,
              date TEXT,
              cached_at INTEGER
            )
          ''');
          await db.execute('''
            CREATE TABLE categories (
              id TEXT PRIMARY KEY,
              name TEXT,
              type TEXT
            )
          ''');
          await db.execute('''
            CREATE TABLE user_sessions (
              id INTEGER PRIMARY KEY,
              user_id TEXT,
              token TEXT,
              created_at INTEGER
            )
          ''');
        },
      );
    }
  }

  Future<void> _ensureDb() async {
    if (kIsWeb) {
      if (_sharedPrefsDb == null) {
        await _initDb();
      }
    } else {
      if (_sqliteDb == null) {
        await _initDb();
      }
    }
  }

  // Generic Cache CRUD helpers
  Future<void> insertAll(String table, List<Map<String, dynamic>> rows) async {
    await _ensureDb();
    if (kIsWeb) {
      final batch = _sharedPrefsDb!.batch();
      for (var row in rows) {
        batch.insert(table, row);
      }
      await batch.commit(noResult: true);
    } else {
      final batch = _sqliteDb!.batch();
      for (var row in rows) {
        batch.insert(
          table,
          row,
          conflictAlgorithm: sqflite.ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
    }
  }

  Future<List<Map<String, dynamic>>> queryAll(String table) async {
    await _ensureDb();
    if (kIsWeb) {
      return await _sharedPrefsDb!.query(table);
    } else {
      return await _sqliteDb!.query(table);
    }
  }

  Future<void> insert(String table, Map<String, dynamic> row) async {
    await _ensureDb();
    if (kIsWeb) {
      await _sharedPrefsDb!.insert(table, row);
    } else {
      await _sqliteDb!.insert(
        table,
        row,
        conflictAlgorithm: sqflite.ConflictAlgorithm.replace,
      );
    }
  }

  Future<void> delete(String table, String id) async {
    await _ensureDb();
    if (kIsWeb) {
      await _sharedPrefsDb!.delete(table, where: 'id = ?', whereArgs: [id]);
    } else {
      await _sqliteDb!.delete(table, where: 'id = ?', whereArgs: [id]);
    }
  }

  Future<void> clearTable(String table) async {
    await _ensureDb();
    if (kIsWeb) {
      await _sharedPrefsDb!.delete(table);
    } else {
      await _sqliteDb!.delete(table);
    }
  }

  Future<void> clearAllCaches() async {
    await clearTable('products');
    await clearTable('exercises');
    await clearTable('announcements');
    await clearTable('progress_entries');
    await clearTable('health_metrics');
  }
}
