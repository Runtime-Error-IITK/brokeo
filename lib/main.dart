import 'package:brokeo/firebase_options.dart';
import 'package:brokeo/frontend/home_pages/home_page.dart';
import 'package:brokeo/frontend/login_pages/auth_page.dart';
import 'package:brokeo/frontend/login_pages/login_page1.dart';
import 'package:brokeo/frontend/transactions_pages/categories_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await _initializeFirebase(); // Ensure Firebase is initialized before running the app.

  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}

Future<void> _initializeFirebase() async {
  try {
    if (Firebase.apps.isEmpty) {
      print('Initializing Firebase...');
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      print('Firebase initialized successfully.');
    } else {
      print('Firebase already initialized. Using existing app: ${Firebase.apps[0].name}');
    }
  } catch (e) {
    print('Error during Firebase initialization: $e');
    if (e.toString().contains('duplicate-app')) {
      print('Using the existing Firebase app instead.');
    } else {
      throw Exception('Firebase initialization failed: $e');
    }
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Remove debug banner
      home: AuthPage() // Set LoginPage1 as the home page
    );
  }
}