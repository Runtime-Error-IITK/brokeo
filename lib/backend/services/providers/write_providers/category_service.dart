import 'dart:developer' show log;

import 'package:brokeo/backend/models/category.dart';
import 'package:brokeo/backend/services/providers/read_providers/user_id_provider.dart'
    show userIdProvider;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final categoryServiceProvider = Provider<CategoryService?>(
  (ref) {
    final userId = ref.watch(userIdProvider);
    // If there's no userId, return null (or you could throw an exception)
    if (userId == null) return null;
    return CategoryService(userId: userId);
  },
);

class CategoryService {
  final String userId;

  CategoryService({required this.userId});

  Future<bool> deleteCategory({
    required String categoryId,
  }) async {
    final categoryRef = FirebaseFirestore.instance
        .collection('categories')
        .doc(userId)
        .collection('userCategories')
        .doc(categoryId);

    try {
      await categoryRef.delete();
      log('Deleted category with id: $categoryId');
      return true;
    } catch (e) {
      log('Error deleting category: $e');
      return false;
    }
  }

  Future<CloudCategory?> insertCategory(CloudCategory category) async {
    final collectionRef = FirebaseFirestore.instance
        .collection('categories')
        .doc(userId)
        .collection('userCategories');

    final docRef = collectionRef.doc();

    try {
      await docRef.set(category.toFirestore());
      final docSnap = await docRef.get();
      if (docSnap.exists) {
        log('Created category with id: ${docRef.id}');
        return CloudCategory.fromSnapshot(docSnap);
      } else {
        log('Failed to retrieve created category');
        return null;
      }
    } catch (e) {
      log('Error creating category: $e');
      return null;
    }
  }

  Future<CloudCategory?> updateCloudCategory(CloudCategory category) async {
    final docRef = FirebaseFirestore.instance
        .collection('categories')
        .doc(userId)
        .collection('userCategories')
        .doc(category.categoryId);

    try {
      await docRef.update(category.toFirestore());
      final docSnap = await docRef.get();
      if (docSnap.exists) {
        log('Updated category with id: ${docSnap.id}');
        return CloudCategory.fromSnapshot(docSnap);
      } else {
        log('Failed to retrieve updated category');
        return null;
      }
    } catch (e) {
      log('Error updating category: $e');
      return null;
    }
  }
}
