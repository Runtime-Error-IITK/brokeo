import 'dart:developer' show log;

import 'package:brokeo/backend/models/split_transaction.dart';
import 'package:brokeo/backend/models/split_user.dart';
import 'package:brokeo/backend/services/providers/read_providers/split_user_stream_provider';
import 'package:brokeo/backend/services/providers/read_providers/user_id_provider.dart';
import 'package:brokeo/backend/services/providers/write_providers/split_transaction_service.dart';
import 'package:brokeo/backend/services/providers/write_providers/split_user_service_provider.dart';
import 'package:brokeo/frontend/split_pages/manage_splits.dart';
import 'package:flutter/material.dart';
import 'package:brokeo/frontend/home_pages/home_page.dart' as brokeo_home;
import 'package:brokeo/frontend/transactions_pages/categories_page.dart';
import 'package:brokeo/frontend/analytics_pages/analytics_page.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ChooseSplitTypePage extends ConsumerStatefulWidget {
  final double amount;
  final String description;
  final List<Map<String, String>> selectedContacts;

  const ChooseSplitTypePage({
    super.key,
    required this.amount,
    required this.description,
    required this.selectedContacts,
  });

  @override
  _ChooseSplitTypePageState createState() => _ChooseSplitTypePageState();
}

class _ChooseSplitTypePageState extends ConsumerState<ChooseSplitTypePage> {
  String _splitType = 'Equal'; // 'Equal' or 'Custom'
  final Map<String, double> _customAmounts = {};

  // Store controllers in a map so they persist across rebuilds.
  final Map<String, TextEditingController> _amountControllers = {};

  @override
  void initState() {
    super.initState();
    // Initialize controllers for each contact and for "You".
    for (var contact in widget.selectedContacts) {
      _amountControllers[contact["phone"]!] = TextEditingController();
    }
    _amountControllers['You'] = TextEditingController();

    _initializeEqualSplit();
  }

  void _initializeEqualSplit() {
    final totalAmount = widget.amount;
    final participantCount =
        widget.selectedContacts.length + 1; // +1 for yourself
    final equalAmount = totalAmount / participantCount;

    _customAmounts.clear();

    // Update amounts for each contact.
    for (var contact in widget.selectedContacts) {
      final key = contact["phone"]!;
      _customAmounts[key] = equalAmount;
      // Also update the corresponding controller.
      _amountControllers[key]?.text = equalAmount.toStringAsFixed(2);
    }
    // Update amount for "You".
    _customAmounts['You'] = equalAmount;
    _amountControllers['You']?.text = equalAmount.toStringAsFixed(2);
  }

  @override
  void dispose() {
    // Dispose all controllers.
    for (final controller in _amountControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  double get _remainingAmount {
    final total = widget.amount;
    final allocated =
        _customAmounts.values.fold(0.0, (sum, amount) => sum + amount);
    return total - allocated;
  }

  @override
  Widget build(BuildContext context) {
    // log(widget.selectedContacts.toString());
    final totalAmount = widget.amount;
    final remainingAmount = _remainingAmount;

    return Scaffold(
      appBar: AppBar(
        title: Text('Choose Split Type'),
      ),
      body: Column(
        children: [
          // Transaction Info
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.description,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                LinearProgressIndicator(
                  value: remainingAmount / totalAmount,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
                ),
                SizedBox(height: 8),
                Text(
                  'Left ${remainingAmount.toStringAsFixed(2)}/${totalAmount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          // Split Type Selection
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Split Type',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: Text('Equal'),
                        selected: _splitType == 'Equal',
                        onSelected: (selected) {
                          setState(() {
                            _splitType = 'Equal';
                            _initializeEqualSplit();
                          });
                        },
                        selectedColor: Colors.purple,
                        labelStyle: TextStyle(
                          color: _splitType == 'Equal'
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: ChoiceChip(
                        label: Text('Custom'),
                        selected: _splitType == 'Custom',
                        onSelected: (selected) {
                          setState(() {
                            _splitType = 'Custom';
                          });
                        },
                        selectedColor: Colors.purple,
                        labelStyle: TextStyle(
                          color: _splitType == 'Custom'
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Amount Allocation List
          Expanded(
            child: ListView(
              children: [
                // Your allocation
                _buildAmountTile(
                  keyId: 'You',
                  name: 'You',
                ),
                // Contacts allocation
                ...widget.selectedContacts.map((contact) {
                  return _buildAmountTile(
                    keyId: contact["phone"]!,
                    name: contact["name"]!,
                  );
                }).toList(),
              ],
            ),
          ),

          // Action Buttons
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: remainingAmount == 0
                        ? () {
                            // TODO: Save the split transaction
                            // log(_customAmounts.toString());

                            final asyncMetadata =
                                ref.read(userMetadataStreamProvider);
                            final splitUserFilter = SplitUserFilter();

                            asyncMetadata.whenData(
                              (metadata) async {
                                final myNumber = metadata["phone"];

                                if (_customAmounts.containsKey("You")) {
                                  final value = _customAmounts["You"];
                                  _customAmounts.remove("You");
                                  _customAmounts[myNumber] = value!;
                                }
                                final currentDate = DateTime.now();
                                final splitTransaction = SplitTransaction(
                                  splitTransactionId: "",
                                  date: currentDate,
                                  description: widget.description,
                                  isPayment: false,
                                  userPhone: myNumber,
                                  splitAmounts: _customAmounts,
                                );

                                ref
                                    .read(splitTransactionServiceProvider)!
                                    .insertSplitTransaction(
                                        CloudSplitTransaction
                                            .fromSplitTransaction(
                                                splitTransaction));

                                // for (var currNumber
                                //     in _customAmounts.keys) {
                                //   if (splitUsers.any((user) =>
                                //       user.phoneNumber == currNumber)) {
                                //     continue;
                                //   }
                                //   final newSplituser = SplitUser(
                                //     userId: "",
                                //     name: widget.selectedContacts
                                //         .firstWhere((contact) =>
                                //             contact["phone"] ==
                                //             currNumber)["name"]!,
                                //     phoneNumber: currNumber,
                                //   );
                                //   ref
                                //       .read(splitUserServiceProvider)!
                                //       .insertSplitUser(
                                //           CloudSplitUser.fromSplitUser(
                                //               newSplituser));
                                // }

                                //navigator to ManageSplitsPage
                                int count = 0;
                                if (context.mounted) {
                                  Navigator.popUntil(
                                      context, (_) => count++ == 3);

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Transaction split successfully!'),
                                    ),
                                  );
                                }
                              },
                            );
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      padding:
                          EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                    ),
                    child: Text(
                      'Confirm',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountTile({
    required String keyId, // Unique identifier (e.g., 'You' or contact phone)
    required String name,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.purple[100],
        child: Text(
          name[0],
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.purple,
          ),
        ),
      ),
      title: Text(name),
      trailing: SizedBox(
        width: 100,
        child: TextField(
          // Use the stored controller.
          controller: _amountControllers[keyId],
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            prefixText: '₹',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          ),
          onChanged: (value) {
            final newAmount = double.tryParse(value) ?? 0.0;
            setState(() {
              _customAmounts[keyId] = newAmount;
              // If you're in Equal mode and a user edits a field, switch to Custom.
              if (_splitType == 'Equal') {
                _splitType = 'Custom';
              }
            });
          },
        ),
      ),
    );
  }
}
