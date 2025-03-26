import 'package:brokeo/backend/models/due.dart';
import 'package:brokeo/backend/services/managers/due_manager.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final dueManagerProvider =
    StateNotifierProvider<DueManagerProvider, DueManager>(
  (ref) {
    final dueManager = DueManagerProvider(ref: ref);
    return dueManager;
  },
);

class DueManagerProvider extends StateNotifier<DueManager> {
  final Ref ref;

  DueManagerProvider({required this.ref}) : super(DueManager()) {
    loadDues();
  }

  Future<Due?> addDue(Due due) async {
    final newDue = await state.addDue(due);
    state = state.copyWith();
    return newDue;
  }

  Future<Due?> updateDue(Due due) async {
    final updatedDue = await state.updateDue(due);
    state = state.copyWith();
    return updatedDue;
  }

  Future<void> deleteDue(int dueId) async {
    state.deleteDue(dueId);
    state = state.copyWith();
  }

  void loadDues() async {
    await state.loadDues();
    state = state.copyWith();
  }
}
