import 'dart:developer' show log;

import 'package:brokeo/backend/models/split_user.dart' show CloudSplitUser;
import 'package:brokeo/backend/services/providers/read_providers/user_id_provider.dart'
    show userIdProvider;
import 'package:cloud_firestore/cloud_firestore.dart' show FirebaseFirestore;
import 'package:hooks_riverpod/hooks_riverpod.dart' show Provider;

/// The provider for SplitUserService, which depends on the current user's ID.
final splitUserServiceProvider = Provider<SplitUserService?>((ref) {
  final userId = ref.watch(userIdProvider);
  if (userId == null) return null;
  return SplitUserService(userId: userId);
});

class SplitUserService {
  final String userId;

  SplitUserService({required this.userId});

  /// Deletes a split user. [splitUserId] should be the document ID of the split user entry.
  Future<bool> deleteSplitUser({required String splitUserId}) async {
    final docRef = FirebaseFirestore.instance
        .collection('splitUsers')
        .doc(userId)
        .collection('userSplitUsers')
        .doc(splitUserId);

    try {
      await docRef.delete();
      log("Deleted split user with id: $splitUserId");
      return true;
    } catch (e) {
      log("Error deleting split user: $e");
      return false;
    }
  }

  /// Inserts a new split user.
  /// Returns the newly created CloudSplitUser if successful; otherwise, returns null.
  Future<CloudSplitUser?> insertSplitUser(CloudSplitUser splitUser) async {
    final collectionRef = FirebaseFirestore.instance
        .collection('splitUsers')
        .doc(userId)
        .collection('userSplitUsers');
    final docRef = collectionRef.doc();

    try {
      await docRef.set(splitUser.toFirestore());
      final docSnap = await docRef.get();
      if (docSnap.exists) {
        log("Created split user with id: ${docRef.id}");
        return CloudSplitUser.fromSnapshot(docSnap);
      } else {
        log("Failed to retrieve created split user");
        return null;
      }
    } catch (e) {
      log("Error creating split user: $e");
      return null;
    }
  }

  /// Updates an existing split user.
  /// [splitUser.userId] should contain the document ID of the split user entry.
  Future<CloudSplitUser?> updateSplitUser(CloudSplitUser splitUser) async {
    final docRef = FirebaseFirestore.instance
        .collection('splitUsers')
        .doc(userId)
        .collection('userSplitUsers')
        .doc(splitUser.userId);

    try {
      await docRef.update(splitUser.toFirestore());
      final docSnap = await docRef.get();
      if (docSnap.exists) {
        log("Updated split user with id: ${splitUser.userId}");
        return CloudSplitUser.fromSnapshot(docSnap);
      } else {
        log("Failed to retrieve updated split user");
        return null;
      }
    } catch (e) {
      log("Error updating split user: $e");
      return null;
    }
  }
}
