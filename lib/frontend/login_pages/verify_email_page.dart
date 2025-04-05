import 'dart:async';
import 'package:brokeo/frontend/home_pages/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:brokeo/frontend/login_pages/auth_page.dart';
import 'package:brokeo/frontend/login_pages/login_page1.dart';

class VerifyEmailPage extends StatefulWidget {
  @override
  _VerifyEmailPageState createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  bool isEmailVerified = false;
  bool canResendEmail = false;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoginPage1()),
      );
      return;
    }
    isEmailVerified = user.emailVerified;
    if (!isEmailVerified) {
      sendEmailVerification();
    }
    timer = Timer.periodic(Duration(seconds: 3), (_) => checkEmailVerified());
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future checkEmailVerified() async {
    final user = FirebaseAuth.instance.currentUser;
    await user!.reload();
    setState(() {
      isEmailVerified = user.emailVerified;
    });
    if (isEmailVerified) {
      timer?.cancel();
      // Navigator.of(context).pushReplacement(
      //   MaterialPageRoute(
      //     builder: (context) => AuthPage(),
      //   ),
      // );
    }
  }

  Future sendEmailVerification() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      await user!.sendEmailVerification();

      setState(() => canResendEmail = false);
      await Future.delayed(Duration(seconds: 5));
      setState(() => canResendEmail = true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to send verification email: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) => isEmailVerified
      ? AuthPage()
      : Scaffold(
          appBar: AppBar(title: Text('Verify Email')),
          body: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'A verification email has been sent to your email address.',
                  style: TextStyle(fontSize: 20),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size.fromHeight(50),
                  ),
                  icon: Icon(Icons.email, size: 32),
                  label: Text('Resend Email', style: TextStyle(fontSize: 24)),
                  onPressed: canResendEmail ? sendEmailVerification : null,
                ),
                SizedBox(height: 8),
                TextButton(
                  onPressed: () => FirebaseAuth.instance.signOut(),
                  child: Text(
                    'Cancel',
                    style: TextStyle(fontSize: 24),
                  ),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size.fromHeight(50),
                  ),
                ),
              ],
            ),
          ));
}
