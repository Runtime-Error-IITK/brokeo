import 'package:brokeo/backend/models/category.dart';
import 'package:brokeo/backend/services/providers2/read_providers/user_id_provider.dart'
    show userIdProvider;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final categoryStreamProvider =
    StreamProvider.autoDispose<List<Category>>((ref) {
  final userId = ref.watch(userIdProvider);

  if (userId == null) {
    return const Stream.empty();
  }

  final snapshots = FirebaseFirestore.instance
      .collection('categories')
      .doc(userId)
      .collection('userCategories')
      .snapshots();

  return snapshots.map((querySnapshot) {
    return querySnapshot.docs.map((doc) {
      final cloudCategory = CloudCategory.fromSnapshot(doc);
      return Category.fromCloudCategory(cloudCategory);
    }).toList();
  });
});
