import 'dart:developer';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static Database? _db;

  static Future<void> open() async {
    if (_db != null) {
      return;
    }
    try {
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path, dbName);
      final db = await openDatabase(dbPath);
      _db = db;

      await db.execute(createCategoryTable);
      await db.execute(createMerchantTable);
      await db.execute(createSplitUserTable);
      await db.execute(createDueTable);
      await db.execute(createScheduleTable);
    } catch (e) {
      log("Error opening database: $e");
    }
  }

  static Future<Database> get db async {
    if (_db != null) {
      return _db!;
    } else {
      await open();
      return _db!;
    }
  }

  static Future<void> close() async {
    final db = _db;
    if (db != null) {
      await db.close();
      _db = null;
    }
  }
}

const String dbName = "brokeo.db";

const String categoryTable = "categories";
const String createCategoryTable = '''CREATE TABLE "categories" (
	"name"	TEXT NOT NULL UNIQUE,
	"categoryId"	INTEGER NOT NULL UNIQUE,
	"budget"	REAL NOT NULL,
	PRIMARY KEY("categoryId" AUTOINCREMENT)
)''';

const String merchantTable = "merchants";
const String createMerchantTable = '''CREATE TABLE IF NOT EXISTS "merchants" (
	"merchantId"	INTEGER NOT NULL UNIQUE,
	"name"	TEXT NOT NULL,
	"categoryId"	INTEGER NOT NULL,
	PRIMARY KEY("merchantId" AUTOINCREMENT),
	FOREIGN KEY("categoryId") REFERENCES "categories"("categoryId")
)''';

const String splitUserTable = "splitUsers";
const String createSplitUserTable = '''CREATE TABLE IF NOT EXISTS "splitUsers" (
	"name"	TEXT NOT NULL,
	"phoneNumber"	TEXT NOT NULL UNIQUE,
	PRIMARY KEY("phoneNumber")
)''';

const String dueTable = "dues";
const String createDueTable = '''CREATE TABLE IF NOT EXISTS "dues" (
	"dueId"	INTEGER NOT NULL UNIQUE,
	"amount"	REAL NOT NULL,
	"merchantId"	INTEGER NOT NULL,
	"categoryId"	INTEGER NOT NULL,
	PRIMARY KEY("dueId" AUTOINCREMENT),
	FOREIGN KEY("categoryId") REFERENCES "categories"("categoryId"),
	FOREIGN KEY("merchantId") REFERENCES "merchants"("merchantId")
)''';

const String scheduleTable = "schedules";
const String createScheduleTable = '''CREATE TABLE "schedules" (
	"scheduleId"	INTEGER NOT NULL UNIQUE,
	"amount"	REAL NOT NULL,
	"merchantId"	INTEGER NOT NULL,
	"categoryId"	INTEGER NOT NULL,
	"timePeriod"	INTEGER NOT NULL,
	"dates"	TEXT NOT NULL,
	PRIMARY KEY("scheduleId" AUTOINCREMENT),
	FOREIGN KEY("categoryId") REFERENCES "categories"("categoryId"),
	FOREIGN KEY("merchantId") REFERENCES "merchants"("merchantId")
)''';
