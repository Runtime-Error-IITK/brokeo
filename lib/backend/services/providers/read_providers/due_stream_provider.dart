import 'package:brokeo/backend/models/due.dart';
import 'package:brokeo/backend/services/providers2/read_providers/user_id_provider.dart'
    show userIdProvider;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final dueStreamProvider = StreamProvider.autoDispose<List<Due>>((ref) {
  final userId = ref.watch(userIdProvider);

  if (userId == null) {
    return const Stream.empty();
  }

  final snapshots = FirebaseFirestore.instance
      .collection('dues')
      .doc(userId)
      .collection('userDues')
      .snapshots();

  return snapshots.map((querySnapshot) {
    return querySnapshot.docs.map((doc) {
      final cloudDue = CloudDue.fromSnapshot(doc);
      return Due.fromCloudDue(cloudDue);
    }).toList();
  });
});
