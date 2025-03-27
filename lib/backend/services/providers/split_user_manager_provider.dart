import 'package:brokeo/backend/models/split_user.dart';
import 'package:brokeo/backend/services/managers/split_user_manager.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final splitUserManagerProvider =
    StateNotifierProvider<SplitUserManagerProvider, SplitUserManager>(
  (ref) {
    final splitUserManager = SplitUserManagerProvider(ref: ref);
    return splitUserManager;
  },
);

class SplitUserManagerProvider extends StateNotifier<SplitUserManager> {
  final Ref ref;

  SplitUserManagerProvider({required this.ref}) : super(SplitUserManager()) {
    loadSplitUsers();
  }

  Future<SplitUser?> addSplitUser(SplitUser splitUser) async {
    final newSplitUser = await state.addSplitUser(splitUser);
    state = state.copyWith();
    return newSplitUser;
  }

  Future<SplitUser?> updateSplitUser(SplitUser splitUser) async {
    final updatedSplitUser = await state.updateSplitUser(splitUser);
    state = state.copyWith();
    return updatedSplitUser;
  }

  Future<void> deleteSplitUser(String phoneNumber) async {
    await state.deleteSplitUser(phoneNumber);
    state = state.copyWith();
  }

  void loadSplitUsers() async {
    await state.loadSplitUsers();
    state = state.copyWith();
  }
}
