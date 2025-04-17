import 'dart:developer' show log;

import 'package:brokeo/backend/models/transaction.dart';
import 'package:brokeo/backend/services/providers/read_providers/user_id_provider.dart'
    show userIdProvider;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final transactionServiceProvider = Provider<TransactionService?>(
  (ref) {
    final userId = ref.watch(userIdProvider);
    // If there's no userId, return null (or you could throw an exception)
    if (userId == null) return null;
    return TransactionService(userId: userId);
  },
);

class TransactionService {
  final String userId;

  TransactionService({required this.userId});

  Future<bool> deleteTransaction({required String transactionId}) async {
    final transactionRef = FirebaseFirestore.instance
        .collection('transactions')
        .doc(userId)
        .collection('userTransactions')
        .doc(transactionId);

    try {
      await transactionRef.delete();
      log("Deleted transaction with id: $transactionId");
      return true;
    } catch (e) {
      log("Error deleting transaction: $e");
      return false;
    }
  }

  Future<CloudTransaction?> insertTransaction(
      CloudTransaction transaction) async {
    final collectionRef = FirebaseFirestore.instance
        .collection('transactions')
        .doc(userId)
        .collection('userTransactions');

    final docRef = collectionRef.doc();

    try {
      await docRef.set(transaction.toFirestore());
      final docSnap = await docRef.get();
      if (docSnap.exists) {
        log("Created transaction with id: ${docRef.id}");
        return CloudTransaction.fromSnapshot(docSnap);
      } else {
        log("Failed to retrieve created transaction");
        return null;
      }
    } catch (e) {
      log("Error creating transaction: $e");
      return null;
    }
  }

  Future<CloudTransaction?> updateCloudTransaction(
      CloudTransaction transaction) async {
    final transactionRef = FirebaseFirestore.instance
        .collection('transactions')
        .doc(userId)
        .collection('userTransactions')
        .doc(transaction.transactionId);

    try {
      await transactionRef.update(transaction.toFirestore());
      final docSnap = await transactionRef.get();
      if (docSnap.exists) {
        log("Updated transaction with id: ${transaction.transactionId}");
        return CloudTransaction.fromSnapshot(docSnap);
      } else {
        log("Failed to retrieve updated transaction");
        return null;
      }
    } catch (e) {
      log("Error updating transaction: $e");
      return null;
    }
  }
}
