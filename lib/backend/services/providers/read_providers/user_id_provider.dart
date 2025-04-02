import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// Provider for FirebaseAuth instance
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

// StreamProvider for the current Firebase user
final firebaseUserProvider = StreamProvider<User?>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  return auth.authStateChanges();
});

// Provider to extract the current user's UID (or null if not logged in)
final userIdProvider = Provider<String?>(
  (ref) {
    final userAsync = ref.watch(firebaseUserProvider);
    // AsData returns the data if available, otherwise null
    return userAsync.asData?.value?.uid;
  },
);

final userMetadataStreamProvider =
    StreamProvider.autoDispose<Map<String, dynamic>>((ref) {
  final userId = ref.watch(userIdProvider);
  if (userId == null) {
    return const Stream.empty();
  }
  return FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .snapshots()
      .map((doc) => doc.data() ?? {});
});
