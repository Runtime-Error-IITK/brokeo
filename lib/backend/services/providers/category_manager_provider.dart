import 'package:brokeo/backend/models/category.dart';
import 'package:brokeo/backend/services/managers/category_manager.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final categoryManaagerProvider =
    StateNotifierProvider<CategoryManagerProvider, CategoryManager>(
  (ref) {
    final categoryManager = CategoryManagerProvider(ref: ref);
    return categoryManager;
  },
);

class CategoryManagerProvider extends StateNotifier<CategoryManager> {
  final Ref ref;

  CategoryManagerProvider({required this.ref}) : super(CategoryManager()) {
    loadCategories();
  }

  Future<Category?> addCategory(Category category) async {
    final newCategory = await state.addCategory(category);
    state = state.copyWith();
    return newCategory;
  }

  Future<Category?> updateCategory(Category category) async {
    final updatedCategory = await state.updateCategory(category);
    state = state.copyWith();
    return updatedCategory;
  }

  Future<void> deleteCategory(int categoryId) async {
    await state.deleteCategory(categoryId);
    state = state.copyWith();
  }

  void loadCategories() async {
    await state.loadCategories();
    state = state.copyWith();
  }
}
