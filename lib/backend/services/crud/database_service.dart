import 'dart:developer';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  Database? _db;
  Future<void> open() async {
    if (_db != null) {
      return;
    }
    try {
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path, dbName);
      final db = await openDatabase(dbPath);
      _db = db;

      await db.execute(createCategoryTable);
    } catch (e) {
      log("Error opening database: $e");
    }
  }

  Future<Database> get db async {
    if (_db != null) {
      return _db!;
    } else {
      await open();
      return _db!;
    }
  }

  Future<void> close() async {
    final db = _db;
    if (db != null) {
      await db.close();
      _db = null;
    }
  }
}

const String dbName = "brokeo.db";
const String categoryTable = "categories";
const String createCategoryTable = '''CREATE TABLE IF NOT EXISTS "categories" (
	"name"	TEXT NOT NULL,
	"categoryId"	INTEGER NOT NULL UNIQUE,
	"budget"	REAL NOT NULL,
	PRIMARY KEY("categoryId" AUTOINCREMENT)
)''';
