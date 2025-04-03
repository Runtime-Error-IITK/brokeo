import 'package:brokeo/backend/models/schedule.dart'
    show Schedule, CloudSchedule;
import 'package:brokeo/backend/services/providers/read_providers/user_id_provider.dart'
    show userIdProvider;
import 'package:cloud_firestore/cloud_firestore.dart'
    show FieldPath, FirebaseFirestore, Query;
import 'package:hooks_riverpod/hooks_riverpod.dart';

final scheduleStreamProvider = StreamProvider.autoDispose
    .family<List<Schedule>, ScheduleFilter>((ref, filter) {
  final userId = ref.watch(userIdProvider);
  if (userId == null) {
    return const Stream.empty();
  }

  // Build the base query.
  Query query = FirebaseFirestore.instance
      .collection('schedules')
      .doc(userId)
      .collection('userSchedules');

  // If a scheduleId filter is provided, filter on the document ID.
  if (filter.scheduleId != null && filter.scheduleId!.isNotEmpty) {
    query = query.where(FieldPath.documentId, isEqualTo: filter.scheduleId);
  }

  // If a timePeriod filter is provided, apply it.
  if (filter.timePeriod != null) {
    query = query.where('timePeriod', isEqualTo: filter.timePeriod);
  }

  final snapshots = query.snapshots();

  return snapshots.map((querySnapshot) {
    return querySnapshot.docs.map((doc) {
      final cloudSchedule = CloudSchedule.fromSnapshot(doc);
      return Schedule.fromCloudSchedule(cloudSchedule);
    }).toList();
  });
});

/// Filter class for schedules.
/// Optionally filter by scheduleId (document ID) and/or timePeriod.
class ScheduleFilter {
  final String? scheduleId;
  final int? timePeriod;

  const ScheduleFilter({this.scheduleId, this.timePeriod});

  @override
  bool operator ==(Object other) {
    return other is ScheduleFilter &&
        other.scheduleId == scheduleId &&
        other.timePeriod == timePeriod;
  }

  @override
  int get hashCode => (scheduleId ?? '').hashCode ^ (timePeriod ?? 0).hashCode;
}
