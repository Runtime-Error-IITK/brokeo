import 'dart:developer';

import 'package:brokeo/backend/models/split_user.dart';
import 'package:brokeo/backend/services/crud/database_service.dart';

class SplitUserService {
  Future<void> deleteSplitUser({required String phoneNumber}) async {
    final db = await DatabaseService.db;
    final deletedCount = await db.delete(
      splitUserTable,
      where: 'phoneNumber = ?',
      whereArgs: [phoneNumber],
    );
    if (deletedCount == 0) {
      log('No split user found with phone number: $phoneNumber');
    } else {
      log('Deleted split user with phone number: $phoneNumber');
    }
  }

  Future<DatabaseSplitUser?> insertSplitUser(
      DatabaseSplitUser splitUser) async {
    final db = await DatabaseService.db;
    await db.insert(splitUserTable, {
      nameColumn: splitUser.name,
      phoneNumberColumn: splitUser.phoneNumber,
    });
    final createdSplitUser = await db.query(
      splitUserTable,
      where: 'phoneNumber = ?',
      whereArgs: [splitUser.phoneNumber],
    );
    if (createdSplitUser.isEmpty) {
      log('Failed to retrieve created split user');
      return null;
    }

    return DatabaseSplitUser.fromRow(createdSplitUser.first);
  }

  Future<DatabaseSplitUser?> updateSplitUser(
      DatabaseSplitUser splitUser) async {
    final db = await DatabaseService.db;
    final updatedCount = await db.update(
      splitUserTable,
      {
        nameColumn: splitUser.name,
        phoneNumberColumn: splitUser.phoneNumber,
      },
      where: 'phoneNumber = ?',
      whereArgs: [splitUser.phoneNumber],
    );

    if (updatedCount == 0) {
      log('No split user found with phone number: ${splitUser.phoneNumber}');
      return null;
    }

    final updatedSplitUser = await db.query(
      splitUserTable,
      where: 'phoneNumber = ?',
      whereArgs: [splitUser.phoneNumber],
    );

    if (updatedSplitUser.isEmpty) {
      log('Failed to retrieve updated split user');
      return null;
    }

    return DatabaseSplitUser.fromRow(updatedSplitUser.first);
  }

  // Future<DatabaseSplitUser?> upsertSplitUser(
  //     DatabaseSplitUser splitUser) async {
  //   final db = await DatabaseService.db;
  //   final results = await db.query(
  //     splitUserTable,
  //     where: 'phoneNumber = ?',
  //     whereArgs: [splitUser.phoneNumber],
  //   );

  //   if (results.isNotEmpty) {
  //     await db.update(
  //       splitUserTable,
  //       {
  //         nameColumn: splitUser.name,
  //         phoneNumberColumn: splitUser.phoneNumber,
  //       },
  //       where: 'phoneNumber = ?',
  //       whereArgs: [splitUser.phoneNumber],
  //     );
  //     final updatedSplitUser = await db.query(
  //       splitUserTable,
  //       where: 'phoneNumber = ?',
  //       whereArgs: [splitUser.phoneNumber],
  //     );
  //     if (updatedSplitUser.isEmpty) {
  //       log('Failed to retrieve updated split user');
  //       return null;
  //     }
  //     return DatabaseSplitUser.fromRow(updatedSplitUser.first);
  //   } else {
  //     final _ = await db.insert(splitUserTable, {
  //       nameColumn: splitUser.name,
  //       phoneNumberColumn: splitUser.phoneNumber,
  //     });

  //     // if (phoneNumber == 0) {
  //     //   log('Failed to create split user');
  //     //   return null;
  //     // }

  //     final createdSplitUser = await db.query(
  //       splitUserTable,
  //       where: 'phoneNumber = ?',
  //       whereArgs: [splitUser.phoneNumber],
  //     );

  //     if (createdSplitUser.isEmpty) {
  //       log('Failed to retrieve created split user');
  //       return null;
  //     }

  //     return DatabaseSplitUser.fromRow(createdSplitUser.first);
  //   }
  // }

  Future<DatabaseSplitUser?> getSplitUser({required String phoneNumber}) async {
    final db = await DatabaseService.db;
    final results = await db.query(
      splitUserTable,
      where: 'phoneNumber = ?',
      whereArgs: [phoneNumber],
    );

    if (results.isEmpty) {
      log('No split user found with phone number: $phoneNumber');
      return null;
    }

    return DatabaseSplitUser.fromRow(results.first);
  }

  Future<List<DatabaseSplitUser>> getAllSplitUsers() async {
    final db = await DatabaseService.db;
    final results = await db.query(splitUserTable);

    if (results.isEmpty) {
      log('No split users found');
      return [];
    }

    return results.map((row) => DatabaseSplitUser.fromRow(row)).toList();
  }
}
