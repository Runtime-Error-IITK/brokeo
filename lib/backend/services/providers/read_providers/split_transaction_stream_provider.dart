import 'dart:developer' show log;

import 'package:brokeo/backend/models/split_transaction.dart';
import 'package:brokeo/backend/models/transaction.dart';
import 'package:brokeo/backend/services/providers/read_providers/user_id_provider.dart'
    show userMetadataStreamProvider;
import 'package:cloud_firestore/cloud_firestore.dart'
    show FieldPath, FirebaseFirestore, Query, QuerySnapshot, Timestamp;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rxdart/rxdart.dart';

final splitTransactionStreamProvider = StreamProvider.autoDispose
    .family<List<SplitTransaction>, SplitTransactionFilter>(
  (ref, filter) {
    // Watch the user metadata provider which returns AsyncValue<Map<String, dynamic>>
    final userMetadataAsync = ref.watch(userMetadataStreamProvider);

    return userMetadataAsync.when(
      data: (userMetadata) {
        // Extract the phone number from the metadata
        final phoneNumber = userMetadata['phone'] as String?;
        if (phoneNumber == null) {
          return const Stream.empty();
        }
        // log("Hello ");

        // If otherUserId is provided, assume it now represents the other user's phone number.
        if (filter.first != null && filter.second != null) {
          log("sad: ${filter.first}, ${filter.second}");
          // Condition 1:
          // - transaction.phoneNumber equals the current phone number
          // - splitAmounts.<otherPhone> is not null
          final query = FirebaseFirestore.instance
              .collection('splitTransactions')
              .where('userPhone', isEqualTo: filter.first)
              .orderBy('date', descending: true);

          // Condition 2:
          // - transaction.phoneNumber equals the other user's phone number
          // - splitAmounts.<currentPhone> is not null

          return query.snapshots().map(
                (snapshot) => snapshot.docs.map((doc) {
                  // log(doc.data().toString());
                  final cloudSplitTransaction =
                      CloudSplitTransaction.fromSnapshot(doc);
                  return SplitTransaction.fromCloudSplitTransaction(
                      cloudSplitTransaction);
                }).toList(),
              );
        } else {
          log("entered else");
          // Fallback: if otherUserId is not provided, use a query filtering only on phoneNumber.
          Query query = FirebaseFirestore.instance
              .collection('splitTransactions')
              // .where('splitAmounts.$phoneNumber', isNotEqualTo: null)
              // .orderBy('splitAmounts.$phoneNumber')
              .orderBy('date', descending: true);
          // log('works till here');

          return query.snapshots().map((snapshot) {
            // Filter out documents where 'splitAmounts' doesn't have the key or its value is null.
            final filteredDocs = snapshot.docs.where((doc) {
              final data = doc.data();
              // Optionally check that 'splitAmounts' exists to avoid potential null errors.

              return (data! as Map)['splitAmounts'][phoneNumber] != null;
            }).toList();

            return filteredDocs.map((doc) {
              final cloudSplitTransaction =
                  CloudSplitTransaction.fromSnapshot(doc);
              return SplitTransaction.fromCloudSplitTransaction(
                  cloudSplitTransaction);
            }).toList();
          });
        }
      },
      loading: () => const Stream.empty(),
      error: (error, stack) => const Stream.empty(),
    );
  },
);

class SplitTransactionFilter {
  final String? first, second;

  SplitTransactionFilter({this.first, this.second});

  @override
  bool operator ==(Object other) {
    return other is SplitTransactionFilter &&
        other.first == first &&
        other.second == second;
  }

  @override
  int get hashCode => first.hashCode ^ second.hashCode;
}
