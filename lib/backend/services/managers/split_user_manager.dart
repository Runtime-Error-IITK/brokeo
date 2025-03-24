import 'dart:developer' show log;

import 'package:brokeo/backend/models/split_user.dart';
import 'package:brokeo/backend/services/crud/split_user_service.dart';

class SplitUserManager {
  List<SplitUser> _splitUsers = [];
  List<SplitUser> get splitUsers => _splitUsers;

  Future<SplitUser?> addSplitUser(SplitUser splitUser) async {
    final splitUserService = SplitUserService();
    final databaseSplitUser = DatabaseSplitUser.fromSplitUser(splitUser);
    final createdSplitUser =
        await splitUserService.insertSplitUser(databaseSplitUser);

    if (createdSplitUser != null) {
      final newSplitUser = SplitUser.fromDatabaseSplitUser(createdSplitUser);
      _splitUsers.add(newSplitUser);
      return newSplitUser;
    } else {
      log("Failed to add split user");
      return null;
    }
  }

  Future<SplitUser?> updateSplitUser(SplitUser splitUser) async {
    final splitUserService = SplitUserService();
    final databaseSplitUser = DatabaseSplitUser.fromSplitUser(splitUser);
    final updatedSplitUser =
        await splitUserService.updateSplitUser(databaseSplitUser);

    if (updatedSplitUser == null) {
      log("Failed to update split user");
      return null;
    }
    final newSplitUser = SplitUser.fromDatabaseSplitUser(updatedSplitUser);
    final index =
        _splitUsers.indexWhere((s) => s.phoneNumber == splitUser.phoneNumber);
    if (index != -1) {
      _splitUsers[index] = newSplitUser;
      return newSplitUser;
    } else {
      log("Failed to find split user to update");
      return null;
    }
  }

  Future<void> deleteSplitUser(String phoneNumber) async {
    final splitUserService = SplitUserService();
    await splitUserService.deleteSplitUser(phoneNumber: phoneNumber);
    _splitUsers
        .removeWhere((splitUser) => splitUser.phoneNumber == phoneNumber);
  }

  SplitUserManager copyWith() {
    final newSplitUserManager = SplitUserManager();
    for (final splitUser in _splitUsers) {
      newSplitUserManager._splitUsers.add(splitUser);
    }
    return newSplitUserManager;
  }

  Future<void> loadSplitUsers() async {
    final splitUserService = SplitUserService();
    final splitUsers = await splitUserService.getAllSplitUsers();
    _splitUsers = splitUsers
        .map((splitUser) => SplitUser.fromDatabaseSplitUser(splitUser))
        .toList();
  }
}
