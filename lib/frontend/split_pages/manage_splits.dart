import 'dart:developer' show log;

import 'package:brokeo/backend/models/split_transaction.dart';
import 'package:brokeo/backend/services/providers/read_providers/merchant_stream_provider.dart';
import 'package:brokeo/backend/services/providers/read_providers/split_transaction_stream_provider.dart'
    show SplitTransactionFilter, splitTransactionStreamProvider;
import 'package:brokeo/backend/services/providers/read_providers/split_user_stream_provider'
    show SplitUserFilter, splitUserStreamProvider;
import 'package:brokeo/backend/services/providers/read_providers/user_id_provider.dart';
import 'package:brokeo/backend/services/providers/write_providers/user_metadata_service.dart';
import 'package:brokeo/frontend/home_pages/home_page.dart' show HomePage;
import 'package:brokeo/frontend/transactions_pages/categories_page.dart';
import 'package:flutter/material.dart';
import 'package:brokeo/frontend/split_pages/choose_transactions.dart';
import 'package:brokeo/frontend/home_pages/home_page.dart' as brokeo_split;
import 'package:brokeo/frontend/split_pages/split_history.dart';
import 'package:brokeo/frontend/analytics_pages/analytics_page.dart';
import 'package:flutter/services.dart' show MethodChannel, PlatformException;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart'
    show Permission, PermissionActions, PermissionStatusGetters;

class ManageSplitsPage extends ConsumerStatefulWidget {
  const ManageSplitsPage({super.key});

  @override
  _ManageSplitsPageState createState() => _ManageSplitsPageState();
}

