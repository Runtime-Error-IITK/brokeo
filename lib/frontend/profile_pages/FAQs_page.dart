import 'package:flutter/material.dart';

class FAQsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "FAQs",
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView(
          children: [
            ListTile(
              title: Text(
                "What is Brokeo?",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              subtitle: Text(
                "Brokeo is a financial management app.",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            ListTile(
              title: Text(
                "How do I reset my password?",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              subtitle: Text(
                "Go to settings and select 'Reset Password'.",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}