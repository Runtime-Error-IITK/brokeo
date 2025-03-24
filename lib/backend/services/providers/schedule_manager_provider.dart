import 'package:brokeo/backend/models/schedule.dart';
import 'package:brokeo/backend/services/managers/schedule_manager.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final scheduleManagerProvider =
    StateNotifierProvider<ScheduleManagerProvider, ScheduleManager>(
  (ref) {
    final scheduleManager = ScheduleManagerProvider(ref: ref);
    return scheduleManager;
  },
);

class ScheduleManagerProvider extends StateNotifier<ScheduleManager> {
  final Ref ref;

  ScheduleManagerProvider({required this.ref}) : super(ScheduleManager()) {
    loadSchedules();
  }

  Future<Schedule?> addSchedule(Schedule schedule) async {
    final newSchedule = await state.addSchedule(schedule);
    state = state.copyWith();
    return newSchedule;
  }

  Future<Schedule?> updateSchedule(Schedule schedule) async {
    final updatedSchedule = await state.updateSchedule(schedule);
    state = state.copyWith();
    return updatedSchedule;
  }

  Future<void> deleteSchedule(int scheduleId) async {
    await state.deleteSchedule(scheduleId);
    state = state.copyWith();
  }

  void loadSchedules() async {
    await state.loadSchedules();
    state = state.copyWith();
  }
}
