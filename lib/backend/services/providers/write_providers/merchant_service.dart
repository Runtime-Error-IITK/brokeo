import 'dart:developer' show log;

import 'package:brokeo/backend/models/merchant.dart' show CloudMerchant;
import 'package:brokeo/backend/services/providers/read_providers/user_id_provider.dart'
    show userIdProvider;
import 'package:cloud_firestore/cloud_firestore.dart' show FirebaseFirestore;
import 'package:hooks_riverpod/hooks_riverpod.dart' show Provider;

final merchantServiceProvider = Provider<MerchantService?>(
  (ref) {
    final userId = ref.watch(userIdProvider);
    // If there's no userId, return null (or you could throw an exception)
    if (userId == null) return null;
    return MerchantService(userId: userId);
  },
);

class MerchantService {
  final String userId;

  MerchantService({required this.userId});

  Future<bool> deleteMerchant({required String merchantId}) async {
    final merchantRef = FirebaseFirestore.instance
        .collection('merchants')
        .doc(userId)
        .collection('userMerchants')
        .doc(merchantId);

    try {
      await merchantRef.delete();
      log("Deleted merchant with id: $merchantId");
      return true;
    } catch (e) {
      log("Error deleting merchant: $e");
      return false;
    }
  }

  Future<CloudMerchant?> insertMerchant(CloudMerchant merchant) async {
    final collectionRef = FirebaseFirestore.instance
        .collection('merchants')
        .doc(userId)
        .collection('userMerchants');

    final docRef = collectionRef.doc();

    try {
      await docRef.set(merchant.toFirestore());
      final docSnap = await docRef.get();
      if (docSnap.exists) {
        log("Created merchant with id: ${docRef.id}");
        return CloudMerchant.fromSnapshot(docSnap);
      } else {
        log("Failed to retrieve created merchant");
        return null;
      }
    } catch (e) {
      log("Error creating merchant: $e");
      return null;
    }
  }

  Future<CloudMerchant?> updateCloudMerchant(CloudMerchant merchant) async {
    final docRef = FirebaseFirestore.instance
        .collection('merchants')
        .doc(userId)
        .collection('userMerchants')
        .doc(merchant.merchantId);

    try {
      await docRef.update(merchant.toFirestore());
      final docSnap = await docRef.get();
      if (docSnap.exists) {
        log("Updated merchant with id: ${docRef.id}");
        return CloudMerchant.fromSnapshot(docSnap);
      } else {
        log("Failed to retrieve updated merchant");
        return null;
      }
    } catch (e) {
      log("Error updating merchant: $e");
      return null;
    }
  }
}
