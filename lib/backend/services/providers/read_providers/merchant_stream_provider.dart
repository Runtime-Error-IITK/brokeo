import 'package:brokeo/backend/models/merchant.dart';
import 'package:brokeo/backend/services/providers/read_providers/user_id_provider.dart'
    show userIdProvider;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final merchantStreamProvider = StreamProvider.autoDispose
    .family<List<Merchant>, MerchantFilter>((ref, filter) {
  final userId = ref.watch(userIdProvider);

  if (userId == null) {
    return const Stream.empty();
  }

  // Build the base query
  Query query = FirebaseFirestore.instance
      .collection('merchants')
      .doc(userId)
      .collection('userMerchants');

  // If a merchantId filter is provided, filter on the document ID.
  if (filter.merchantId != null && filter.merchantId!.isNotEmpty) {
    query = query.where(FieldPath.documentId, isEqualTo: filter.merchantId);
  }

  // Apply filter for merchantName if provided
  if (filter.merchantName != null && filter.merchantName!.isNotEmpty) {
    query = query.where('name', isEqualTo: filter.merchantName);
  }

  final snapshots = query.snapshots();

  return snapshots.map((querySnapshot) {
    return querySnapshot.docs.map((doc) {
      final cloudMerchant = CloudMerchant.fromSnapshot(doc);
      return Merchant.fromCloudMerchant(cloudMerchant);
    }).toList();
  });
});

class MerchantFilter {
  final String? merchantId;
  final String? merchantName;

  const MerchantFilter({this.merchantId, this.merchantName});

  @override
  bool operator ==(Object other) {
    return other is MerchantFilter &&
        other.merchantId == merchantId &&
        other.merchantName == merchantName;
  }

  @override
  int get hashCode =>
      (merchantId ?? '').hashCode ^ (merchantName ?? '').hashCode;
}
