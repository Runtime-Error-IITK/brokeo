import 'package:brokeo/backend/models/merchant.dart' show CloudMerchant;
import 'package:brokeo/backend/models/transaction.dart' show Transaction;
import 'package:brokeo/backend/services/providers/read_providers/merchant_stream_provider.dart'
    show MerchantFilter, merchantStreamProvider;
import 'package:brokeo/backend/services/providers/read_providers/user_id_provider.dart'
    show userIdProvider;
import 'package:brokeo/backend/services/providers/write_providers/merchant_service.dart';
import 'package:brokeo/backend/services/providers/write_providers/transaction_service.dart'
    show transactionServiceProvider;
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class TransactionDetailPage extends ConsumerWidget {
  final Transaction transaction;

  const TransactionDetailPage({Key? key, required this.transaction})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Fetch the merchant data using the merchantId from the transaction.
    // We use a MerchantFilter with only merchantId since that's all we need.
    final merchantAsync = ref.watch(merchantStreamProvider(
        MerchantFilter(merchantId: transaction.merchantId)));

    return Scaffold(
      appBar: AppBar(
        title: Text(transaction.amount < 0
            ? "Debit Transaction"
            : "Credit Transaction"),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Amount section.
            Text("Amount",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(
              "₹${transaction.amount.abs().toStringAsFixed(0)} ${transaction.amount < 0 ? 'Debited' : 'Credited'}",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              "${_convertNumberToWords(transaction.amount.abs().toInt())} Rupees Only",
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            SizedBox(height: 20),
            // Merchant section.
            Text("To",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Row(
              children: [
                // Fetch the merchant name asynchronously.
                merchantAsync.when(
                  loading: () => SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  error: (error, stack) => Text("Error",
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  data: (merchants) {
                    // If a merchant is found, display its name; otherwise, display a placeholder.
                    final name = merchants.isNotEmpty
                        ? merchants.first.name
                        : "Unknown Merchant";
                    return Text(name,
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold));
                  },
                ),
                SizedBox(width: 10),
                // Icon(Icons.restaurant, color: Colors.red),
              ],
            ),
            // Transaction ID section.
            Text(
              "Transaction ID: #${transaction.transactionId}",
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            SizedBox(height: 20),
            // SMS section.
            Text("SMS",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(
              transaction.sms,
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            Spacer(),
            // Actions: Delete Transaction button.
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _showDeleteConfirmationDialog(ref, context, transaction);
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

  void _showDeleteConfirmationDialog(
      WidgetRef ref, BuildContext context, Transaction transaction) {
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
              onPressed: () async {
                // Get the TransactionService instance.
                final transactionService = ref.read(transactionServiceProvider);
                if (transactionService == null) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("User not logged in")),
                    );
                  }
                  return;
                }

                // Attempt to delete the transaction.
                final success = await transactionService.deleteTransaction(
                    transactionId: transaction.transactionId);
                if (success) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text("Transaction deleted successfully!")),
                    );
                    Navigator.pop(context); // Close the dialog.
                    Navigator.pop(
                        context); // Close the transaction detail page.
                  }
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Failed to delete transaction.")),
                    );
                  }
                }
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
      "",
      "One",
      "Two",
      "Three",
      "Four",
      "Five",
      "Six",
      "Seven",
      "Eight",
      "Nine",
      "Ten",
      "Eleven",
      "Twelve",
      "Thirteen",
      "Fourteen",
      "Fifteen",
      "Sixteen",
      "Seventeen",
      "Eighteen",
      "Nineteen"
    ];
    final tens = [
      "",
      "",
      "Twenty",
      "Thirty",
      "Forty",
      "Fifty",
      "Sixty",
      "Seventy",
      "Eighty",
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
