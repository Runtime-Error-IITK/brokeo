import 'dart:developer' show log;

import 'package:brokeo/backend/models/category.dart';
import 'package:brokeo/backend/services/crud/category_service.dart';

class CategoryManager {
  List<Category> _categories = [];
  List<Category> get categories => _categories;

  Future<Category?> addCategory(Category category) async {
    final categoryService = CategoryService();
    final databaseCategory = DatabaseCategory.fromCategory(category);
    final createdCategory =
        await categoryService.insertCategory(databaseCategory);

    if (createdCategory != null) {
      final newCategory = Category.fromDatabaseCategory(createdCategory);
      _categories.add(newCategory);
      return newCategory;
    } else {
      log("Failed to add category");
      return null;
    }
  }

  Future<Category?> updateCategory(Category category) async {
    final categoryService = CategoryService();
    final databaseCategory = DatabaseCategory.fromCategory(category);
    final updatedCategory =
        await categoryService.updateCategory(databaseCategory);

    if (updatedCategory == null) {
      log("Failed to update category");
      return null;
    }
    final newCategory = Category.fromDatabaseCategory(updatedCategory);
    final index =
        _categories.indexWhere((c) => c.categoryId == category.categoryId);

    if (index != -1) {
      _categories[index] = newCategory;
      return newCategory;
    } else {
      log("Failed to find category to update");
      return null;
    }
  }

  Future<void> deleteCategory(int categoryId) async {
    final categoryService = CategoryService();
    await categoryService.deleteCategory(categoryId: categoryId);
    _categories.removeWhere((category) => category.categoryId == categoryId);
  }

  CategoryManager copyWith() {
    final newCategoryManager = CategoryManager();
    for (final category in _categories) {
      newCategoryManager._categories.add(category);
    }
    return newCategoryManager;
  }

  Future<void> loadCategories() async {
    final categoryService = CategoryService();
    final categories = await categoryService.getAllCategories();
    _categories = categories
        .map((category) => Category.fromDatabaseCategory(category))
        .toList();
  }
}
