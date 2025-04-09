import 'package:brokeo/firebase_options.dart';
import 'package:brokeo/frontend/home_pages/home_page.dart';
import 'package:brokeo/frontend/login_pages/auth_page.dart';
import 'package:brokeo/frontend/login_pages/login_page1.dart';
import 'package:brokeo/frontend/login_pages/login_page3.dart';
import 'package:brokeo/frontend/login_pages/verify.dart';
import 'package:brokeo/frontend/transactions_pages/categories_page.dart';
import 'package:firebase_core/firebase_core.dart';
// import 'package:brokeo/frontend/login_pages/login_page1.dart';
// import 'package:brokeo/frontend/home_pages/home_page.dart';
// import 'package:brokeo/frontend/transactions_pages/categories_page.dart';
// import 'package:brokeo/frontend/login_pages/login_page1.dart';
// import 'package:brokeo/frontend/login_pages/login_page3.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Remove debug banner
      home: EmailVerificationPage(), // Set LoginPage1 as the home page
    );
  }
}
