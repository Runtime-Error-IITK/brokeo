import 'package:flutter/material.dart';
import 'package:brokeo/models/transaction_model.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class TransactionDetailPage extends ConsumerWidget {
  final Transaction transaction;

  const TransactionDetailPage({Key? key, required this.transaction}) : super(key: key);

  @override
  Widget build(BuildContext context , WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        // Updated title based on transaction amount
        title: Text(transaction.amount < 0 ? "Debit Transaction" : "Credit Transaction"),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Amount",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            // Updated amount display without negative sign and specifying type
            Text(
              "₹${transaction.amount.abs().toStringAsFixed(0)} ${transaction.amount < 0 ? 'Debited' : 'Credited'}",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              "${_convertNumberToWords(transaction.amount.abs().toInt())} Rupees Only",
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            SizedBox(height: 20),
            Text(
              "To",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                Text(
                  transaction.name,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 10),
                Icon(Icons.restaurant, color: Colors.red),
              ],
            ),
            Text(
              "Transaction ID: #1234ABCD",
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            SizedBox(height: 20),
            Text(
              "SMS",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              "Dear UPI user A/C X1234 debited by 60.0 on date 02Feb25 trf to CC Canteen Refno 503692055033. If not u? call 1800111109. - SBI",
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _showEditTransactionDialog(context, transaction);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    foregroundColor: Colors.black,
                  ),
                  child: Text("Edit Transaction"),
                ),
                ElevatedButton(
                  onPressed: () {
                    _showDeleteConfirmationDialog(context, transaction);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: Text("Delete Transaction"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showEditTransactionDialog(BuildContext context, Transaction transaction) {
    TextEditingController amountController = TextEditingController(text: transaction.amount.toString());
    TextEditingController nameController = TextEditingController(text: transaction.name);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Edit Transaction"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: amountController,
                decoration: InputDecoration(labelText: "Amount"),
              ),
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: "Merchant"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                // Implement logic to update transaction details
                print("Updated amount: ${amountController.text}, Merchant: ${nameController.text}");
                Navigator.pop(context);
              },
              child: Text("Confirm"),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, Transaction transaction) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Delete Transaction"),
          content: Text("Are you sure you want to delete this transaction?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                // Implement the delete transaction logic
                Navigator.pop(context);
              },
              child: Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  String _convertNumberToWords(int number) {
    if (number == 0) return "Zero";
    final ones = [
      "", "One", "Two", "Three", "Four", "Five", "Six", "Seven", "Eight", "Nine",
      "Ten", "Eleven", "Twelve", "Thirteen", "Fourteen", "Fifteen", "Sixteen",
      "Seventeen", "Eighteen", "Nineteen"
    ];
    final tens = [
      "", "", "Twenty", "Thirty", "Forty", "Fifty", "Sixty", "Seventy", "Eighty",
      "Ninety"
    ];
    String words = "";
    if (number >= 1000000) {
      words += "${_convertNumberToWords(number ~/ 1000000)} Million ";
      number %= 1000000;
    }
    if (number >= 1000) {
      words += "${_convertNumberToWords(number ~/ 1000)} Thousand ";
      number %= 1000;
    }
    if (number >= 100) {
      words += "${_convertNumberToWords(number ~/ 100)} Hundred ";
      number %= 100;
    }
    if (number > 0) {
      if (number < 20) {
        words += "${ones[number]} ";
      } else {
        words += "${tens[number ~/ 10]} ";
        if ((number % 10) > 0) {
          words += "${ones[number % 10]} ";
        }
      }
    }
    return words.trim();
  }
}
