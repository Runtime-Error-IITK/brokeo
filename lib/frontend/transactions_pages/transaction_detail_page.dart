import 'package:brokeo/backend/models/category.dart' show Category;
import 'package:brokeo/backend/models/merchant.dart' show CloudMerchant;
import 'package:brokeo/backend/models/transaction.dart'
    show CloudTransaction, Transaction;
import 'package:brokeo/backend/services/providers/read_providers/category_stream_provider.dart';
import 'package:brokeo/backend/services/providers/read_providers/merchant_stream_provider.dart'
    show MerchantFilter, merchantStreamProvider;
import 'package:brokeo/backend/services/providers/read_providers/user_id_provider.dart'
    show userIdProvider;
import 'package:brokeo/backend/services/providers/write_providers/category_service.dart';
import 'package:brokeo/backend/services/providers/write_providers/merchant_service.dart';
import 'package:brokeo/backend/services/providers/write_providers/transaction_service.dart'
    show transactionServiceProvider;
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

class TransactionDetailPage extends ConsumerStatefulWidget {
  final Transaction transaction;
  const TransactionDetailPage({Key? key, required this.transaction})
      : super(key: key);

  @override
  ConsumerState<TransactionDetailPage> createState() =>
      _TransactionDetailPageState();
}

class _TransactionDetailPageState extends ConsumerState<TransactionDetailPage> {
  // Keep the current category in state (initialized from the transaction).
  late String _currentCategoryId;

  @override
  void initState() {
    super.initState();
    // Assuming your transaction has a field `category`. You can adjust if needed.
    _currentCategoryId = widget.transaction.categoryId;
  }

  void _showEditCategoryDialog() {
    final categoryFilter = CategoryFilter();
    final asyncCategories = ref.watch(categoryStreamProvider(categoryFilter));

    asyncCategories.when(
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stackTrace) => Center(
        child: Text("Error: $error"),
      ),
      data: (categories) {
        String selectedCategory = _currentCategoryId;
        showDialog(
          context: context,
          builder: (context) {
            return StatefulBuilder(builder: (context, setStateDialog) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                title: Text('Edit Category'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Display current default category.
                    Row(
                      children: [
                        Text("Current: ",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(selectedCategory),
                      ],
                    ),
                    SizedBox(height: 20),
                    // Dropdown to select new category.
                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      items: categories
                          .map<DropdownMenuItem<String>>((Category category) {
                        final name = category.name;
                        return DropdownMenuItem<String>(
                          value: name,
                          child: Text(name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setStateDialog(() {
                            selectedCategory = value;
                          });
                        }
                      },
                      decoration: InputDecoration(
                        labelText: 'Select Category',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("Cancel"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Update the category in this page's state.
                      setState(() {
                        _currentCategoryId = selectedCategory;
                      });
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                "Category updated to $_currentCategoryId")),
                      );
                    },
                    child: Text("Save"),
                  ),
                ],
              );
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Fetch the merchant data using the merchantId from the transaction.
    final merchantAsync = ref.watch(merchantStreamProvider(
      MerchantFilter(merchantId: widget.transaction.merchantId),
    ));

    final categoryFilter = CategoryFilter();
    final asyncCategories = ref.watch(categoryStreamProvider(categoryFilter));
    return asyncCategories.when(
        loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
        error: (error, stack) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Profile page Error: $error")),
            );
          });
          return const SizedBox.shrink();
        },
        data: (categories) {
          return Scaffold(
            appBar: AppBar(
              title: Text(widget.transaction.amount < 0
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
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(
                    "₹${widget.transaction.amount.abs().toStringAsFixed(0)} ${widget.transaction.amount < 0 ? 'Debited' : 'Credited'}",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "${_convertNumberToWords(widget.transaction.amount.abs().toInt())} Rupees Only",
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  SizedBox(height: 20),
                  // Merchant section.
                  Text("To",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      merchantAsync.when(
                        loading: () => SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        error: (error, stack) => Text("Error",
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold)),
                        data: (merchants) {
                          final name = merchants.isNotEmpty
                              ? merchants.first.name
                              : "Unknown Merchant";
                          return Text(name,
                              style: TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.bold));
                        },
                      ),
                      SizedBox(width: 10),
                    ],
                  ),
                  // Transaction ID section.
                  Text(
                    "Transaction ID: #${widget.transaction.transactionId}",
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  SizedBox(height: 20),
                  // Category section.
                  Text("Category",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  DropdownButtonHideUnderline(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: DropdownButton<String>(
                        value: _currentCategoryId,
                        isExpanded: true,
                        icon: Icon(Icons.arrow_drop_down),
                        onChanged: (value) {
                          if (value != null) {
                            setState(
                              () {
                                _currentCategoryId = value;
                                final newTransaction = Transaction(
                                  transactionId:
                                      widget.transaction.transactionId,
                                  amount: widget.transaction.amount,
                                  date: widget.transaction.date,
                                  merchantId: widget.transaction.merchantId,
                                  categoryId: value,
                                  userId: widget.transaction.userId,
                                  sms: widget.transaction.sms,
                                );
                                final transactionService =
                                    ref.read(transactionServiceProvider);
                                transactionService?.updateCloudTransaction(
                                  CloudTransaction.fromTransaction(
                                      newTransaction),
                                );
                              },
                            );
                          }
                        },
                        items: categories.map((Category category) {
                          return DropdownMenuItem<String>(
                            value: category.categoryId,
                            child: Text(category.name),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  // SMS section.
                  Text("SMS",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(
                    widget.transaction.sms,
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  Spacer(),
                  // Actions: Delete Transaction button.
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          _showDeleteConfirmationDialog(
                              ref, context, widget.transaction);
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
        });
  }

void _showDeleteConfirmationDialog(
    WidgetRef ref, BuildContext context, Transaction transaction) {
  bool isProcessing = false;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text("Delete Transaction"),
            content: Text("Are you sure you want to delete this transaction?"),
            actions: [
              TextButton(
                onPressed: isProcessing
                    ? null
                    : () => Navigator.pop(context),
                child: Text("Cancel"),
              ),
              // Delete button / loader
              SizedBox(
                height: 36,
                child: isProcessing
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                        ),
                      )
                    : TextButton(
                        onPressed: () async {
                          setState(() => isProcessing = true);

                          final transactionService =
                              ref.read(transactionServiceProvider);
                          if (transactionService == null) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("User not logged in")),
                              );
                            }
                            setState(() => isProcessing = false);
                            return;
                          }

                          final success = await transactionService
                              .deleteTransaction(
                                  transactionId:
                                      transaction.transactionId);

                          if (success) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        "Transaction deleted successfully!")),
                              );
                              // Close both dialogs/pages as before
                              Navigator.pop(context); // close AlertDialog
                              Navigator.pop(context); // pop back
                            }
                          } else {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        "Failed to delete transaction.")),
                              );
                            }
                            setState(() => isProcessing = false);
                          }
                        },
                        child: Text(
                          "Delete",
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
              ),
            ],
          );
        },
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
