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
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter/material.dart';

class ManageSplitsPage extends ConsumerStatefulWidget {
  const ManageSplitsPage({super.key});

  @override
  _ManageSplitsPageState createState() => _ManageSplitsPageState();
}

class _ManageSplitsPageState extends ConsumerState<ManageSplitsPage> {
  int _currentIndex = 3; // Set the initial index to 3 for the Split tab
  @override
  Widget build(BuildContext context) {
    // log("hehe");
    final filter = SplitTransactionFilter();
    final asyncSplitTransactions =
        ref.watch(splitTransactionStreamProvider(filter));
    final splitUserFilter = SplitUserFilter();
    final asyncSplitUsers = ref.watch(splitUserStreamProvider(splitUserFilter));
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
                      content:
                          Text("Manage Splits: Transactions Error: $error")),
                );
              });
              return SizedBox.shrink();
            },
            data: (transactions) {
              // log("Transactions are here");
              return asyncSplitUsers.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content:
                              Text("Manage Splits: Split User Error: $error")),
                    );
                  });
                  return SizedBox.shrink();
                },
                data: (splitUserList) {
                  // log("Split Users are here");

                  double borrowed = 0, lent = 0;

                  for (var transaction in transactions) {
                    for (var entry in transaction.splitAmounts.entries) {
                      if (entry.key == userMetadata["phone"]) {
                        continue;
                      }
                      final amount = entry.value;
                      if (transaction.isPayment) {
                        if (transaction.userPhone == userMetadata["phone"]) {
                          borrowed -= amount;
                          if (borrowed < 0) {
                            lent -= borrowed;
                            borrowed = 0;
                          }
                        } else {
                          lent -= amount;
                          if (lent < 0) {
                            borrowed -= lent;
                            lent = 0;
                          }
                        }
                      } else if (transaction.userPhone ==
                          userMetadata["phone"]) {
                        lent += amount;
                      } else {
                        borrowed += amount;
                      }
                    }
                  }

                  var splitUsers = {};
                  var splitUsersNames = {};
                  for (var transaction in transactions) {
                    for (var entry in transaction.splitAmounts.entries) {
                      final user = entry.key;
                      final amount = entry.value;
                      log("User: $user, Amount: $amount");
                      if (!splitUsers.containsKey(user)) {
                        if (entry.key == userMetadata["phone"]) continue;
                        splitUsers[user] = 0.0;
                        // name from splitUsers
                        splitUsersNames[user] = splitUserList
                            .where((splitUser) => splitUser.phoneNumber == user)
                            .first
                            .name;
                      }
                      if (transaction.isPayment) {
                        if (transaction.userPhone == userMetadata["phone"]) {
                          splitUsers[user] = splitUsers[user] + amount;
                        } else {
                          splitUsers[user] = splitUsers[user] - amount;
                        }
                      } else {
                        if (transaction.userPhone == userMetadata["phone"]) {
                          splitUsers[user] = splitUsers[user] + amount;
                        } else {
                          splitUsers[user] = splitUsers[user] - amount;
                        }
                      }
                    }
                  }

                  final splitUsersList = splitUsers.entries.map(
                    (entry) {
                      return {
                        "name": splitUsersNames[entry.key],
                        "amount": entry.value
                      };
                    },
                  ).toList();

                  return Scaffold(
                    //backgroundColor: Color.fromARGB(255, 255, 247, 254),
                    body: ListView.separated(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0), // Added horizontal padding
                      itemCount: splitUsers.length +
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
                                  color:
                                      const Color.fromARGB(255, 237, 155, 219)
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
                                    builder: (context) =>
                                        ChooseTransactionPage()),
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
        });
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
          builder: (context) => HomePage(),
          // builder: (context) => SplitHistoryPage(),
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
                    "₹${split["amount"].abs()}",
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
