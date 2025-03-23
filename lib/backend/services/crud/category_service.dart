import 'dart:developer';
import 'package:brokeo/backend/models/category.dart';
import 'package:brokeo/backend/services/crud/database_service.dart';

class CategoryService {
  Future<void> deleteCategory({required int categoryId}) async {
    final db = await DatabaseService.db;
    final deletedCount = await db.delete(
      categoryTable,
      where: 'categoryId = ?',
      whereArgs: [categoryId],
    );
    if (deletedCount == 0) {
      log('No category found with id: $categoryId');
    } else {
      log('Deleted category with id: $categoryId');
    }
  }

  Future<DatabaseCategory?> insertCategory(DatabaseCategory category) async {
    final db = await DatabaseService.db;
    final categoryId = await db.insert(categoryTable, {
      nameColumn: category.name,
      categoryIdColumn: category.categoryId,
      budgetColumn: category.budget,
    });

    if (categoryId == 0) {
      log('Failed to create category');
      return null;
    }

    final createdCategory = await db.query(
      categoryTable,
      where: 'categoryId = ?',
      whereArgs: [categoryId],
    );

    if (createdCategory.isEmpty) {
      log('Failed to retrieve created category');
      return null;
    }

    return DatabaseCategory.fromRow(createdCategory.first);
  }

  Future<DatabaseCategory?> updateCategory(DatabaseCategory category) async {
    final db = await DatabaseService.db;
    final updatedCount = await db.update(
      categoryTable,
      {
        nameColumn: category.name,
        budgetColumn: category.budget,
      },
      where: 'categoryId = ?',
      whereArgs: [category.categoryId],
    );

    if (updatedCount == 0) {
      log('No category found with id: ${category.categoryId}');
      return null;
    }

    final updatedCategory = await db.query(
      categoryTable,
      where: 'categoryId = ?',
      whereArgs: [category.categoryId],
    );

    if (updatedCategory.isEmpty) {
      log('Failed to retrieve updated category');
      return null;
    }

    return DatabaseCategory.fromRow(updatedCategory.first);
  }

  // Future<DatabaseCategory?> upsertCategory(DatabaseCategory category) async {
  //   final db = await DatabaseService.db;
  //   final results = await db.query(
  //     categoryTable,
  //     where: 'categoryId = ?',
  //     whereArgs: [category.categoryId],
  //   );

  //   if (results.isNotEmpty) {
  //     await db.update(
  //       categoryTable,
  //       {
  //         nameColumn: category.name,
  //         budgetColumn: category.budget,
  //       },
  //       where: 'categoryId = ?',
  //       whereArgs: [category.categoryId],
  //     );
  //     final updatedCategory = await db.query(
  //       categoryTable,
  //       where: 'categoryId = ?',
  //       whereArgs: [category.categoryId],
  //     );
  //     if (updatedCategory.isEmpty) {
  //       log('Failed to retrieve updated category');
  //       return null;
  //     }
  //     return DatabaseCategory.fromRow(updatedCategory.first);
  //   } else {
  //     final categoryId = await db.insert(categoryTable, {
  //       nameColumn: category.name,
  //       categoryIdColumn: category.categoryId,
  //       budgetColumn: category.budget,
  //     });

  //     if (categoryId == 0) {
  //       log('Failed to create category');
  //       return null;
  //     }

  //     final createdCategory = await db.query(
  //       categoryTable,
  //       where: 'categoryId = ?',
  //       whereArgs: [categoryId],
  //     );

  //     if (createdCategory.isEmpty) {
  //       log('Failed to retrieve created category');
  //       return null;
  //     }

  //     return DatabaseCategory.fromRow(createdCategory.first);
  //   }
  // }

  Future<DatabaseCategory?> getCategory({required int categoryId}) async {
    final db = await DatabaseService.db;
    final results = await db.query(
      categoryTable,
      where: 'categoryId = ?',
      whereArgs: [categoryId],
    );

    if (results.isEmpty) {
      log('No category found with id: $categoryId');
      return null;
      // throw Exception('No category found with id: $categoryId');
    }

    return DatabaseCategory.fromRow(results.first);
  }
}
