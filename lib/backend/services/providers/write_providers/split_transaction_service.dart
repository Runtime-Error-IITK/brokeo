import 'dart:developer' show log;

import 'package:brokeo/backend/models/split_transaction.dart';
import 'package:brokeo/backend/services/providers/read_providers/user_id_provider.dart'
    show userIdProvider;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// Provider for the split transaction service.
final splitTransactionServiceProvider =
    Provider<SplitTransactionService?>((ref) {
  final userId = ref.watch(userIdProvider);
  if (userId == null) return null;
  return SplitTransactionService(userId: userId);
});

class SplitTransactionService {
  final String userId;

  SplitTransactionService({required this.userId});

  /// Deletes a split transaction.
  Future<bool> deleteSplitTransaction(
      {required String splitTransactionId}) async {
    final docRef = FirebaseFirestore.instance
        .collection('splitTransactions')
        .doc(splitTransactionId);

    try {
      await docRef.delete();
      log("Deleted split transaction with id: $splitTransactionId");
      return true;
    } catch (e) {
      log("Error deleting split transaction: $e");
      return false;
    }
  }

  /// Inserts a new split transaction into Firestore.
  Future<CloudSplitTransaction?> insertSplitTransaction(
      CloudSplitTransaction transaction) async {
    final collectionRef =
        FirebaseFirestore.instance.collection('splitTransactions');

    final docRef = collectionRef.doc();

    try {
      await docRef.set(transaction.toFirestore());
      final docSnap = await docRef.get();
      if (docSnap.exists) {
        log("Created split transaction with id: ${docRef.id}");
        return CloudSplitTransaction.fromSnapshot(docSnap);
      } else {
        log("Failed to retrieve created split transaction");
        return null;
      }
    } catch (e) {
      log("Error creating split transaction: $e");
      return null;
    }
  }

  /// Updates an existing split transaction.
  Future<CloudSplitTransaction?> updateSplitTransaction(
      CloudSplitTransaction transaction) async {
    final docRef =
        FirebaseFirestore.instance.collection('splitTransactions').doc(userId);

    try {
      await docRef.update(transaction.toFirestore());
      final docSnap = await docRef.get();
      if (docSnap.exists) {
        log("Updated split transaction with id: ${transaction.splitTransactionId}");
        return CloudSplitTransaction.fromSnapshot(docSnap);
      } else {
        log("Failed to retrieve updated split transaction");
        return null;
      }
    } catch (e) {
      log("Error updating split transaction: $e");
      return null;
    }
  }
}
