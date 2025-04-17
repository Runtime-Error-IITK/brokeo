import 'dart:convert';
import 'dart:developer' show log;
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SmsHandler {
  static const platform = MethodChannel('sms_platform');

  // Function to call the FastAPI endpoint and pass a string (user message)
  static Future<void> fetchTransactionData(String userMessage) async {
    print("User message: $userMessage"); // Print the user message for debugging
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
