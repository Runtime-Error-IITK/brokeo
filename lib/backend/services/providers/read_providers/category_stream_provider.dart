import 'package:brokeo/backend/models/category.dart';
import 'package:brokeo/backend/services/providers/read_providers/user_id_provider.dart'
    show userIdProvider;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final categoryStreamProvider = StreamProvider.autoDispose
    .family<List<Category>, String?>((ref, filterCategoryId) {
  final userId = ref.watch(userIdProvider);

  if (userId == null) {
    return const Stream.empty();
  }

  // Build the base query.
  Query query = FirebaseFirestore.instance
      .collection('categories')
      .doc(userId)
      .collection('userCategories');

  // Apply filter if provided.
  if (filterCategoryId != null && filterCategoryId.isNotEmpty) {
    query = query.where('categoryId', isEqualTo: filterCategoryId);
  }

  final snapshots = query.snapshots();

  return snapshots.map((querySnapshot) {
    return querySnapshot.docs.map((doc) {
      final cloudCategory = CloudCategory.fromSnapshot(doc);
      return Category.fromCloudCategory(cloudCategory);
    }).toList();
  });
});
