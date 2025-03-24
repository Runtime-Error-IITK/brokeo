import 'dart:developer' show log;

import 'package:brokeo/backend/models/due.dart';
import 'package:brokeo/backend/services/crud/due_service.dart';

class DueManager {
  List<Due> _dues = [];
  List<Due> get dues => _dues;

  Future<Due?> addDue(Due due) async {
    final dueService = DueService();
    final databaseDue = DatabaseDue.fromDue(due);
    final createdDue = await dueService.insertDue(databaseDue);
    if (createdDue != null) {
      final newDue = Due.fromDatabaseDue(createdDue);
      _dues.add(newDue);
      return newDue;
    } else {
      log("Failed to add due");
      return null;
    }
  }

  Future<Due?> updateDue(Due due) async {
    final dueService = DueService();
    final databaseDue = DatabaseDue.fromDue(due);
    final updatedDue = await dueService.updateDue(databaseDue);
    if (updatedDue == null) {
      log("Failed to update due");
      return null;
    }
    final newDue = Due.fromDatabaseDue(updatedDue);
    final index = _dues.indexWhere((d) => d.dueId == due.dueId);
    if (index != -1) {
      _dues[index] = newDue;
      return newDue;
    } else {
      log("Failed to find due to update");
      return null;
    }
  }

  Future<void> deleteDue(int dueId) async {
    final dueService = DueService();
    await dueService.deleteDue(dueId: dueId);
    _dues.removeWhere((due) => due.dueId == dueId);
  }

  DueManager copyWith() {
    final newDueManager = DueManager();
    for (final due in _dues) {
      newDueManager._dues.add(due);
    }
    return newDueManager;
  }

  Future<void> loadDues() async {
    final dueService = DueService();
    final dues = await dueService.getAllDues();

    _dues = dues.map((due) => Due.fromDatabaseDue(due)).toList();
  }
}
