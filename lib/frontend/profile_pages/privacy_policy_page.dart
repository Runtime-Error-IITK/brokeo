import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class PrivacyPolicyPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context,WidgetRef ref) {  
    return Scaffold(
      appBar: AppBar(
        title: Text("Privacy Policy"),
        backgroundColor: const Color.fromARGB(255, 206, 134, 218),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          "This is the privacy policy of the app. It explains how we handle your data.",
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}