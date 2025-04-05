import 'package:brokeo/backend/services/providers/read_providers/user_id_provider.dart'
    show firebaseAuthProvider;
import 'package:brokeo/frontend/login_pages/auth_page.dart' show AuthPage;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart' show GoogleFonts;
import 'package:hooks_riverpod/hooks_riverpod.dart';

class LoginPage2 extends ConsumerStatefulWidget {
  final String verificationId;
  final String email;

  const LoginPage2({
    super.key,
    required this.email,
    required this.verificationId,
  });

  @override
  LoginPage2State createState() => LoginPage2State();
}

class LoginPage2State extends ConsumerState<LoginPage2> {
  TextEditingController otpController = TextEditingController();

  void _verifyOtp() async {
    final firebaseAuthInstance = ref.read(firebaseAuthProvider);

    // Replace the following with your custom email OTP verification logic.
    // For example, if you have a custom method on your auth instance:
    // final userCredential = await firebaseAuthInstance.signInWithEmailOtp(
    //   email: widget.email,
    //   otpCode: otpController.text,
    // );
    //
    // For demonstration purposes, we'll assume the OTP verification is successful:
    await Future.delayed(Duration(seconds: 1)); // Simulate network delay

    if (context.mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => AuthPage(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [Color(0xFFB443B6), Colors.white],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // "Hello!" Text
              Text(
                'Hello!',
                style: GoogleFonts.pacifico(
                  color: Color(0xFF1C1B14),
                  fontSize: 50,
                  fontWeight: FontWeight.w400,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 4),
                      blurRadius: 4,
                      color: Colors.black.withOpacity(0.25),
                    )
                  ],
                ),
              ),
              SizedBox(height: 40),

              // Displaying Email
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey, width: 2),
                  ),
                  child: Text(
                    widget.email,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              SizedBox(height: 20),

              // OTP Input Field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  controller: otpController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'Enter OTP',
                    hintStyle: TextStyle(
                        color: Colors.black.withOpacity(0.6), fontSize: 18),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: 2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Arrow Button
              Container(
                decoration: BoxDecoration(
                  color: Color(0xFF65558F),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  iconSize: 35,
                  icon: Icon(Icons.arrow_forward, color: Colors.white),
                  onPressed: _verifyOtp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
