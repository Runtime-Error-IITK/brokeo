import 'dart:developer' show log;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:brokeo/backend/models/schedule.dart';
import 'package:brokeo/backend/services/providers/read_providers/user_id_provider.dart'
    show userIdProvider;

final scheduleServiceProvider = Provider<ScheduleService?>((ref) {
  final userId = ref.watch(userIdProvider);
  // If there's no userId, return null (or you could throw an exception)
  if (userId == null) return null;
  return ScheduleService(userId: userId);
});

class ScheduleService {
  final String userId;

  ScheduleService({required this.userId});

  Future<bool> deleteSchedule({required String scheduleId}) async {
    final scheduleRef = FirebaseFirestore.instance
        .collection('schedules')
        .doc(userId)
        .collection('userSchedules')
        .doc(scheduleId);

    try {
      await scheduleRef.delete();
      log("Deleted schedule with id: $scheduleId");
      return true;
    } catch (e) {
      log("Error deleting schedule: $e");
      return false;
    }
  }

  Future<CloudSchedule?> insertSchedule(CloudSchedule schedule) async {
    final collectionRef = FirebaseFirestore.instance
        .collection('schedules')
        .doc(userId)
        .collection('userSchedules');

    // Create a new document reference; Firestore will generate an id.
    final docRef = collectionRef.doc();

    try {
      await docRef.set(schedule.toFirestore());
      final docSnap = await docRef.get();
      if (docSnap.exists) {
        log("Created schedule with id: ${docRef.id}");
        return CloudSchedule.fromSnapshot(docSnap);
      } else {
        log("Failed to retrieve created schedule");
        return null;
      }
    } catch (e) {
      log("Error creating schedule: $e");
      return null;
    }
  }
}
