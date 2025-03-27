import 'dart:developer';

import 'package:brokeo/backend/models/due.dart';
import 'package:brokeo/backend/services/crud/database_service.dart';

class DueService {
  Future<void> deleteDue({required int dueId}) async {
    final db = await DatabaseService.db;
    final deletedCount = await db.delete(
      dueTable,
      where: 'dueId = ?',
      whereArgs: [dueId],
    );

    if (deletedCount == 0) {
      log('No due found with id: $dueId');
    } else {
      log('Deleted due with id: $dueId');
    }
  }

  Future<DatabaseDue?> insertDue(DatabaseDue due) async {
    final db = await DatabaseService.db;
    final dueId = await db.insert(dueTable, {
      amountColumn: due.amount,
      merchantIdColumn: due.merchantId,
      categoryIdColumn: due.categoryId,
    });

    if (dueId == 0) {
      log('Failed to create due');
      return null;
    }

    final createdDue = await db.query(
      dueTable,
      where: 'dueId = ?',
      whereArgs: [dueId],
    );

    if (createdDue.isEmpty) {
      log('Failed to retrieve created due');
      return null;
    }
    return DatabaseDue.fromRow(createdDue.first);
  }

  Future<DatabaseDue?> updateDue(DatabaseDue due) async {
    final db = await DatabaseService.db;
    final updatedCount = await db.update(
      dueTable,
      {
        amountColumn: due.amount,
        merchantIdColumn: due.merchantId,
        categoryIdColumn: due.categoryId,
      },
      where: 'dueId = ?',
      whereArgs: [due.dueId],
    );

    if (updatedCount == 0) {
      log('No due found with id: ${due.dueId}');
      return null;
    }

    final updatedDue = await db.query(
      dueTable,
      where: 'dueId = ?',
      whereArgs: [due.dueId],
    );

    if (updatedDue.isEmpty) {
      log('Failed to retrieve updated due');
      return null;
    }
    return DatabaseDue.fromRow(updatedDue.first);
  }

  // Future<DatabaseDue?> upsertDue(DatabaseDue due) async {
  //   final db = await DatabaseService.db;
  //   final results = await db.query(
  //     dueTable,
  //     where: 'dueId = ?',
  //     whereArgs: [due.dueId],
  //   );
  //   if (results.isNotEmpty) {
  //     await db.update(
  //       dueTable,
  //       {
  //         amountColumn: due.amount,
  //         merchantIdColumn: due.merchantId,
  //         categoryIdColumn: due.categoryId,
  //       },
  //       where: 'dueId = ?',
  //       whereArgs: [due.dueId],
  //     );
  //     final updatedDue = await db.query(
  //       dueTable,
  //       where: 'dueId = ?',
  //       whereArgs: [due.dueId],
  //     );
  //     if (updatedDue.isEmpty) {
  //       log('Failed to retrieve updated due');
  //       return null;
  //     }
  //     return DatabaseDue.fromRow(updatedDue.first);
  //   } else {
  //     final dueId = await db.insert(dueTable, {
  //       amountColumn: due.amount,
  //       merchantIdColumn: due.merchantId,
  //       categoryIdColumn: due.categoryId,
  //     });

  //     if (dueId == 0) {
  //       log('Failed to create due');
  //       return null;
  //     }

  //     final createdDue = await db.query(
  //       dueTable,
  //       where: 'dueId = ?',
  //       whereArgs: [dueId],
  //     );

  //     if (createdDue.isEmpty) {
  //       log('Failed to retrieve created due');
  //       return null;
  //     }
  //     return DatabaseDue.fromRow(createdDue.first);
  //   }
  // }

  Future<DatabaseDue?> getDue({required int dueId}) async {
    final db = await DatabaseService.db;
    final results = await db.query(
      dueTable,
      where: 'dueId = ?',
      whereArgs: [dueId],
    );

    if (results.isEmpty) {
      log('No due found with id: $dueId');
      return null;
    } else {
      return DatabaseDue.fromRow(results.first);
    }
  }

  Future<List<DatabaseDue>> getAllDues() async {
    final db = await DatabaseService.db;
    final results = await db.query(dueTable);

    if (results.isEmpty) {
      log('No dues found');
      return [];
    } else {
      return results.map((row) => DatabaseDue.fromRow(row)).toList();
    }
  }
}
