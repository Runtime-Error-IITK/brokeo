import 'package:brokeo/backend/models/category.dart';
import 'package:brokeo/backend/services/providers/read_providers/user_id_provider.dart'
    show userIdProvider;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final categoryStreamProvider = StreamProvider.autoDispose
    .family<List<Category>, CategoryFilter>((ref, filter) {
  final userId = ref.watch(userIdProvider);

  if (userId == null) {
    return const Stream.empty();
  }

  // Build the base query.
  Query query = FirebaseFirestore.instance
      .collection('categories')
      .doc(userId)
      .collection('userCategories');

  // Apply filter for categoryId if provided.
  if (filter.categoryId != null && filter.categoryId!.isNotEmpty) {
    query = query.where('categoryId', isEqualTo: filter.categoryId);
  }

  // Apply filter for categoryName if provided.
  if (filter.categoryName != null && filter.categoryName!.isNotEmpty) {
    query = query.where('name', isEqualTo: filter.categoryName);
  }

  final snapshots = query.snapshots();

  return snapshots.map((querySnapshot) {
    return querySnapshot.docs.map((doc) {
      final cloudCategory = CloudCategory.fromSnapshot(doc);
      return Category.fromCloudCategory(cloudCategory);
    }).toList();
  });
});

/// Filter class for categories.
/// It contains optional fields to filter on categoryId and categoryName.
class CategoryFilter {
  final String? categoryId;
  final String? categoryName;

  CategoryFilter({this.categoryId, this.categoryName});
}
