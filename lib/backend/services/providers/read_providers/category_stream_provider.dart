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
    // Use FieldPath.documentId to filter by document id.
    query = query.where(FieldPath.documentId, isEqualTo: filter.categoryId);
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
/// Contains optional fields for filtering on categoryId and categoryName.
class CategoryFilter {
  final String? categoryId;
  final String? categoryName;

  const CategoryFilter({this.categoryId, this.categoryName});

  @override
  bool operator ==(Object other) {
    return other is CategoryFilter &&
        other.categoryId == categoryId &&
        other.categoryName == categoryName;
  }

  @override
  int get hashCode =>
      (categoryId ?? '').hashCode ^ (categoryName ?? '').hashCode;
}
