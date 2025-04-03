import 'package:brokeo/backend/models/transaction.dart';
import 'package:brokeo/backend/services/providers/read_providers/user_id_provider.dart'
    show userIdProvider;
import 'package:cloud_firestore/cloud_firestore.dart' show FirebaseFirestore;
import 'package:hooks_riverpod/hooks_riverpod.dart';

final transactionStreamProvider = StreamProvider.autoDispose<List<Transaction>>(
  (ref) {
    final userId = ref.watch(userIdProvider);

    if (userId == null) {
      return const Stream.empty();
    }

    final snapshots = FirebaseFirestore.instance
        .collection('transactions')
        .doc(userId)
        .collection('userTransactions')
        .snapshots();

    return snapshots.map((querySnapshot) {
      return querySnapshot.docs.map((doc) {
        final cloudTransaction = CloudTransaction.fromSnapshot(doc);
        return Transaction.fromCloudTransaction(cloudTransaction);
      }).toList();
    });
  },
);
