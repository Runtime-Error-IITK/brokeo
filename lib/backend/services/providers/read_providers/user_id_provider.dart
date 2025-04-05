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
    // final userAsync = ref.watch(firebaseUserProvider);
    // AsData returns the data if available, otherwise null
    return "Rb7tSCHRLVcui8kBatw0hkKKApj2";
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
      .map((snapshot) {
    if (!snapshot.exists || snapshot.data() == null) {
      // Return an empty map if the document doesn't exist
      return <String, dynamic>{};
    }

    final data = snapshot.data()! as Map<String, dynamic>;

    // Element-wise casting
    final budgetNum =
        data['budget'] as num?; // Firestore can return int or double
    final budgetDouble = budgetNum?.toDouble() ?? 0.0;

    final emailStr = data['email'] as String? ?? "";
    final nameStr = data['name'] as String? ?? "";

    return {
      'budget': budgetDouble,
      'email': emailStr,
      'name': nameStr,
    };
  });
});

final userNameProvider =
    StreamProvider.autoDispose.family<String, String>((ref, userId) {
  return FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .snapshots()
      .map((snapshot) {
    if (!snapshot.exists || snapshot.data() == null) {
      // Return an empty string if no data is found.
      return "";
    }
    final data = snapshot.data()!;
    // Assumes the user's name is stored under the 'name' field.
    return data['name'] as String? ?? "";
  });
});
