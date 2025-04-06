import 'package:brokeo/backend/models/split_transaction.dart';
import 'package:brokeo/backend/services/providers/read_providers/split_transaction_stream_provider.dart'
    show SplitTransactionFilter, splitTransactionStreamProvider;
import 'package:brokeo/frontend/home_pages/home_page.dart' show HomePage;
import 'package:brokeo/frontend/transactions_pages/categories_page.dart';
import 'package:flutter/material.dart';
import 'package:brokeo/frontend/split_pages/choose_transactions.dart';
import 'package:brokeo/frontend/home_pages/home_page.dart' as brokeo_split;
import 'package:brokeo/frontend/split_pages/split_history.dart';
import 'package:brokeo/frontend/analytics_pages/analytics_page.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter/material.dart';

// class ManageSplitsPage extends StatelessWidget {
//   const ManageSplitsPage({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Normal Stateless Widget'),
//       ),
//       body: const Center(
//         child: Text('Hello, Flutter!'),
//       ),
//     );
//   }
// }

class ManageSplitsPage extends ConsumerStatefulWidget {
  @override
  _ManageSplitsPageState createState() => _ManageSplitsPageState();
}

class _ManageSplitsPageState extends ConsumerState<ManageSplitsPage> {
  int _currentIndex = 3; // Set the initial index to 3 for the Split tab

  // Future<void> _loadSplits() async {
  //   // Simulated data - replace with your actual data fetching logic
  //   final mockData = [
  //     {"name": "Darshan", "amount": 510.0, "isSettled": false},
  //     {"name": "Chetan Singh", "amount": 50.0, "isSettled": false},
  //     {"name": "Chinmay Jain", "amount": 75.0, "isSettled": false},
  //     {"name": "Anjali Patra", "amount": 1200.0, "isSettled": false},
  //     {"name": "Suryansh Verma", "amount": 160.0, "isSettled": false},
  //     {"name": "Aryan Kumar", "amount": 25.0, "isSettled": false},
  //     {"name": "Rudransh Verma", "amount": 0.0, "isSettled": true},
  //     {"name": "Moni Sinha", "amount": 50.0, "isSettled": false},
  //     {"name": "Sanjina S", "amount": 1.0, "isSettled": false},
  //     {"name": "Prem Bhardwaj", "amount": 3180.0, "isSettled": false},
  //     {"name": "Prem Bhardwaj", "amount": 3180.0, "isSettled": false},
  //     {"name": "Prem Bhardwaj", "amount": 3180.0, "isSettled": false},
  //     {"name": "Prem Bhardwaj", "amount": 3180.0, "isSettled": false},
  //     {"name": "Prem afeafa", "amount": 3180.0, "isSettled": false},
  //   ];

  //   // Convert raw data to Split objects

  //   setState(() {
  //     splits =
  //         mockData.map((item) => brokeo_split.Split.fromMap(item)).toList();
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    final filter = SplitTransactionFilter();
    final hehe = ref.watch(splitTransactionStreamProvider(filter));

    return hehe.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: $error")),
          );
        });
        return const SizedBox.shrink();
      },
      data: (transactions) {
        var splitUsers = {};
        for (var transaction in transactions) {
          for (var entry in transaction.splitAmounts.entries) {
            final user = entry.key;
            final amount = entry.value;
            if (!splitUsers.containsKey(user)) {
              splitUsers[user] = 0.0;
            }
            splitUsers[user] += amount;
          }
        }
        final splitUsersList = splitUsers.entries.map(
          (entry) {
            return {"name": entry.key, "amount": entry.value};
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
                    color: const Color.fromARGB(255, 245, 210, 245),
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
                        amount: 1441,
                        amountColor: Colors.green[800]!,
                      ),
                      const Divider(
                        height: 24,
                        color: Colors.black54,
                        thickness: 0.75,
                      ),
                      _buildBalanceRow(
                        label: "You Owe",
                        amount: 200,
                        amountColor: Colors.red[800]!,
                      ),
                      const SizedBox(height: 12),
                      _buildBalanceRow(
                        label: "You Are Owed",
                        amount: 1641,
                        amountColor: Colors.green[800]!,
                      ),
                    ],
                  ),
                );
              } else {
                final split = splitUsers[index - 2];
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
                      MaterialPageRoute(builder: (context) => HomePage()),
                      // builder: (context) => ChooseTransactionPage()),
                    );
                  },
                  child: const Icon(Icons.add, color: Colors.white),
                  backgroundColor: const Color.fromARGB(
                      255, 97, 53, 186), // Your exact purple color
                  shape: const CircleBorder(),
                )
              : null,
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
                    split["name"],
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
          ),
        ],
      ),
    );
  }
}
