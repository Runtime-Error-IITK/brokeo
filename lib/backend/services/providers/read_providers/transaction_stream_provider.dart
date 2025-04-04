import 'package:brokeo/backend/models/transaction.dart';
import 'package:brokeo/backend/services/providers/read_providers/user_id_provider.dart'
    show userIdProvider;
import 'package:cloud_firestore/cloud_firestore.dart'
    show FirebaseFirestore, Query, Timestamp;
import 'package:hooks_riverpod/hooks_riverpod.dart';

final transactionStreamProvider = StreamProvider.autoDispose
    .family<List<Transaction>, TransactionFilter>((ref, filter) {
  final userId = ref.watch(userIdProvider);

  if (userId == null) {
    return const Stream.empty();
  }

  // Build the base query
  Query query = FirebaseFirestore.instance
      .collection('transactions')
      .doc(userId)
      .collection('userTransactions');

  // Apply filter for merchantId if provided
  if (filter.merchantId != null && filter.merchantId!.isNotEmpty) {
    query = query.where('merchantId', isEqualTo: filter.merchantId);
  }

  // Apply filter for categoryId if provided
  if (filter.categoryId != null && filter.categoryId!.isNotEmpty) {
    query = query.where('categoryId', isEqualTo: filter.categoryId);
  }

  // Apply filter for startDate if provided
  if (filter.startDate != null) {
    query = query.where('date',
        isGreaterThanOrEqualTo: Timestamp.fromDate(filter.startDate!));
  }

  // Apply filter for endDate if provided
  if (filter.endDate != null) {
    query = query.where('date',
        isLessThanOrEqualTo: Timestamp.fromDate(filter.endDate!));
  }

  final snapshots = query.snapshots();

  return snapshots.map((querySnapshot) {
    return querySnapshot.docs.map((doc) {
      final cloudTransaction = CloudTransaction.fromSnapshot(doc);
      return Transaction.fromCloudTransaction(cloudTransaction);
    }).toList();
  });
});

class TransactionFilter {
  final String? merchantId;
  final String? categoryId;
  final DateTime? startDate;
  final DateTime? endDate;

  @override
  bool operator ==(Object other) {
    return other is TransactionFilter &&
        other.merchantId == merchantId &&
        other.categoryId == categoryId &&
        other.startDate == startDate &&
        other.endDate == endDate;
  }

  @override
  int get hashCode =>
      (merchantId ?? '').hashCode ^
      (categoryId ?? '').hashCode ^
      (startDate?.millisecondsSinceEpoch ?? 0) ^
      (endDate?.millisecondsSinceEpoch ?? 0);

  const TransactionFilter({
    this.merchantId,
    this.categoryId,
    this.startDate,
    this.endDate,
  });
}
