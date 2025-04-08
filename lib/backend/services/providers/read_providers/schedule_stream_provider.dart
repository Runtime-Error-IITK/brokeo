import 'package:cloud_firestore/cloud_firestore.dart'
    show FirebaseFirestore, Query, Timestamp;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:brokeo/backend/models/schedule.dart';
import 'package:brokeo/backend/services/providers/read_providers/user_id_provider.dart'
    show userIdProvider;

final scheduleStreamProvider = StreamProvider.autoDispose
    .family<List<Schedule>, ScheduleFilter>((ref, filter) {
  final userId = ref.watch(userIdProvider);

  if (userId == null) {
    return const Stream.empty();
  }

  // Build the base query using the userId.
  // Adjust the collection path as per your Firestore data structure.
  Query query = FirebaseFirestore.instance
      .collection('schedules')
      .doc(userId)
      .collection('userSchedules');

  // Apply filter: Only include schedules whose date is after the provided startDate.
  if (filter.startDate != null) {
    query = query.where(dateColumn,
        isGreaterThan: Timestamp.fromDate(filter.startDate!));
  }

  // Order by date in descending order (latest schedules first).
  query = query.orderBy(dateColumn, descending: true);

  final snapshots = query.snapshots();

  return snapshots.map((querySnapshot) {
    return querySnapshot.docs.map((doc) {
      final cloudSchedule = CloudSchedule.fromSnapshot(doc);
      return Schedule.fromCloudSchedule(cloudSchedule);
    }).toList();
  });
});

class ScheduleFilter {
  final DateTime? startDate;

  const ScheduleFilter({
    this.startDate,
  });

  @override
  bool operator ==(Object other) {
    return other is ScheduleFilter && other.startDate == startDate;
  }

  @override
  int get hashCode => (startDate?.millisecondsSinceEpoch ?? 0);
}
