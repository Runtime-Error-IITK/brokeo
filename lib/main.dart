import 'package:brokeo/firebase_options.dart';
import 'package:brokeo/frontend/home_pages/home_page.dart';
import 'package:brokeo/frontend/home_pages/main_page.dart';
import 'package:brokeo/frontend/login_pages/login_page1.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const AuthGate(),
    );
  }
}

/// Shows [HomePage] if the user is signed in, otherwise [LoginPage1].
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // still connecting to the stream
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        // user is signed in
        if (snapshot.hasData) {
          return const MainScreen();
        }
        // user is not signed in
        return const LoginPage1();
      },
    );
  }
}
