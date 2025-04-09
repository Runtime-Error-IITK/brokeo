import 'dart:async';

import 'package:brokeo/frontend/home_pages/home_page.dart';
import 'package:brokeo/frontend/login_pages/auth_page.dart' show AuthPage;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// Providers (provided by you)
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final firebaseUserProvider = StreamProvider<User?>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  return auth.authStateChanges();
});

// Convert your widget into a ConsumerStatefulWidget
class EmailVerificationPage extends ConsumerStatefulWidget {
  const EmailVerificationPage({Key? key}) : super(key: key);

  @override
  ConsumerState<EmailVerificationPage> createState() =>
      _EmailVerificationPageState();
}

class _EmailVerificationPageState extends ConsumerState<EmailVerificationPage> {
  bool _isResending = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Start polling every 5 seconds.
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      final firebaseAuth = ref.read(firebaseAuthProvider);
      final user = firebaseAuth.currentUser;
      if (user != null) {
        await user.reload();
        if (user.emailVerified) {
          // Cancel the timer to stop polling.
          _timer?.cancel();
          if (mounted) {
            // Navigate to HomePage once the email is verified.
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const AuthPage()),
            );
          }
        }
      }
    });
  }

  Future<void> _resendVerificationEmail() async {
    try {
      setState(() {
        _isResending = true;
      });
      // Use the firebaseAuthProvider to get the FirebaseAuth instance.
      final firebaseAuth = ref.read(firebaseAuthProvider);
      final user = firebaseAuth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Verification email sent.")),
          );
        }
      }
      setState(() {
        _isResending = false;
      });
    } catch (e) {
      setState(() {
        _isResending = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error sending verification email.")),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch the firebaseUserProvider
    final firebaseUserAsync = ref.watch(firebaseUserProvider);

    // The timer handles polling for email verification,
    // so no need to rely solely on authStateChanges() here.
    return Scaffold(
      body: Center(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [Color(0xFFB443B6), Colors.white],
            ),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 200),
                  // Display a mail icon
                  Icon(
                    Icons.mail_outline_outlined,
                    color: const Color(0xFF1C1B14),
                    size: 150,
                  ),
                  const SizedBox(height: 50),
                  const Text(
                    'A verification link has been sent to your email. Please check your inbox and verify your account.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 50),
                  ElevatedButton(
                    onPressed: _isResending ? null : _resendVerificationEmail,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 247, 195, 229),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 15),
                    ),
                    child: _isResending
                        ? const CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          )
                        : const Text(
                            'Resend Verification Email',
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
