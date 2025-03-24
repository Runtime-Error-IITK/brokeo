import 'dart:developer' show log;

import 'package:brokeo/backend/models/merchant.dart';
import 'package:brokeo/backend/services/crud/merchant_service.dart';

class MerchantManager {
  List<Merchant> _merchants = [];
  List<Merchant> get merchants => _merchants;

  Future<Merchant?> addMerchant(Merchant merchant) async {
    final merchantService = MerchantService();
    final databaseMerchant = DatabaseMerchant.fromMerchant(merchant);
    final createdMerchant =
        await merchantService.insertMerchant(databaseMerchant);

    if (createdMerchant != null) {
      final newMerchant = Merchant.fromDatabaseMerchant(createdMerchant);
      _merchants.add(newMerchant);
      return newMerchant;
    } else {
      log("Failed to add merchant");
      return null;
    }
  }

  Future<Merchant?> updateMerchant(Merchant merchant) async {
    final merchantService = MerchantService();
    final databaseMerchant = DatabaseMerchant.fromMerchant(merchant);
    final updatedMerchant =
        await merchantService.updateMerchant(databaseMerchant);

    if (updatedMerchant == null) {
      log("Failed to update merchant");
      return null;
    }
    final newMerchant = Merchant.fromDatabaseMerchant(updatedMerchant);
    final index =
        _merchants.indexWhere((m) => m.merchantId == merchant.merchantId);
    if (index != -1) {
      _merchants[index] = newMerchant;
      return newMerchant;
    } else {
      log("Failed to find merchant to update");
      return null;
    }
  }

  Future<void> deleteMerchant(int merchantId) async {
    final merchantService = MerchantService();
    await merchantService.deleteMerchant(merchantId: merchantId);
    _merchants.removeWhere((merchant) => merchant.merchantId == merchantId);
  }

  MerchantManager copyWith() {
    final newMerchantManager = MerchantManager();
    for (final merchant in _merchants) {
      newMerchantManager._merchants.add(merchant);
    }
    return newMerchantManager;
  }

  Future<void> loadMerchants() async {
    final merchantService = MerchantService();
    final merchants = await merchantService.getAllMerchants();

    _merchants = merchants
        .map((merchant) => Merchant.fromDatabaseMerchant(merchant))
        .toList();
  }
}
