import 'package:brokeo/backend/models/schedule.dart'
    show Schedule, CloudSchedule;
import 'package:brokeo/backend/services/providers/read_providers/user_id_provider.dart'
    show userIdProvider;
import 'package:cloud_firestore/cloud_firestore.dart' show FirebaseFirestore;
import 'package:hooks_riverpod/hooks_riverpod.dart';

final scheduleStreamProvider = StreamProvider.autoDispose<List<Schedule>>(
  (ref) {
    final userId = ref.watch(userIdProvider);
    if (userId == null) {
      return const Stream.empty();
    }

    final snapshots = FirebaseFirestore.instance
        .collection('schedules')
        .doc(userId)
        .collection('userSchedules')
        .snapshots();

    return snapshots.map((querySnapshot) {
      return querySnapshot.docs.map((doc) {
        final cloudSchedule = CloudSchedule.fromSnapshot(doc);
        return Schedule.fromCloudSchedule(cloudSchedule);
      }).toList();
    });
  },
);
