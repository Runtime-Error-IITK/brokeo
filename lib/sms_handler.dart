import 'dart:async';
import 'dart:convert';
import 'dart:developer' show log;

import 'package:brokeo/backend/models/category.dart' show Category;
import 'package:brokeo/backend/models/merchant.dart'
    show CloudMerchant, Merchant;
import 'package:brokeo/backend/models/transaction.dart';
import 'package:brokeo/backend/services/providers/read_providers/category_stream_provider.dart';
import 'package:brokeo/backend/services/providers/read_providers/merchant_stream_provider.dart';
import 'package:brokeo/backend/services/providers/write_providers/merchant_service.dart'
    show merchantServiceProvider;
import 'package:brokeo/backend/services/providers/write_providers/transaction_service.dart';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SmsHandler {
  static const platform = MethodChannel('sms_platform');

  static Future<void> fetchTransactionData(String userMessage) async {
    log("User message: $userMessage");

    final url = Uri.parse(
      "http://172.27.16.252:8002/parse_transaction?user_message=$userMessage",
    );

    try {
      final response = await http.get(url, headers: {
        "Content-Type": "application/json",
      });

      if (response.statusCode != 200) {
        log("Error: ${response.statusCode}, ${response.body}");
        return;
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      log("Response from API: $data");

      if (data['IS_TRANSACTION'] != "YES") return;

      double amount = 0;
      if (data["Transaction Type"] as String == "Debit") {
        amount = double.parse(data["Transaction Amount"] as String) * -1;
      } else {
        amount = double.parse(data["Transaction Amount"] as String);
      }

      final container = ProviderContainer();

      // ── MERCHANTS ────────────────────────────────────────────────
      final merchantFilter = MerchantFilter(
        merchantName: toTitleCase(data["Merchant Name"] as String),
      );
      final merchantCompleter = Completer<List<Merchant>>();
      ProviderSubscription<AsyncValue<List<Merchant>>>? merchantSub;

      merchantSub = container.listen<AsyncValue<List<Merchant>>>(
        merchantStreamProvider(merchantFilter),
        (prev, next) => next.when(
          data: (merchants) {
            merchantCompleter.complete(merchants);
            merchantSub?.close(); // stop listening
          },
          loading: () {/* still waiting */},
          error: (err, stack) {
            merchantCompleter.completeError(err, stack);
            merchantSub?.close();
          },
        ),
        fireImmediately: true,
      );

      final merchants = await merchantCompleter.future;

      // ── CATEGORIES ───────────────────────────────────────────────
      final categoryFilter = CategoryFilter(categoryName: "Others");
      final categoryCompleter = Completer<List<Category>>();
      ProviderSubscription<AsyncValue<List<Category>>>? categorySub;

      categorySub = container.listen<AsyncValue<List<Category>>>(
        categoryStreamProvider(categoryFilter),
        (prev, next) => next.when(
          data: (categories) {
            categoryCompleter.complete(categories);
            categorySub?.close();
          },
          loading: () {},
          error: (err, stack) {
            categoryCompleter.completeError(err, stack);
            categorySub?.close();
          },
        ),
        fireImmediately: true,
      );

      final categories = await categoryCompleter.future;
      final userId = FirebaseAuth.instance.currentUser?.uid;

      //  ── INSERT TRANSACTION ───────────────────────────────────────
      if (userId == null) {
        log("No signed‑in user");
        container.dispose();
        return;
      }

      if (merchants.isEmpty) {
        final newMerchant = Merchant(
          merchantId: "",
          name: toTitleCase(data["Merchant Name"] as String),
          categoryId: categories[0].categoryId,
          userId: userId,
        );
        final merchantService = container.read(merchantServiceProvider);
        final insertedMerchant = await merchantService
            ?.insertMerchant(CloudMerchant.fromMerchant(newMerchant));
        if (insertedMerchant != null) {
          merchants.add(Merchant.fromCloudMerchant(insertedMerchant));
        }
      }

      final newTx = Transaction(
        transactionId: "",
        amount: amount,
        date: DateTime.now(),
        merchantId: merchants.first.userId,
        categoryId: categories.first.categoryId,
        userId: userId,
      );

      final txService = container.read(transactionServiceProvider);
      final inserted = await txService
          ?.insertTransaction(CloudTransaction.fromTransaction(newTx));

      if (inserted != null) {
        log("Inserted transaction: $inserted");
      } else {
        log("Failed to insert transaction");
      }

      container.dispose();
    } catch (e, stack) {
      log("Exception occurred: $e\n$stack");
    }
  }

  static Future<void> saveAppCloseTime(DateTime time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('appCloseTime', time.toIso8601String());
  }

  static Future<DateTime?> getLastAppCloseTime() async {
    final prefs = await SharedPreferences.getInstance();
    final iso = prefs.getString('appCloseTime');
    return iso == null ? null : DateTime.tryParse(iso);
  }

  static String toTitleCase(String input) {
    if (input.trim().isEmpty) return input;
    return input.split(' ').map((word) {
      if (word.isEmpty) return word;
      final lower = word.toLowerCase();
      return lower[0].toUpperCase() + lower.substring(1);
    }).join(' ');
  }
}
