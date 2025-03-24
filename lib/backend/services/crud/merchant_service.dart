import 'dart:core';
import 'dart:developer';

import 'package:brokeo/backend/models/merchant.dart';
import 'package:brokeo/backend/services/crud/database_service.dart';

class MerchantService {
  Future<void> deleteMerchant({required int merchantId}) async {
    final db = await DatabaseService.db;
    final deletedCount = await db.delete(
      merchantTable,
      where: 'merchantId = ?',
      whereArgs: [merchantId],
    );

    if (deletedCount == 0) {
      log('No merchant found with id: $merchantId');
    } else {
      log('Deleted merchant with id: $merchantId');
    }
  }

  Future<DatabaseMerchant?> insertMerchant(DatabaseMerchant merchant) async {
    final db = await DatabaseService.db;
    final merchantId = await db.insert(merchantTable, {
      nameColumn: merchant.name,
      categoryIdColumn: merchant.categoryId,
    });

    if (merchantId == 0) {
      log('Failed to create merchant');
      return null;
    }

    final createdMerchant = await db.query(
      merchantTable,
      where: 'merchantId = ?',
      whereArgs: [merchantId],
    );

    if (createdMerchant.isEmpty) {
      log('Failed to retrieve created merchant');
      return null;
    }

    return DatabaseMerchant.fromRow(createdMerchant.first);
  }

  Future<DatabaseMerchant?> updateMerchant(DatabaseMerchant merchant) async {
    final db = await DatabaseService.db;
    final updatedCount = await db.update(
      merchantTable,
      {
        nameColumn: merchant.name,
        categoryIdColumn: merchant.categoryId,
      },
      where: 'merchantId = ?',
      whereArgs: [merchant.merchantId],
    );

    if (updatedCount == 0) {
      log('No merchant found with id: ${merchant.merchantId}');
      return null;
    }

    final updatedMerchant = await db.query(
      merchantTable,
      where: 'merchantId = ?',
      whereArgs: [merchant.merchantId],
    );

    if (updatedMerchant.isEmpty) {
      log('Failed to retrieve updated merchant');
      return null;
    }

    return DatabaseMerchant.fromRow(updatedMerchant.first);
  }

  // Future<DatabaseMerchant?> upsertMerchant(DatabaseMerchant merchant) async {
  //   final db = await DatabaseService.db;
  //   final results = await db.query(
  //     merchantTable,
  //     where: 'merchantId = ?',
  //     whereArgs: [merchant.merchantId],
  //   );

  //   if (results.isNotEmpty) {
  //     await db.update(
  //       merchantTable,
  //       {
  //         nameColumn: merchant.name,
  //         categoryIdColumn: merchant.categoryId,
  //       },
  //       where: 'merchantId = ?',
  //       whereArgs: [merchant.merchantId],
  //     );
  //     final updatedMerchant = await db.query(
  //       merchantTable,
  //       where: 'merchantId = ?',
  //       whereArgs: [merchant.merchantId],
  //     );
  //     if (updatedMerchant.isEmpty) {
  //       log('Failed to retrieve updated merchant');
  //       return null;
  //     }
  //     return DatabaseMerchant.fromRow(updatedMerchant.first);
  //   } else {
  //     final merchantId = await db.insert(merchantTable, {
  //       nameColumn: merchant.name,
  //       categoryIdColumn: merchant.categoryId,
  //     });

  //     if (merchantId == 0) {
  //       log('Failed to create merchant');
  //       return null;
  //     }

  //     final createdMerchant = await db.query(
  //       merchantTable,
  //       where: 'merchantId = ?',
  //       whereArgs: [merchantId],
  //     );

  //     if (createdMerchant.isEmpty) {
  //       log('Failed to retrieve created merchant');
  //       return null;
  //     }

  //     return DatabaseMerchant.fromRow(createdMerchant.first);
  //   }
  // }

  Future<DatabaseMerchant?> getMerchant({required int merchantId}) async {
    final db = await DatabaseService.db;
    final results = await db.query(
      merchantTable,
      where: 'merchantId = ?',
      whereArgs: [merchantId],
    );

    if (results.isNotEmpty) {
      return DatabaseMerchant.fromRow(results.first);
    } else {
      log('No merchant found with id: $merchantId');
      return null;
    }
  }

  Future<List<DatabaseMerchant>> getAllMerchants() async {
    final db = await DatabaseService.db;
    final results = await db.query(merchantTable);

    if (results.isNotEmpty) {
      return results.map((row) => DatabaseMerchant.fromRow(row)).toList();
    } else {
      log('No merchants found');
      return [];
    }
  }
}
