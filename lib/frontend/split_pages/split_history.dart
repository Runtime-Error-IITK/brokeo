import 'package:brokeo/backend/models/split_transaction.dart';
import 'package:brokeo/backend/services/providers/read_providers/split_transaction_stream_provider.dart'
    show SplitTransactionFilter, splitTransactionStreamProvider;
import 'package:brokeo/backend/services/providers/read_providers/user_id_provider.dart';
import 'package:brokeo/backend/services/providers/write_providers/split_transaction_service.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

class SplitHistoryPage extends ConsumerStatefulWidget {
  final Map<dynamic, dynamic> split;
  const SplitHistoryPage({super.key, required this.split});

  @override
  _SplitHistoryPageState createState() => _SplitHistoryPageState();
}

class _SplitHistoryPageState extends ConsumerState<SplitHistoryPage> {
  final int _currentIndex = 3;
  final bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final userMetadata = ref.watch(userMetadataStreamProvider);

    return userMetadata.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: $error")),
          );
        });
        return SizedBox.shrink();
      },
      data: (user) {
        // log('woah');
        final splitFilter1 = SplitTransactionFilter(
          first: widget.split['phone'],
          second: user['phone'],
        );

        final splitFilter2 = SplitTransactionFilter(
          second: widget.split['phone'],
          first: user['phone'],
        );
        final asyncSplitTransactions1 =
            ref.watch(splitTransactionStreamProvider(splitFilter1));

        final asyncSplitTransactions2 =
            ref.watch(splitTransactionStreamProvider(splitFilter2));

        return asyncSplitTransactions1.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Error: $error")),
                );
              });
              return SizedBox.shrink();
            },
            data: (transactions1) {
              // log("woah2");

              transactions1.removeWhere((transaction) =>
                  transaction.splitAmounts[splitFilter1.second] == null);

              return asyncSplitTransactions2.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error: $error")),
                    );
                  });
                  return SizedBox.shrink();
                },
                data: (transactions2) {
                  transactions2.removeWhere((transaction) =>
                      transaction.splitAmounts[splitFilter2.second] == null);
                  double totalOwed = 0;
                  final transactions = [...transactions1, ...transactions2];
                  transactions.sort((a, b) => a.date.compareTo(b.date));
                  for (final transaction in transactions) {
                    if (transaction.userPhone == widget.split['phone']) {
                      totalOwed += transaction.splitAmounts[user['phone']]!;
                    } else {
                      totalOwed -=
                          transaction.splitAmounts[splitFilter2.second]!;
                    }
                  }
                  return Scaffold(
                    appBar: AppBar(
                      leading: IconButton(
                        icon: Icon(Icons.arrow_back),
                        onPressed: () => Navigator.pop(context),
                      ),
                      title: Text(widget.split['name'],
                          style: TextStyle(fontSize: 24)),
                      centerTitle: true,
                    ),
                    body: _isLoading
                        ? Scaffold(
                            backgroundColor: Colors.white,
                            body: Center(
                              child: CircularProgressIndicator(),
                            ),
                          )
                        : Column(
                            children: [
                              // "You owe", "owes you", or "Settled" message below app bar
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10, // More horizontal padding
                                  vertical: 4, // Less vertical padding
                                ),
                                child: Center(
                                  child: Text(
                                    totalOwed > 0
                                        ? 'You owe ${widget.split['name']} ₹${totalOwed.abs().toStringAsFixed(2)}'
                                        : totalOwed < 0
                                            ? '${widget.split['name']} owes you ₹${totalOwed.abs().toStringAsFixed(2)}'
                                            : 'Settled',
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      color: totalOwed > 0
                                          ? Colors.red
                                          : totalOwed < 0
                                              ? Colors.green
                                              : Colors
                                                  .black, // Neutral color for "Settled"
                                    ),
                                  ),
                                ),
                              ),
                              // Action buttons
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16, // More horizontal padding
                                  vertical: 4, // Less vertical padding
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () =>
                                          _showSettleUpConfirmation(
                                              context, totalOwed, user),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.purple,
                                        foregroundColor: Colors.white,
                                      ),
                                      child: Text('Record Payment'),
                                    ),
                                  ],
                                ),
                              ),

                              // Transaction list
                              Expanded(
                                child: ListView.separated(
                                  padding: EdgeInsets.zero,
                                  itemCount: transactions.length,
                                  itemBuilder: (context, index) {
                                    final reversedIndex =
                                        transactions.length - 1 - index;
                                    final transaction =
                                        transactions[reversedIndex];

                                    String message = "";
                                    if (transaction.isPayment) {
                                      if (transaction.userPhone ==
                                          widget.split['phone']) {
                                        message =
                                            "${widget.split['name']} paid";
                                      } else {
                                        message = "You paid";
                                      }
                                    } else {
                                      if (transaction.userPhone ==
                                          widget.split['phone']) {
                                        message = "You borrowed";
                                      } else {
                                        message = "You lent";
                                      }
                                    }
                                    return InkWell(
                                        onTap: () {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title:
                                                    const Text('Description'),
                                                content: Text(
                                                    transaction.description),
                                                actions: <Widget>[
                                                  TextButton(
                                                    child: const Text('Close'),
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 5, horizontal: 12),
                                          child: Row(
                                            children: [
                                              CircleAvatar(
                                                radius: 20,
                                                backgroundColor:
                                                    Colors.purple[100],
                                                child: Text(
                                                  widget.split['name'][0],
                                                  style: TextStyle(
                                                    color: Colors.purple,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 16),
                                              Expanded(
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    // First row: name and message on the same level.
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                          widget.split['name'],
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 16,
                                                            color: Colors.black,
                                                          ),
                                                        ),
                                                        Text(
                                                          message,
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            color: (transaction
                                                                        .userPhone ==
                                                                    widget.split[
                                                                        'phone'])
                                                                ? Colors.red
                                                                : Colors.green,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(
                                                        height:
                                                            4), // Adjust spacing as needed
                                                    // Second row: date and amount on the same level.
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                          DateFormat(
                                                                  "MMM dd, yyyy, hh:mm")
                                                              .format(
                                                                  transaction
                                                                      .date),
                                                          style: TextStyle(
                                                            color: Colors
                                                                .grey.shade600,
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                        Text(
                                                          (transaction.userPhone ==
                                                                  user['phone'])
                                                              ? '₹${transaction.splitAmounts[widget.split['phone']]!.abs().toStringAsFixed(2)}'
                                                              : '₹${transaction.splitAmounts[user['phone']]!.abs().toStringAsFixed(2)}',
                                                          style: TextStyle(
                                                            color: (transaction
                                                                        .userPhone ==
                                                                    widget.split[
                                                                        'phone'])
                                                                ? Colors.red
                                                                : Colors.green,
                                                            fontSize: 15,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ));
                                  },
                                  separatorBuilder: (context, index) => Divider(
                                    height: 1,
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                              ),
                            ],
                          ),
                  );
                },
              );
            });
      },
    );
  }

  // Shows a dialog/popup to add a new transaction
  void _showAddTransactionDialog(BuildContext context) {
    // Create variables to store the form data:
    final formKey = GlobalKey<FormState>(); // Key to identify and validate form
    String amount = ''; // Will store the transaction amount
    DateTime? selectedDate; // Will store selected date
    TimeOfDay? selectedTime; // Will store selected time
    String type = 'You Owe'; // Default transaction type

    // Helper function to show date picker dialog
    Future<void> selectDate(BuildContext context) async {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(), // Default to current date
        firstDate: DateTime(2000), // Earliest allowed date
        lastDate: DateTime(2100), // Latest allowed date
      );
      if (picked != null) {
        selectedDate = picked; // Save selected date
      }
    }

    // Helper function to show time picker dialog
    Future<void> selectTime(BuildContext context) async {
      final TimeOfDay? picked = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(), // Default to current time
      );
      if (picked != null) {
        selectedTime = picked; // Save selected time
      }
    }

    // Actually show the dialog using showDialog()
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                'Add Transaction',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min, // Keep dialog compact
                  children: [
                    // Amount input field
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: "Amount",
                        prefixText: "₹", // Indian Rupee symbol
                        border: OutlineInputBorder(), // Styled border
                      ),
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        // Only allow numbers with optional decimal point
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d+\.?\d{0,2}')),
                      ],
                      validator: (value) {
                        // Validation rules:
                        if (value == null || value.isEmpty) {
                          return 'Please enter amount';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Enter valid amount';
                        }
                        if (double.parse(value) <= 0) {
                          return 'Amount must be positive';
                        }
                        return null; // No error
                      },
                      onChanged: (value) => amount = value,
                    ),
                    SizedBox(height: 16), // Add spacing between fields

                    // Date and Time row
                    Row(
                      children: [
                        // Date picker field
                        Expanded(
                          child: InkWell(
                            onTap: () => selectDate(context)
                                .then((_) => setState(() {})),
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: "Date",
                                border: OutlineInputBorder(),
                              ),
                              child: Text(
                                selectedDate != null
                                    ? DateFormat('dd/MM/yyyy')
                                        .format(selectedDate!)
                                    : 'Select date',
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 16), // Spacing between date and time
                        // Time picker field
                        Expanded(
                          child: InkWell(
                            onTap: () => selectTime(context)
                                .then((_) => setState(() {})),
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: "Time",
                                border: OutlineInputBorder(),
                              ),
                              child: Text(
                                selectedTime != null
                                    ? selectedTime!.format(context)
                                    : 'Select time',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),

                    // Transaction type dropdown
                    DropdownButtonFormField<String>(
                      value: type,
                      decoration: InputDecoration(
                        labelText: "Type",
                        border: OutlineInputBorder(),
                      ),
                      items: ['You Owe', 'You Are Owed'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select type';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        setState(() {
                          type = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),
              // Dialog action buttons
              actions: [
                // Cancel button
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                // Confirm button
                ElevatedButton(
                  onPressed: () {
                    // Validate all form fields
                    if (formKey.currentState!.validate()) {
                      // Check date/time were selected
                      if (selectedDate == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Please select date')));
                        return;
                      }
                      if (selectedTime == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Please select time')));
                        return;
                      }

                      // In a real app, this would save to database
                      print('''
                      New Transaction:
                      Amount: ₹${double.parse(amount).toStringAsFixed(2)}
                      Type: $type
                      Date: ${DateFormat('dd/MM/yyyy').format(selectedDate!)}
                      Time: ${selectedTime!.format(context)}
                      ''');

                      Navigator.pop(context); // Close dialog
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 97, 53, 186),
                  ),
                  child: Text(
                    'Confirm',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Shows confirmation dialog when settling up
  void _showSettleUpConfirmation(
      BuildContext context, double totalOwed, Map userMetadata) {
    final formKey = GlobalKey<FormState>();
    String settleAmount = totalOwed.abs().toStringAsFixed(2);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Record Payment',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  // initialValue: settleAmount,
                  decoration: InputDecoration(
                    labelText: "Amount",
                    prefixText: "₹",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^-?\d+\.?\d{0,2}')),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an amount';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Enter a valid amount';
                    }
                    return null;
                  },
                  onChanged: (value) => settleAmount = value,
                ),
                SizedBox(height: 16),
                // Text(
                //   'Current balance: ₹${totalOwed.toStringAsFixed(2)}',
                //   style: TextStyle(color: Colors.grey),
                // ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final enteredAmount = double.parse(settleAmount);

                  final newTransaction = SplitTransaction(
                    splitTransactionId: "",
                    date: DateTime.now(),
                    description: "Paid ${widget.split['name']} ₹$settleAmount",
                    isPayment: true,
                    userPhone: userMetadata['phone'],
                    splitAmounts: {
                      widget.split['phone']: enteredAmount,
                      userMetadata['phone']: 0,
                    },
                  );

                  ref
                      .read(splitTransactionServiceProvider)!
                      .insertSplitTransaction(
                        CloudSplitTransaction.fromSplitTransaction(
                            newTransaction),
                      );

                  // ScaffoldMessenger.of(context).showSnackBar(
                  //   SnackBar(
                  //     content: Text(
                  //       newBalance > 0
                  //           ? 'You owe ₹${newBalance.toStringAsFixed(2)}'
                  //           : newBalance < 0
                  //               ? '${widget.split['name']} owes you ₹${newBalance.abs().toStringAsFixed(2)}'
                  //               : 'You are settled up with ${widget.split['name']}',
                  //     ),
                  //   ),
                  // );

                  setState(() {
                    // transactions.add({
                    //   'name': widget.split['name'],
                    //   'amount': -enteredAmount,
                    //   'date': DateFormat('dd MMM\'yy, HH:mm')
                    //       .format(DateTime.now()),
                    //   'avatarText': widget.split['name'][0],
                    // });
                  });

                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 97, 53, 186),
              ),
              child: Text(
                'Confirm',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}
