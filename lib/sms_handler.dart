import 'dart:convert';
import 'package:http/http.dart' as http;

class SmsHandler {
  // Function to call the FastAPI endpoint and pass a string (user message)
  static Future<void> fetchTransactionData(String userMessage, DateTime date) async {
    final url = Uri.parse("http://172.27.16.252:8000//parse_transaction?user_message=$userMessage");

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
}
