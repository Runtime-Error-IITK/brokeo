import 'dart:developer';

import 'package:brokeo/backend/models/schedule.dart';
import 'package:brokeo/backend/services/crud/database_service.dart';

class ScheduleService {
  Future<void> deleteSchedule({required int scheduleId}) async {
    final db = await DatabaseService.db;
    final deletedCount = await db.delete(
      scheduleTable,
      where: 'scheduleId = ?',
      whereArgs: [scheduleId],
    );

    if (deletedCount == 0) {
      log('No schedule found with id: $scheduleId');
    } else {
      log('Deleted schedule with id: $scheduleId');
    }
  }

  Future<DatabaseSchedule?> upsertSchedule(DatabaseSchedule schedule) async {
    final db = await DatabaseService.db;
    final results = await db.query(
      scheduleTable,
      where: 'scheduleId = ?',
      whereArgs: [schedule.scheduleId],
    );

    if (results.isNotEmpty) {
      await db.update(
        scheduleTable,
        {
          amountColumn: schedule.amount,
          merchantIdColumn: schedule.merchantId,
          categoryIdColumn: schedule.categoryId,
          datesColumn: schedule.dates,
          timePeriodColumn: schedule.timePeriod,
        },
        where: 'scheduleId = ?',
        whereArgs: [schedule.scheduleId],
      );
      final updatedSchedule = await db.query(
        scheduleTable,
        where: 'scheduleId = ?',
        whereArgs: [schedule.scheduleId],
      );
      if (updatedSchedule.isEmpty) {
        log('Failed to retrieve updated schedule');
        return null;
      }
      return DatabaseSchedule.fromRow(updatedSchedule.first);
    } else {
      final scheduleId = await db.insert(scheduleTable, {
        amountColumn: schedule.amount,
        merchantIdColumn: schedule.merchantId,
        categoryIdColumn: schedule.categoryId,
        datesColumn: schedule.dates,
        timePeriodColumn: schedule.timePeriod,
      });

      if (scheduleId == 0) {
        log('Failed to create schedule');
        return null;
      }

      final createdSchedule = await db.query(
        scheduleTable,
        where: 'scheduleId = ?',
        whereArgs: [scheduleId],
      );
      if (createdSchedule.isEmpty) {
        log('Failed to retrieve created schedule');
        return null;
      }
      return DatabaseSchedule.fromRow(createdSchedule.first);
    }
  }

  Future<DatabaseSchedule?> getSchedule({required int scheduleId}) async {
    final db = await DatabaseService.db;
    final results = await db.query(
      scheduleTable,
      where: 'scheduleId = ?',
      whereArgs: [scheduleId],
    );

    if (results.isEmpty) {
      log('No schedule found with id: $scheduleId');
      return null;
    }

    return DatabaseSchedule.fromRow(results.first);
  }
}
