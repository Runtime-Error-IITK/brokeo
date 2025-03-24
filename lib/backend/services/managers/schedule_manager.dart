import 'dart:developer' show log;

import 'package:brokeo/backend/models/schedule.dart';
import 'package:brokeo/backend/services/crud/schedule_service.dart';

class ScheduleManager {
  List<Schedule> _schedules = [];
  List<Schedule> get schedules => _schedules;

  Future<Schedule?> addSchedule(Schedule schedule) async {
    final scheduleService = ScheduleService();
    final databaseSchedule = DatabaseSchedule.fromSchedule(schedule);
    final createdSchedule =
        await scheduleService.insertSchedule(databaseSchedule);
    if (createdSchedule != null) {
      final newSchedule = Schedule.fromDatabaseSchedule(createdSchedule);
      _schedules.add(newSchedule);
      return newSchedule;
    } else {
      log("Failed to add schedule");
      return null;
    }
  }

  Future<Schedule?> updateSchedule(Schedule schedule) async {
    final scheduleService = ScheduleService();
    final databaseSchedule = DatabaseSchedule.fromSchedule(schedule);
    final updatedSchedule =
        await scheduleService.updateSchedule(databaseSchedule);

    if (updatedSchedule == null) {
      log("Failed to update schedule");
      return null;
    }

    final newSchedule = Schedule.fromDatabaseSchedule(updatedSchedule);
    final index =
        _schedules.indexWhere((s) => s.scheduleId == schedule.scheduleId);

    if (index != -1) {
      _schedules[index] = newSchedule;
      return newSchedule;
    } else {
      log("Failed to find schedule to update");
      return null;
    }
  }

  Future<void> deleteSchedule(int scheduleId) async {
    final scheduleService = ScheduleService();
    await scheduleService.deleteSchedule(scheduleId: scheduleId);
    _schedules.removeWhere((schedule) => schedule.scheduleId == scheduleId);
  }

  ScheduleManager copyWith() {
    final newScheduleManager = ScheduleManager();
    for (final schedule in _schedules) {
      newScheduleManager._schedules.add(schedule);
    }
    return newScheduleManager;
  }

  Future<void> loadSchedules() async {
    final scheduleService = ScheduleService();
    final schedules = await scheduleService.getAllSchedules();

    _schedules = schedules
        .map((schedule) => Schedule.fromDatabaseSchedule(schedule))
        .toList();
  }
}
