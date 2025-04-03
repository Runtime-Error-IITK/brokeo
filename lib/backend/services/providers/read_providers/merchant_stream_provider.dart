import 'package:brokeo/backend/models/merchant.dart';
import 'package:brokeo/backend/services/providers/read_providers/user_id_provider.dart'
    show userIdProvider;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final merchantStreamProvider = StreamProvider.autoDispose
    .family<List<Merchant>, String?>((ref, filterMerchantId) {
  final userId = ref.watch(userIdProvider);

  if (userId == null) {
    return const Stream.empty();
  }

  // Build the base query
  Query query = FirebaseFirestore.instance
      .collection('merchants')
      .doc(userId)
      .collection('userMerchants');

  // If a filter is provided, apply it
  if (filterMerchantId != null && filterMerchantId.isNotEmpty) {
    query = query.where('merchantId', isEqualTo: filterMerchantId);
  }

  final snapshots = query.snapshots();

  return snapshots.map((querySnapshot) {
    return querySnapshot.docs.map((doc) {
      final cloudMerchant = CloudMerchant.fromSnapshot(doc);
      return Merchant.fromCloudMerchant(cloudMerchant);
    }).toList();
  });
});
