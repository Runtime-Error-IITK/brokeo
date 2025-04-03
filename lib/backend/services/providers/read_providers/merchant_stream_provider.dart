import 'package:brokeo/backend/models/merchant.dart';
import 'package:brokeo/backend/services/providers/read_providers/user_id_provider.dart'
    show userIdProvider;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final merchantStreamProvider =
    StreamProvider.autoDispose<List<Merchant>>((ref) {
  final userId = ref.watch(userIdProvider);

  if (userId == null) {
    return const Stream.empty();
  }

  final snapshots = FirebaseFirestore.instance
      .collection('merchants')
      .doc(userId)
      .collection('userMerchants')
      .snapshots();

  return snapshots.map((querySnapshot) {
    return querySnapshot.docs.map((doc) {
      final cloudMerchant = CloudMerchant.fromSnapshot(doc);
      return Merchant.fromCloudMerchant(cloudMerchant);
    }).toList();
  });
});
