import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SmsHandler {
  static const platform = MethodChannel('sms_platform');

  // Function to call the FastAPI endpoint and pass a string (user message)
  static Future<void> fetchTransactionData(String userMessage) async {
    print("User message: $userMessage"); // Print the user message for debugging
    final url = Uri.parse("http://172.27.16.252:8000/parse_transaction?user_message=$userMessage");

    try {
      // Sending a GET request with the user message as a query parameter
      final response = await http.get(
        url,
        headers: {"Content-Type": "application/json"}, // Setting headers
      );

      // Check if the request was successful (Status Code 200)
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body); // Convert response to JSON
        print("Response from API: $data"); // Print the response
      } else {
        print("Error: ${response.statusCode}, ${response.body}"); // Print error if request fails
      }
    } catch (e) {
      print("Exception occurred: $e"); // Catch and print any exceptions
    }
  }

  static Future<void> saveAppCloseTime() async {
    final prefs = await SharedPreferences.getInstance();
    final int currentTime = DateTime.now().millisecondsSinceEpoch;
    await prefs.setInt('lastAppCloseTime', currentTime);
  }

  // Function to process new SMS messages when the app is opened
  static Future<void> processNewSmsOnAppOpen() async {
    print("Processing new SMS on app open..."); // Debugging message
    final prefs = await SharedPreferences.getInstance();
    int? lastAppCloseTime = prefs.getInt('lastAppCloseTime');

    try {
      final List<dynamic> smsList = await platform.invokeMethod('readAllSms');

      for (var sms in smsList) {
        if (sms is String) {
          final lines = sms.split('\n');
          if (lines.length >= 2) {
            final String body = lines[1].replaceFirst('Message: ', '').trim();
            final String timestampLine = lines[0].replaceFirst('From: ', '').trim();
            final int timestamp = int.tryParse(timestampLine) ?? 0; // Parse actual timestamp

            if (lastAppCloseTime == null || timestamp > lastAppCloseTime) {
              await fetchTransactionData(body);
            }
          } else {
            print("Unexpected SMS format: $sms");
          }
        } else {
          print("Unexpected SMS format: $sms");
        }
      }

      if (smsList.isNotEmpty) {
        final int latestTimestamp = smsList.map((sms) {
          if (sms is String) {
            final lines = sms.split('\n');
            if (lines.isNotEmpty) {
              final String timestampLine = lines[0].replaceFirst('From: ', '').trim();
              return int.tryParse(timestampLine) ?? 0;
            }
          }
          return 0;
        }).reduce((a, b) => a > b ? a : b);

        await prefs.setInt('lastAppCloseTime', latestTimestamp);
      }
    } catch (e) {
      print("Error fetching SMS: $e");
    }
  }
}