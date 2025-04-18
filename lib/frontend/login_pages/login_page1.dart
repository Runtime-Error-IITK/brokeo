import 'package:brokeo/backend/default_categories.dart'
    show ensureDefaultCategories;
import 'package:brokeo/frontend/login_pages/auth_page.dart' show AuthPage;
import 'package:brokeo/frontend/login_pages/login_page2.dart';
import 'package:brokeo/frontend/login_pages/verify.dart'
    show EmailVerificationPage;
import 'package:firebase_auth/firebase_auth.dart'
    show FirebaseAuth, FirebaseAuthException, UserCredential;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart' show GoogleFonts;
import 'package:hooks_riverpod/hooks_riverpod.dart';

class LoginPage1 extends ConsumerStatefulWidget {
  const LoginPage1({super.key});

  @override
  LoginPage1State createState() => LoginPage1State();
}

class LoginPage1State extends ConsumerState<LoginPage1> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isEmailValid = true;
  bool _isProcessing = false; // Prevent multiple taps

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _validEmailFormat(String email) {
    final RegExp emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  Future<void> _login() async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      final user = userCredential.user;
      if (user != null) {
        await ensureDefaultCategories(user.uid);

        if (!user.emailVerified) {
          await user.sendEmailVerification();
          if (mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => EmailVerificationPage()),
              (route) => false,
            );
          }
        } else {
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => AuthPage()),
            );
          }
        }
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No user found for that email.';
          break;
        case 'wrong-password':
          errorMessage = 'Wrong password provided.';
          break;
        default:
          errorMessage = 'Wrong email or password. (${e.code})';
      }
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(errorMessage)));
        setState(() => _isProcessing = false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('An error occurred: $e')));
        setState(() => _isProcessing = false);
      }
    }
  }

  void _verifyEmail() {
    final email = _emailController.text.trim();

    if (email.isEmpty || !_validEmailFormat(email)) {
      setState(() {
        _isEmailValid = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter a valid email address.")),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });
    _login();
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
                    ),
                  ],
                ),
              ),
              SizedBox(height: 40),

              // Email Field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                    hintText: 'Enter Email Address',
                    hintStyle: TextStyle(
                      color: Colors.black.withOpacity(0.6),
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: _isEmailValid ? Colors.grey : Colors.red,
                          width: 2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: _isEmailValid ? Colors.grey : Colors.red,
                          width: 2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: _isEmailValid ? Colors.blue : Colors.red,
                          width: 2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 20),

              // Password Field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                    hintText: 'Enter Password',
                    hintStyle: TextStyle(
                      color: Colors.black.withOpacity(0.6),
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: 2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: 2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue, width: 2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 20),

              // Arrow Button / Loader
              _isProcessing
                  ? SizedBox(
                      height: 50,
                      width: 50,
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                    )
                  : Container(
                      decoration: BoxDecoration(
                        color: Color(0xFF65558F),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        iconSize: 35,
                        icon: Icon(Icons.arrow_forward, color: Colors.white),
                        onPressed: _verifyEmail,
                      ),
                    ),

              SizedBox(height: 12),

              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => LoginPage2(),
                    ),
                  );
                },
                child: Text(
                  'Sign Up Instead',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black.withOpacity(0.7),
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