class _ManageSplitsPageState extends ConsumerState<ManageSplitsPage> {
  int _currentIndex = 3; // Set the initial index to 3 for the Split tab
  List<dynamic> contacts = [];

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    final status = await Permission.contacts.request();
    if (status.isGranted) {
      log("Permission granted. Fetching contacts...");
      try {
        // This calls your platform method to fetch contacts.
        const platform = MethodChannel('com.example.contacts/fetch');
        final List<dynamic> contactDetails =
            await platform.invokeMethod('getContacts');
        log("Contacts fetched successfully: ${contactDetails.length} contacts found.");

        // Use a temporary map to remove duplicates (keyed by a unique field, e.g. phone number).
        final Map<String, Map<String, String>> tempMap = {};

        for (var contact in contactDetails) {
          // Extract the name and phone number from each contact.
          final String name = (contact['name'] as String?)?.trim() ?? "Unknown";
          final String phone =
              (contact['phone'] as String?)?.trim().replaceAll(' ', '') ?? "";
          if (name.isNotEmpty && phone.isNotEmpty) {
            tempMap[phone] = {"name": name, "phone": phone};
          }
        }

        // Convert the deduplicated map values to a list and sort it by name.
        List<Map<String, String>> contactList = tempMap.values.toList();
        contactList.sort((a, b) =>
            a["name"]!.toLowerCase().compareTo(b["name"]!.toLowerCase()));

        // Use setState to update contacts and ensure the UI rebuilds.
        if (mounted) {
          setState(() {
            contacts = contactList;
          });
        }
      } on PlatformException catch (e) {
        log("Failed to fetch contacts: ${e.message}");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to fetch contacts: ${e.message}")),
          );
        }
      }
    } else {
      log("Permission denied.");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Contacts permission denied")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // log("hehe");
    final filter = SplitTransactionFilter();
    final asyncSplitTransactions =
        ref.watch(splitTransactionStreamProvider(filter));
    final asyncMetaData =
        ref.watch(userMetadataStreamProvider); // Get user metadata
    return asyncMetaData.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Manage Splits: Metadata Error: $error")),
          );
        });
        return SizedBox.shrink();
      },
      data: (userMetadata) {
        return asyncSplitTransactions.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text("Manage Splits: Transactions Error: $error")),
              );
            });
            return SizedBox.shrink();
          },
          data: (transactions) {
            // log("Transactions are here");
            // log("Split Users are here");

            double borrowed = 0, lent = 0;

            // for (var transaction in transactions) {
            //   for (var entry in transaction.splitAmounts.entries) {
            //     final amount = entry.value;
            //     if (transaction.isPayment) {
            //       if (transaction.userPhone == userMetadata["phone"]) {
            //         borrowed -= amount;
            //         if (borrowed < 0) {
            //           lent -= borrowed;
            //           borrowed = 0;
            //         }
            //       } else {
            //         lent -= amount;
            //         if (lent < 0) {
            //           borrowed -= lent;
            //           lent = 0;
            //         }
            //       }
            //     } else if (transaction.userPhone == userMetadata["phone"] &&
            //         entry.key != userMetadata["phone"]) {
            //       lent += amount;
            //     } else if (transaction.userPhone != userMetadata["phone"] &&
            //         entry.key == userMetadata["phone"]) {
            //       borrowed += amount;
            //     }
            //   }
            // }

            var splitUsers = {};
            var splitUsersNames = {};
            for (var transaction in transactions) {
              log(transaction.toString());
              for (var entry in transaction.splitAmounts.entries) {
                final user = entry.key;
                final amount = entry.value;
                if (user == userMetadata["phone"]) continue;
                if (transaction.isPayment) {
                  log('sad');
                  if (!splitUsers.containsKey(user)) {
                    splitUsers[user] = 0.0;
                    splitUsersNames[user] = contacts.firstWhere(
                        (contact) => contact["phone"] == user, orElse: () {
                      return {"name": user};
                    })["name"];
                  }
                  if (transaction.userPhone == userMetadata["phone"]) {
                    log("wowpw");
                    splitUsers[user] = splitUsers[user] + amount;
                  } else {
                    splitUsers[user] = splitUsers[user] - amount;
                  }
                } else {
                  if (transaction.userPhone == userMetadata["phone"]) {
                    if (!splitUsers.containsKey(user)) {
                      if (entry.key == userMetadata["phone"]) continue;
                      splitUsers[user] = 0.0;
                      splitUsersNames[user] = contacts.firstWhere(
                          (contact) => contact["phone"] == user, orElse: () {
                        return {"name": user};
                      })["name"];
                    }
                    splitUsers[user] = splitUsers[user] + amount;
                  } else if (transaction.userPhone == user) {
                    if (!splitUsers.containsKey(user)) {
                      if (entry.key == userMetadata["phone"]) continue;
                      splitUsers[user] = 0.0;
                      splitUsersNames[user] = contacts.firstWhere(
                          (contact) => contact["phone"] == user, orElse: () {
                        return {"name": user};
                      })["name"];
                    }
                    splitUsers[user] = splitUsers[user] - amount;
                  }
                }
              }
            }

            // Calculate the total borrowed and lent amounts
            for (var entry in splitUsers.entries) {
              final amount = entry.value;
              if (amount < 0) {
                borrowed += amount.abs();
              } else {
                lent += amount;
              }
            }

            final splitUsersList = splitUsers.entries.map(
              (entry) {
                return {
                  "name": splitUsersNames[entry.key],
                  "phone": entry.key,
                  "amount": entry.value
                };
              },
            ).toList();

            return Scaffold(
              //backgroundColor: Color.fromARGB(255, 255, 247, 254),
              body: ListView.separated(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0), // Added horizontal padding
                itemCount: (splitUsers.isNotEmpty ? splitUsers.length : 1) +
                    2, // increased count: spacer + summary card + splits
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return const SizedBox(
                        height: 20); // Spacer to lower the summary card
                  } else if (index == 1) {
                    // Summary Card moved to be scrollable
                    return Container(
                      margin: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 251, 202, 251),
                        borderRadius: BorderRadius.circular(16.0),
                        boxShadow: [
                          BoxShadow(
                            color: const Color.fromARGB(255, 237, 155, 219)
                                .withOpacity(0.2),
                            blurRadius: 8,
                            spreadRadius: 1,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          _buildBalanceRow(
                            label: "Total Balance",
                            amount: (borrowed - lent) > 0
                                ? borrowed - lent
                                : lent - borrowed,
                            amountColor: borrowed < lent
                                ? Colors.green[800]!
                                : Colors.red[800]!,
                          ),
                          const Divider(
                            height: 24,
                            color: Colors.black54,
                            thickness: 0.75,
                          ),
                          _buildBalanceRow(
                            label: "You Owe",
                            amount: borrowed,
                            amountColor: Colors.red[800]!,
                          ),
                          const SizedBox(height: 12),
                          _buildBalanceRow(
                            label: "You Are Owed",
                            amount: lent,
                            amountColor: Colors.green[800]!,
                          ),
                        ],
                      ),
                    );
                  } else {
                    if (splitUsersList.isEmpty) {
                      return const Center(
                        child: Text(
                          "No split transactions.",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.black54,
                          ),
                        ),
                      );
                    }
                    final split = splitUsersList[index - 2];
                    // ...existing code for split tile...
                    return _buildSplitTile(split);
                  }
                },
                separatorBuilder: (context, index) => Divider(
                  color: Colors.grey[300],
                ),
              ),
              floatingActionButton: _currentIndex == 3
                  ? FloatingActionButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              // builder: (context) => HomePage()),
                              builder: (context) => ChooseTransactionPage()),
                        );
                      },
                      backgroundColor: const Color.fromARGB(
                          255, 97, 53, 186), // Your exact purple color
                      shape: const CircleBorder(),
                      heroTag: "manage_splits_fab",
                      child: const Icon(Icons.add, color: Colors.white),
                    )
                  : null,
            );
          },
        );
      },
    );
  }

  Widget _buildBalanceRow({
    required String label,
    required double amount,
    required Color amountColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black, // Black text for labels
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          "₹${amount.toStringAsFixed(2)}",
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: amountColor, // Green/red for amounts
          ),
        ),
      ],
    );
  }

  Widget _buildSplitTile(Map<dynamic, dynamic> split) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            // builder: (context) => HomePage(),
            builder: (context) => SplitHistoryPage(split: split),
          ),
        );
      },
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.purple[100],
                  child: Text(
                    split["name"][0].toUpperCase(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.purple,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        split["name"],
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                // Wrap the lending/borrowing information in a column.
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      split["amount"] < 0 ? "You borrowed" : "You lent",
                      style: TextStyle(
                        fontSize: 12,
                        color: split["amount"] < 0 ? Colors.red : Colors.green,
                      ),
                    ),
                    Text(
                      "₹${split["amount"].abs().toStringAsFixed(2)}",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: split["amount"] < 0 ? Colors.red : Colors.green,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
