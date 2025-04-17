import 'dart:convert';
import 'dart:developer' show log;
import 'package:brokeo/backend/models/category.dart' show Category;
import 'package:brokeo/backend/models/merchant.dart' show Merchant;
import 'package:brokeo/backend/models/transaction.dart';
import 'package:brokeo/backend/services/providers/read_providers/category_stream_provider.dart';
import 'package:brokeo/backend/services/providers/read_providers/merchant_stream_provider.dart';
import 'package:brokeo/backend/services/providers/write_providers/transaction_service.dart';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

String toTitleCase(String input) {
  if (input.trim().isEmpty) return input;
  return input.split(' ').map((word) {
    if (word.isEmpty) return word;
    final lower = word.toLowerCase();
    return lower[0].toUpperCase() + lower.substring(1);
  }).join(' ');
}

class SmsHandler {
  static const platform = MethodChannel('sms_platform');

  // Function to call the FastAPI endpoint and pass a string (user message)
  static Future<void> fetchTransactionData(String userMessage) async {
    log("User message: $userMessage"); // Print the user message for debugging
    final url = Uri.parse(
        "http://172.27.16.252:8002/parse_transaction?user_message=$userMessage");

    try {
      // Sending a GET request with the user message as a query parameter
      final response = await http.get(
        url,
        headers: {"Content-Type": "application/json"}, // Setting headers
      );

      // Check if the request was successful (Status Code 200)
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body); // Convert response to JSON
        log("Response from API: $data"); // Print the response
        // Response from API: {IS_TRANSACTION: YES, Transaction Amount: 1.00, Transaction Type: Debit, Merchant Name: AUJASVIT DATTA, Category Name: Others}
        if (data['IS_TRANSACTION'] == "YES") {
          // If the response indicates a transaction, save it to SharedPreferences
          final container = ProviderContainer();
          final merchantFilter = MerchantFilter(
              merchantName: toTitleCase(data["Merchant Name"] as String));
          final List<Merchant> merchants = await container
              .read(merchantStreamProvider(merchantFilter).future);

          final categoryFilter = CategoryFilter(categoryName: "Others");
          final List<Category> categories = await container
              .read(categoryStreamProvider(categoryFilter).future);

          final userId = FirebaseAuth.instance.currentUser?.uid;

          final newTransaction = Transaction(
            transactionId: "",
            amount: double.parse(data["Transaction Amount"] as String),
            date: DateTime.now(),
            merchantId: merchants[0].userId,
            categoryId: categories[0].categoryId,
            userId: userId!,
          );
          final transactionService = container.read(transactionServiceProvider);
          final insertedTransaction =
              await transactionService?.insertTransaction(
                  CloudTransaction.fromTransaction(newTransaction));

          if (insertedTransaction != null) {
            log("Inserted transaction: ${insertedTransaction.toString()}");
          } else {
            log("Failed to insert transaction");
          }
        }
      } else {
        log("Error: ${response.statusCode}, ${response.body}"); // Print error if request fails
      }
    } catch (e) {
      log("Exception occurred: $e"); // Catch and print any exceptions
    }
  }

  static Future<void> saveAppCloseTime(DateTime time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('appCloseTime', time.toIso8601String());
  }

  /// (Optional) Load the last saved close time.
  static Future<DateTime?> getLastAppCloseTime() async {
    final prefs = await SharedPreferences.getInstance();
    final iso = prefs.getString('appCloseTime');
    return iso == null ? null : DateTime.tryParse(iso);
  }
}
