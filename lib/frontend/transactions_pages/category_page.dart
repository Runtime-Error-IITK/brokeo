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

  AppBar buildCustomAppBar(BuildContext context, double totalSpends) {
    final data = widget.category;
    return AppBar(
      backgroundColor: const Color.fromARGB(255, 243, 225, 247),
      iconTheme: IconThemeData(color: Colors.black),
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Category icon placed alone on the left
          Image.asset(
            'assets/category_icon/${data.name}.jpg',
            width: 40,
            height: 40,
            fit: BoxFit.cover,
          ),
          SizedBox(width: 20), // Extra spacing between the icon and the text
          // Texts in a Column to the right of the icon
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  "$totalSpends Spends - ₹${totalSpends.toStringAsFixed(0)}/₹${data.budget.toStringAsFixed(0)}",
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        // Edit icon inside a circular container
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black54.withOpacity(0.2),
            ),
            child: IconButton(
              icon: Icon(Icons.edit, color: Colors.white),
              onPressed: () {
                // TODO: Add logic to edit category details.
                _showEditCategoryDialog(
                  context,
                  data.name, // e.g., "Food and Drinks"
                  data.budget, // e.g., "4000"
                );
              },
            ),
          ),
        ),
        // New delete icon inside a circular container
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              // TODO: Add logic to delete category details.
              _showDeleteConfirmationDialog(context, widget.data.name);
            },
          ),
        ),
      ],
      elevation: 0,
    );
  }

  void _showDeleteConfirmationDialog(
      BuildContext context, String categoryName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Delete Category"),
          content:
              Text("Are you sure you want to delete category $categoryName?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // close dialog
              child: Text(
                "Cancel",
                style: TextStyle(color: Colors.black),
              ),
            ),
            TextButton(
              onPressed: () {
                // TODO: Implement actual delete logic here
                Navigator.pop(context); // close dialog
              },
              child: Text(
                "Delete",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showEditCategoryDialog(
    BuildContext context,
    String initialCategoryName,
    double initialBudget, // double
  ) {
    // Convert the double to a string for the text field
    String budgetValueAsString = initialBudget.toString();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Edit Category"),
          content: StatefulBuilder(
            builder: (context, setState) {
              String? selectedCategory = initialCategoryName;
              String? budgetValue =
                  budgetValueAsString; // Start with the string

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // For the category name, if you're using a dropdown
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    decoration: InputDecoration(labelText: "Category Name"),
                    items:
                        DummyDataService.getCategoriesFromBackend().map((cat) {
                      return DropdownMenuItem<String>(
                        value: cat,
                        child: Text(cat),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedCategory = value;
                      });
                    },
                  ),
                  SizedBox(height: 16),
                  // TextField for budget input
                  TextFormField(
                    initialValue: budgetValue,
                    decoration: InputDecoration(
                      labelText: "Budget",
                      prefixText: "₹",
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        budgetValue = value;
                      });
                    },
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // just close
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                // Convert the updated budget string back to a double
                // (handle parsing errors as needed)

                // TODO: Perform the update logic here
                // e.g., print("Updating category: $selectedCategory with budget $updatedBudget");
                Navigator.pop(context); // close dialog
              },
              child: Text("Confirm"),
            ),
          ],
        );
      },
    );
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
