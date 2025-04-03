import 'package:brokeo/backend/services/providers/read_providers/user_id_provider.dart'
    show userIdProvider;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer';

import 'package:hooks_riverpod/hooks_riverpod.dart';

final userMetadataServiceProvider = Provider<UserMetadataService?>((ref) {
  final userId = ref.watch(userIdProvider);
  // If there's no userId, return null (or you could throw an exception)
  if (userId == null) return null;
  return UserMetadataService(userId: userId);
});

class UserMetadataService {
  final String userId;

  UserMetadataService({required this.userId});

  Future<bool> deleteUserMetadata() async {
    final docRef = FirebaseFirestore.instance.collection('users').doc(userId);
    try {
      await docRef.delete();
      log('Deleted user metadata for user: $userId');
      return true;
    } catch (e) {
      log('Error deleting user metadata: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> insertUserMetadata({
    required Map<String, dynamic> metadata,
  }) async {
    final docRef = FirebaseFirestore.instance.collection('users').doc(userId);
    try {
      await docRef.set(metadata);
      final docSnap = await docRef.get();
      if (docSnap.exists) {
        log('Created user metadata for user: $userId');
        return docSnap.data();
      } else {
        log('Failed to retrieve created user metadata for user: $userId');
        return null;
      }
    } catch (e) {
      log('Error creating user metadata: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> updateUserMetadata({
    required Map<String, dynamic> metadata,
  }) async {
    final docRef = FirebaseFirestore.instance.collection('users').doc(userId);
    try {
      await docRef.update(metadata);
      final docSnap = await docRef.get();
      if (docSnap.exists) {
        log('Updated user metadata for user: $userId');
        return docSnap.data();
      } else {
        log('Failed to retrieve updated user metadata for user: $userId');
        return null;
      }
    } catch (e) {
      log('Error updating user metadata: $e');
      return null;
    }
  }
}
