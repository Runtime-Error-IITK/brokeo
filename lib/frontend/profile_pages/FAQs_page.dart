import 'package:flutter/material.dart';

class FAQsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("FAQs"),
        backgroundColor: const Color.fromARGB(255, 205, 143, 216),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView(
          children: [
            ListTile(
              title: Text("What is Brokeo?"),
              subtitle: Text("Brokeo is a financial management app."),
            ),
            ListTile(
              title: Text("How do I reset my password?"),
              subtitle: Text("Go to settings and select 'Reset Password'."),
            ),
            // Add more FAQs as needed
          ],
        ),
      ),
    );
  }
}