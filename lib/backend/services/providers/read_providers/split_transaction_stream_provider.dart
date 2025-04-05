import 'package:brokeo/backend/models/split_transaction.dart';
import 'package:brokeo/backend/models/transaction.dart';
import 'package:brokeo/backend/services/providers/read_providers/user_id_provider.dart'
    show userIdProvider;
import 'package:cloud_firestore/cloud_firestore.dart'
    show DocumentSnapshot, FirebaseFirestore, Query, QuerySnapshot, Timestamp;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rxdart/rxdart.dart';

final splitTransactionStreamProvider = StreamProvider.autoDispose
    .family<List<SplitTransaction>, SplitTransactionFilter>(
  (ref, filter) {
    final userId = ref.watch(userIdProvider);

    if (userId == null) {
      return const Stream.empty();
    }

    // If otherUserId is provided, build two queries to satisfy either condition.
    if (filter.otherUserId != null) {
      // Condition 1:
      // - transaction.userId equals current userId
      // - splitAmounts.<otherUserId> is not null
      final query1 = FirebaseFirestore.instance
          .collection('splitTransactions')
          .where('userId', isEqualTo: userId)
          .where('splitAmounts.${filter.otherUserId}', isNotEqualTo: null);

      // Condition 2:
      // - transaction.userId equals otherUserId
      // - splitAmounts.<userId> is not null
      final query2 = FirebaseFirestore.instance
          .collection('splitTransactions')
          .where('userId', isEqualTo: filter.otherUserId)
          .where('splitAmounts.$userId', isNotEqualTo: null);

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
      // Fallback: if otherUserId is not provided, use a query filtering only on userId.
      Query query = FirebaseFirestore.instance
          .collection('splitTransactions')
          .where('splitAmounts.$userId', isNotEqualTo: null)
          .orderBy('date', descending: true);

      return query.snapshots().map(
            (snapshot) => snapshot.docs.map((doc) {
              final cloudSplitTransaction =
                  CloudSplitTransaction.fromSnapshot(doc);
              return SplitTransaction.fromCloudSplitTransaction(
                  cloudSplitTransaction);
            }).toList(),
          );
    }
  },
);

class SplitTransactionFilter {
  final String? otherUserId;

  SplitTransactionFilter({this.otherUserId});

  @override
  bool operator ==(Object other) {
    return other is SplitTransactionFilter && other.otherUserId == otherUserId;
  }

  @override
  int get hashCode => otherUserId.hashCode;
}
