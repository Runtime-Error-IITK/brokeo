import 'dart:convert';
import 'package:flutter/services.dart';

// Helper function to load colors from assets/colors.json
Future<Map<String, Color>> loadCategoryColors() async {
  final jsonString = await rootBundle.loadString('assets/colors.json');
  final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
  // Convert hex string to Color
  return jsonMap.map((key, value) =>
      MapEntry(key, Color(int.parse(value.replaceFirst('#', '0xff')))));
}
