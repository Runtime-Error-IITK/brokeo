import 'dart:developer' show log;

import 'package:brokeo/backend/models/split_transaction.dart';
import 'package:brokeo/backend/models/transaction.dart';
import 'package:brokeo/backend/services/providers/read_providers/user_id_provider.dart'
    show userMetadataStreamProvider;
import 'package:cloud_firestore/cloud_firestore.dart'
    show FirebaseFirestore, Query, Timestamp, QuerySnapshot;
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
        if (filter.otherPhone != null) {
          // Condition 1:
          // - transaction.phoneNumber equals the current phone number
          // - splitAmounts.<otherPhone> is not null
          final query1 = FirebaseFirestore.instance
              .collection('splitTransactions')
              .where('phoneNumber', isEqualTo: phoneNumber)
              .where('splitAmounts.${filter.otherPhone}', isNotEqualTo: null);

          // Condition 2:
          // - transaction.phoneNumber equals the other user's phone number
          // - splitAmounts.<currentPhone> is not null
          final query2 = FirebaseFirestore.instance
              .collection('splitTransactions')
              .where('phoneNumber', isEqualTo: filter.otherPhone)
              .where('splitAmounts.$phoneNumber', isNotEqualTo: null);

          // Listen to both query snapshots.
          final stream1 = query1.snapshots();
          final stream2 = query2.snapshots();

          // Combine both streams into one.
          return Rx.combineLatest2<QuerySnapshot, QuerySnapshot,
              List<SplitTransaction>>(
            stream1,
            stream2,
            (snap1, snap2) {
              // Merge the document lists.
              final allDocs = [...snap1.docs, ...snap2.docs];

              // Optionally sort by 'date' in descending order.
              allDocs.sort((a, b) {
                final dateA =
                    (a.data() as Map<String, dynamic>)['date'] as Timestamp;
                final dateB =
                    (b.data() as Map<String, dynamic>)['date'] as Timestamp;
                return dateB.compareTo(dateA);
              });

              // Map documents to SplitTransaction objects.
              return allDocs.map((doc) {
                final cloudSplitTransaction =
                    CloudSplitTransaction.fromSnapshot(doc);
                return SplitTransaction.fromCloudSplitTransaction(
                    cloudSplitTransaction);
              }).toList();
            },
          );
        } else {
          // log("why god");
          // Fallback: if otherUserId is not provided, use a query filtering only on phoneNumber.
          Query query = FirebaseFirestore.instance
              .collection('splitTransactions')
              .where('splitAmounts.$phoneNumber', isNotEqualTo: null)
              .orderBy('date', descending: true);
          // log('works till here');

          return query.snapshots().map(
                (snapshot) => snapshot.docs.map((doc) {
                  log(doc.data().toString());
                  final cloudSplitTransaction =
                      CloudSplitTransaction.fromSnapshot(doc);
                  return SplitTransaction.fromCloudSplitTransaction(
                      cloudSplitTransaction);
                }).toList(),
              );
        }
      },
      loading: () => const Stream.empty(),
      error: (error, stack) => const Stream.empty(),
    );
  },
);

class SplitTransactionFilter {
  final String? otherPhone;

  SplitTransactionFilter({this.otherPhone});

  @override
  bool operator ==(Object other) {
    return other is SplitTransactionFilter && other.otherPhone == otherPhone;
  }

  @override
  int get hashCode => otherPhone.hashCode;
}
