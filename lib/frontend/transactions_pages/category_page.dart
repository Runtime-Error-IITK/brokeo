import 'package:brokeo/backend/models/category.dart';
import 'package:brokeo/backend/models/transaction.dart' show Transaction;
import 'package:brokeo/backend/services/providers/read_providers/merchant_stream_provider.dart';
import 'package:brokeo/backend/services/providers/read_providers/transaction_stream_provider.dart'
    show TransactionFilter, transactionStreamProvider;
import 'package:brokeo/frontend/transactions_pages/transaction_detail_page.dart'
    show TransactionDetailPage;
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class CategoryPage extends ConsumerStatefulWidget {
  final Category category;
  const CategoryPage({super.key, required this.category});

  @override
  CategoryPageState createState() => CategoryPageState();
}

class CategoryPageState extends ConsumerState<CategoryPage> {
  @override
  Widget build(BuildContext context) {
    final category = widget.category;
    final transactionFilter =
        TransactionFilter(categoryId: category.categoryId);
    final asyncTransactions =
        ref.watch(transactionStreamProvider(transactionFilter));

    return asyncTransactions.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("User error: $error")),
            );
          });
          return SizedBox.shrink();
        },
        data: (transactions) {
          final now = DateTime.now();

          final List<List<Transaction>> filteredTransactions = [];

          for (int i = 5; i >= 0; i--) {
            final month = DateTime(now.year, now.month - i);
            final monthTransactions = transactions.where((transaction) {
              return transaction.date.year == month.year &&
                  transaction.date.month == month.month;
            }).toList();
            filteredTransactions.add(monthTransactions);
          }
          double totalSpends = 0;
          for (var t in filteredTransactions[-1]) {
            totalSpends -= t.amount > 0 ? t.amount : 0;
          }
          return Scaffold(
            appBar: buildCustomAppBar(context, totalSpends),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 20),
                  buildBarChart(),
                  // Add some spacing before the transaction list
                  SizedBox(height: 10),
                  // Include the transaction list widget here
                  TransactionListWidget(
                    transactions: transactions,
                  ),
                ],
              ),
            ),
            // bottomNavigationBar: buildBottomNavigationBar(),
          );
        });
  }
}

class TransactionListWidget extends ConsumerWidget {
  final List<Transaction> transactions;

  const TransactionListWidget({super.key, required this.transactions});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 20),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: Color(0xFFEDE7F6),
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: transactions.isEmpty
              ? Center(
                  child: Text(
                    "No Transactions Yet",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                )
              : Column(
                  children: transactions.asMap().entries.map((entry) {
                    final index = entry.key;
                    final transaction = entry.value;
                    return Column(
                      children: [
                        _transactionTile(context, ref, transaction),
                        if (index < transactions.length - 1)
                          Divider(color: Colors.grey[300]),
                      ],
                    );
                  }).toList(),
                ),
        ),
      ),
    );
  }

  /// Single Transaction Row (clickable, but onTap is commented out).
  Widget _transactionTile(
      BuildContext context, WidgetRef ref, Transaction transaction) {
    final merchantFilter = MerchantFilter(
      merchantId: transaction.merchantId,
    );

    final asyncMerchant = ref.watch(merchantStreamProvider(merchantFilter));

    return asyncMerchant.when(
        loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
        error: (error, stack) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("User error: $error")),
            );
          });
          return SizedBox.shrink();
        },
        data: (merchant) {
          final name =
              merchant.isEmpty ? "Merchant Not Found" : merchant[0].name;
          return InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      TransactionDetailPage(transaction: transaction),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                children: [
                  // Circle with first letter of transaction name
                  CircleAvatar(
                    backgroundColor: Colors.purple[100],
                    child: Text(
                      name.isNotEmpty ? name.toUpperCase() : "?",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.purple,
                      ),
                    ),
                  ),
                  SizedBox(width: 12),

                  // Transaction name
                  Expanded(
                    child: Text(
                      name,
                      style: TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                  ),

                  // Date/Time + Amount
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "${transaction.date.toIso8601String()}",
                        style: TextStyle(fontSize: 13, color: Colors.black54),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "₹${transaction.amount.toStringAsFixed(0)}",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        });
  }
}
