import 'package:brokeo/backend/models/merchant.dart';
import 'package:brokeo/backend/services/managers/merchant_manager.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final merchantManagerProvider =
    StateNotifierProvider<MerchantManagerProvider, MerchantManager>(
  (ref) {
    final merchantManager = MerchantManagerProvider(ref: ref);
    return merchantManager;
  },
);

class MerchantManagerProvider extends StateNotifier<MerchantManager> {
  final Ref ref;

  MerchantManagerProvider({required this.ref}) : super(MerchantManager()) {
    loadMerchants();
  }

  Future<Merchant?> addMerchant(Merchant merchant) async {
    final newMerchant = await state.addMerchant(merchant);
    state = state.copyWith();
    return newMerchant;
  }

  Future<Merchant?> updateMerchant(Merchant merchant) async {
    final updatedMerchant = await state.updateMerchant(merchant);
    state = state.copyWith();
    return updatedMerchant;
  }

  Future<void> deleteMerchant(int merchantId) async {
    state.deleteMerchant(merchantId);
    state = state.copyWith();
  }

  void loadMerchants() async {
    await state.loadMerchants();
    state = state.copyWith();
  }
}
