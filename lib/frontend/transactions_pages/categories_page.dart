// import 'package:brokeo/backend/services/providers2/read_providers/category_stream_provider.dart';
import 'dart:convert' show json;

import 'package:brokeo/backend/models/category.dart' show Category;
import 'package:brokeo/backend/models/merchant.dart'
    show CloudMerchant, Merchant;
import 'package:brokeo/backend/models/transaction.dart'
    show CloudTransaction, Transaction;
import 'package:brokeo/backend/services/providers/read_providers/category_stream_provider.dart';
import 'package:brokeo/backend/services/providers/read_providers/merchant_stream_provider.dart'
    show MerchantFilter, merchantStreamProvider;
import 'package:brokeo/backend/services/providers/read_providers/transaction_stream_provider.dart'
    show TransactionFilter, transactionStreamProvider;
import 'package:brokeo/backend/services/providers/read_providers/user_id_provider.dart';
import 'package:brokeo/backend/services/providers/write_providers/merchant_service.dart'
    show merchantServiceProvider;
import 'package:brokeo/backend/services/providers/write_providers/transaction_service.dart'
    show transactionServiceProvider;
import 'package:brokeo/frontend/home_pages/home_page.dart';
import 'package:brokeo/frontend/split_pages/manage_splits.dart';
import 'package:brokeo/frontend/transactions_pages/category_page.dart';
import 'package:brokeo/frontend/transactions_pages/color.dart'
    show loadCategoryColors;
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:brokeo/frontend/transactions_pages/transaction_detail_page.dart';
import 'package:brokeo/frontend/transactions_pages/merchants_page.dart';
import 'package:brokeo/frontend/analytics_pages/analytics_page.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' show DateFormat;

/// Main CategoriesPage
class CategoriesPage extends ConsumerStatefulWidget {
  const CategoriesPage({Key? key}) : super(key: key);

  @override
  _CategoriesPageState createState() => _CategoriesPageState();
}

class _CategoriesPageState extends ConsumerState<CategoriesPage>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 1;
  late TabController _tabController;
  bool showTransactions = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        length: 3, vsync: this, initialIndex: 0); // Change initialIndex to 0
  }

  @override
  Widget build(BuildContext context) {
    // final asyncCategories = ref.watch(categoryStreamProvider);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // 1) Top section with the circular arc
            buildTopSection(),

            // Divider below the top section
            // Divider(thickness: 1),
            SizedBox(height: 8),

            // 2) Clickable navigation bar (Transactions | Categories | Merchants)
            buildNavigationBar(context),

            SizedBox(height: 10),
            // 3) Expanded area with a ListView or Transactions:
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildTransactions(),
                  ListView(
                    children: [
                      // Donut chart
                      buildDonutChart(),
                      SizedBox(height: 20),
                      // Placeholder for your categories list
                      buildCategoryGrid(),
                    ],
                  ),
                  _buildMerchants(), //Center(child: Text("Merchants View")),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton(
              onPressed: () {
                _showAddTransactionDialog(context);
              },
              child: Icon(Icons.add, color: Colors.white),
              backgroundColor: Color.fromARGB(255, 97, 53, 186),
              shape: CircleBorder(),
            )
          : null,
      // bottomNavigationBar: buildBottomNavigationBar(),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _tabController.addListener(() {
      setState(() {});
    });
  }

  /// Top section: Circular arc for "Safe to Spend" & "Amount Spent"
  Widget buildTopSection() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59, 999);

    final asynCurrentMonthTransactions = ref.watch(
      transactionStreamProvider(
        TransactionFilter(
          startDate: startOfMonth,
          endDate: endOfMonth,
        ),
      ),
    );

    final asyncUserMetadata = ref.watch(userMetadataStreamProvider);

    return asyncUserMetadata.when(
      loading: () => Center(child: CircularProgressIndicator()),
      error: (error, stack) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("User error: $error")),
          );
        });
        return SizedBox.shrink();
      },
      data: (userMetaData) {
        return asynCurrentMonthTransactions.when(
          loading: () => Center(child: CircularProgressIndicator()),
          error: (error, stack) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("User error: $error")),
              );
            });
            return SizedBox.shrink();
          },
          data: (transactions) {
            double totalSpent = 0;
            for (var transaction in transactions) {
              totalSpent -= transaction.amount < 0 ? transaction.amount : 0;
            }
            double budget = userMetaData['budget'];
            final now = DateTime.now();
            final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
            final daysRemaining = lastDayOfMonth.day - now.day;
            double dailySafeToSpend = (budget - totalSpent) / daysRemaining;
            double progress = totalSpent / budget;
            final currentMonth =
                DateFormat.MMMM().format(now); // e.g., "January"

            return Padding(
              padding: const EdgeInsets.all(14.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Circular arc showing "Safe to Spend"
                  CustomPaint(
                    size: Size(160, 160),
                    painter: ArcPainter(
                      progress: progress,
                      strokeWidth: 8,
                      color: Colors.deepPurple,
                    ),
                    child: Container(
                      width: 130,
                      height: 130,
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Safe to Spend",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 4),
                          Text(
                            "₹${dailySafeToSpend.toStringAsFixed(0)}/day",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 15),
                  // Right column: Current Month & "Amount Spent"
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Current Month
                      Text(
                        currentMonth,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 8),
                      // "Amount Spent" label
                      Text(
                        "Amount Spent",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 6),
                      // Amount spent value
                      Text(
                        "₹${totalSpent.toStringAsFixed(0)}",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// Navigation bar with three items: Transactions, Categories, Merchants
  Widget buildNavigationBar(BuildContext context) {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: Colors.purple,
        unselectedLabelColor: Colors.grey,
        indicatorColor: Colors.purple,
        tabs: [
          Tab(text: "Transactions"),
          Tab(text: "Categories"),
          Tab(text: "Merchants"),
        ],
      ),
    );
  }

  Widget buildDonutChart() {
    // In a real app, you'd fetch these from your database.
    // Here, we define some dummy data:
    return Padding(
      padding: const EdgeInsets.all(16.0),
      // child: DonutChartWidget(),
    );
  }

  /// Builds a grid of categories (2 columns)..
  Widget buildCategoryGrid() {
    final categoryFilter = CategoryFilter();
    final asyncCategories = ref.watch(categoryStreamProvider(categoryFilter));

    return asyncCategories.when(
        loading: () => Center(child: CircularProgressIndicator()),
        error: (error, stack) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Category error: $error")),
            );
          });
          return SizedBox.shrink();
        },
        data: (categories) {
          return GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              // Spacing between columns
              crossAxisSpacing: 16,
              // Spacing between rows
              mainAxisSpacing: 16,
              // Adjust if you want taller or wider cards
              childAspectRatio: 1.0, // Adjust if you want wider or taller cards
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              return buildCategoryCard(context, cat);
            },
          );
        });
  }

  /// Builds an individual category card (name, icon, spent/budget).
  Widget buildCategoryCard(BuildContext context, Category category) {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59, 999);

    final filter = TransactionFilter(
      categoryId: category.categoryId,
      startDate: startOfMonth,
      endDate: endOfMonth,
    );

    final asyncTransactions = ref.watch(transactionStreamProvider(filter));

    return asyncTransactions.when(
      loading: () => Center(child: CircularProgressIndicator()),
      error: (error, stack) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Transaction error: $error")),
          );
        });
        return SizedBox.shrink();
      },
      data: (transactions) {
        double spent = 0;
        for (var transaction in transactions) {
          spent -= transaction.amount < 0 ? transaction.amount : 0;
        }
        return FutureBuilder<Map<String, Color>>(
          future: loadCategoryColors(),
          builder: (context, snapshot) {
            // Use a default light grey color if the data isn't loaded yet.
            Color backgroundColor = Colors.grey.shade200;
            if (snapshot.hasData) {
              final categoryColors = snapshot.data!;
              // Use the color for the current category name, fallback to default.
              backgroundColor =
                  categoryColors[category.name] ?? Colors.grey.shade200;
            }
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CategoryPage(
                      categoryId: category.categoryId,
                    ),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: backgroundColor, // light background tint from JSON
                  border: Border.all(color: Colors.black, width: 1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Category name
                    Text(
                      category.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Icon
                    Image.asset(
                      'assets/colorful_category_icon/${category.name}.jpg',
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                    ),
                    // ImageIcon(
                    //   AssetImage('assets/category_icon/${category.name}.jpg'),
                    //   size: 40,
                    // ),
                    const SizedBox(height: 12),
                    Text(
                      "₹${spent.toStringAsFixed(0)}/₹${category.budget.toStringAsFixed(0)}",
                      style: TextStyle(fontSize: 14),
                    ),
                    // Spent/Budget (add your implementation)
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showAddTransactionDialog(BuildContext context) {
    String? amount;
    String? merchant;
    Category? selectedCategory;
    final emptyCategoryFilter = CategoryFilter();
    String transactionType =
        "Credit"; // Default transaction type set to "Credit"

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Consumer(builder: (context, ref, child) {
          final asyncCategories =
              ref.watch(categoryStreamProvider(emptyCategoryFilter));
          // log(asyncCategories.toString());
          return asyncCategories.when(
            loading: () => AlertDialog(
              title: Center(child: Text("Add transaction")),
              content: SizedBox(
                height: 80,
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
            error: (error, stack) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Category error: $error")),
                );
              });
              return SizedBox.shrink();
            },
            data: (categories) {
              // Wrap the entire AlertDialog in a StatefulBuilder so that
              // any changes update both the content and the actions.
              // log(categories.length.toString());
              return StatefulBuilder(
                builder: (context, setState) {
                  bool isFormValid = amount != null &&
                      amount!.trim().isNotEmpty &&
                      merchant != null &&
                      merchant!.trim().isNotEmpty &&
                      selectedCategory != null;
                  return AlertDialog(
                    title: Center(child: Text("Add transaction")),
                    content: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Radio buttons for transaction type
                            Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    children: [
                                      Radio<String>(
                                        value: "Credit",
                                        groupValue: transactionType,
                                        onChanged: (value) {
                                          setState(() {
                                            transactionType = value!;
                                          });
                                        },
                                      ),
                                      Text("Credit"),
                                    ],
                                  ),
                                  SizedBox(width: 40),
                                  Row(
                                    children: [
                                      Radio<String>(
                                        value: "Debit",
                                        groupValue: transactionType,
                                        onChanged: (value) {
                                          setState(() {
                                            transactionType = value!;
                                          });
                                        },
                                      ),
                                      Text("Debit"),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 16),
                            // Amount input field
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: "Amount",
                                prefixText: "₹",
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                setState(() {
                                  amount = value;
                                });
                              },
                            ),
                            SizedBox(height: 16),
                            // Merchant input field
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: "Merchant",
                              ),
                              onChanged: (value) {
                                setState(() {
                                  merchant = value;
                                });
                              },
                            ),
                            SizedBox(height: 16),
                            // Dropdown for selecting a category
                            DropdownButtonFormField<Category>(
                              value: selectedCategory,
                              decoration: InputDecoration(
                                labelText: "Category",
                              ),
                              items: categories.map((cat) {
                                return DropdownMenuItem<Category>(
                                  value: cat,
                                  child: Text(cat.name),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedCategory = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: isFormValid
                            ? () async {
                                // Create a filter for the merchant using the merchant name from input.
                                final filter =
                                    MerchantFilter(merchantName: merchant);
                                try {
                                  // Await the first snapshot from the merchant stream.
                                  final merchants = await ref.read(
                                      merchantStreamProvider(filter).future);
                                  String merchantId;

                                  if (merchants.isNotEmpty) {
                                    // Merchant exists, so use the merchantId from the first one.
                                    merchantId = merchants.first.merchantId;
                                  } else {
                                    // Merchant not found. Insert a new merchant first.
                                    final merchantService =
                                        ref.read(merchantServiceProvider);
                                    if (merchantService == null) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content:
                                                  Text("User not logged in")),
                                        );
                                      }
                                      return;
                                    }
                                    // Create a new CloudMerchant using the merchant name and the selected category.
                                    final newCloudMerchant = CloudMerchant(
                                      merchantId:
                                          "", // Will be auto-generated by Firestore.
                                      name: merchant!,
                                      userId: ref.read(userIdProvider) ?? "",
                                      categoryId: selectedCategory!.categoryId,
                                      // Add any additional fields if needed.
                                    );
                                    final insertedMerchant =
                                        await merchantService
                                            .insertMerchant(newCloudMerchant);
                                    if (insertedMerchant == null) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content: Text(
                                                  "Failed to add merchant.")),
                                        );
                                      }
                                      return;
                                    }
                                    merchantId = insertedMerchant.merchantId;
                                  }

                                  // Now, create the transaction using the obtained merchantId.
                                  final newTransaction = Transaction(
                                    transactionId: "",
                                    amount: transactionType == "Credit"
                                        ? double.parse(amount!)
                                        : -1 * double.parse(amount!),
                                    date: DateTime.now(),
                                    merchantId: merchantId,
                                    categoryId: selectedCategory!.categoryId,
                                    userId: ref.read(userIdProvider) ?? "",
                                    sms: "Manually added transaction",
                                  );
                                  final cloudTransaction =
                                      CloudTransaction.fromTransaction(
                                          newTransaction);
                                  final transactionService =
                                      ref.read(transactionServiceProvider);
                                  if (transactionService == null) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content:
                                                Text("User not logged in")),
                                      );
                                    }
                                    return;
                                  }
                                  final result = await transactionService
                                      .insertTransaction(cloudTransaction);
                                  if (result != null) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                "Transaction added successfully!")),
                                      );
                                      Navigator.pop(context);
                                    }
                                  } else {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                "Failed to add transaction.")),
                                      );
                                    }
                                  }
                                } catch (error) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              "Error loading merchant data: $error")),
                                    );
                                  }
                                }
                              }
                            : null,
                        child: Text("Confirm"),
                      ),
                    ],
                  );
                },
              );
            },
          );
        });
      },
    );
  }

  Widget buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) {
        if (index != _currentIndex) {
          setState(() {
            _currentIndex = index;
          });
        }
        if (index == 0) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        } else if (index == 1) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => CategoriesPage()),
          );
        } else if (index == 2) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        } else if (index == 3) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        }
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.purple,
      unselectedItemColor: Colors.grey,
      iconSize: 24,
      selectedFontSize: 12,
      unselectedFontSize: 12,
      items: [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
        BottomNavigationBarItem(icon: Icon(Icons.list), label: "Transactions"),
        BottomNavigationBarItem(
            icon: Icon(Icons.analytics), label: "Analytics"),
        BottomNavigationBarItem(icon: Icon(Icons.people), label: "Split"),
      ],
    );
  }

  Widget _buildTransactions() {
    final transactionFilter = TransactionFilter();
    final asyncTransactions =
        ref.watch(transactionStreamProvider(transactionFilter));
    return asyncTransactions.when(
      loading: () => Center(child: CircularProgressIndicator()),
      error: (error, stack) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Transaction error: $error")),
          );
        });
        return SizedBox.shrink();
      },
      data: (transactions) {
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
          itemCount: transactions.length,
          itemBuilder: (context, index) {
            return Column(
              children: [
                _transactionTile(transactions[index], index),
                if (index < transactions.length - 1)
                  Divider(color: Colors.grey[300]),
              ],
            );
          },
        );
      },
    );
  }

  Widget _transactionTile(Transaction transaction, int index) {
    final String merchantId = transaction.merchantId;

    final merchantFilter = MerchantFilter(
      merchantId: merchantId,
    );
    final asyncMerchant = ref.watch(merchantStreamProvider(merchantFilter));

    return asyncMerchant.when(
      loading: () => const CircularProgressIndicator(),
      error: (error, stack) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Merchant error: $error")),
          );
        });
        return SizedBox.shrink();
      },
      data: (merchant) {
        // log(merchant.length.toString());
        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TransactionDetailPage(
                  transaction: transaction,
                ),
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
                        merchant[0].name[0],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.purple,
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        merchant[0].name,
                        style: TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          DateFormat("MMM dd, yyyy, hh:mm ")
                              .format(transaction.date),
                          style: TextStyle(fontSize: 13, color: Colors.black54),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "₹${transaction.amount.abs().toStringAsFixed(0)}",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: transaction.amount < 0
                                ? Colors.red
                                : Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // if (expandedTransactionIndex == index)
              //   Padding(
              //     padding:
              //         const EdgeInsets.only(left: 50, right: 10, bottom: 8),
              //     child: Align(
              //       alignment: Alignment.centerLeft,
              //       child: Text(
              //         "Date: ${DateFormat('dd MMM yyyy').format(DateTime.now())}\nCategory: Groceries",
              //         style: TextStyle(fontSize: 12, color: Colors.black54),
              //       ),
              //     ),
              //   ),
            ],
          ),
        );
      },
    );
  }

// Merchant
  Widget _buildMerchants() {
    final merchantFilter = MerchantFilter();
    final asyncMerchants = ref.watch(merchantStreamProvider(merchantFilter));

    return asyncMerchants.when(
      loading: () => Center(child: CircularProgressIndicator()),
      error: (error, stack) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Merchant error: $error")),
          );
        });
        return SizedBox.shrink();
      },
      data: (merchants) {
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
          itemCount: merchants.length,
          itemBuilder: (context, index) {
            return Column(
              children: [
                _merchantTile(merchants[index], index),
                if (index < merchants.length - 1)
                  Divider(color: Colors.grey[300]),
              ],
            );
          },
        );
      },
    );
  }

  Widget _merchantTile(Merchant merchant, int index) {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59, 999);

    final filter = TransactionFilter(
      merchantId: merchant.merchantId,
      startDate: startOfMonth,
      endDate: endOfMonth,
    );

    final asyncTransactions = ref.watch(transactionStreamProvider(filter));

    return asyncTransactions.when(
        loading: () => const CircularProgressIndicator(),
        error: (error, stack) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Transaction error: $error")),
            );
          });
          return SizedBox.shrink();
        },
        data: (transactions) {
          double amount = 0;
          int spends = 0;
          for (var transaction in transactions) {
            amount -= transaction.amount < 0 ? transaction.amount : 0;
            if (transaction.amount < 0) {
              spends++;
            }
          }

          return InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MerchantsPage(
                    merchantId: merchant.merchantId,
                  ),
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
                          merchant.name[0],
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.purple),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          merchant.name,
                          style: TextStyle(fontSize: 14, color: Colors.black87),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "₹${amount.abs()}",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              "${spends.toString()} Spends", // Placeholder for time
                              style: TextStyle(
                                  fontSize: 12, color: Colors.black54),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        });
  }
}

/// DonutChartWidget: draws a donut chart + legend for up to 3 categories + "Others"
// class DonutChartWidget extends StatelessWidget {
//   final List<Category> categories;

//   const DonutChartWidget({super.key, required this.categories});

//   // Load category colors from JSON file.
//   Future<Map<String, Color>> loadCategoryColors() async {
//     final jsonString =
//         await rootBundle.loadString('assets/category_colors.json');
//     final Map<String, dynamic> jsonMap = json.decode(jsonString);
//     return jsonMap.map((key, value) => MapEntry(key, _hexToColor(value)));
//   }

//   // Helper function to convert a hex string to a Flutter Color.
//   Color _hexToColor(String hex) {
//     hex = hex.replaceAll('#', '');
//     if (hex.length == 6) {
//       hex = 'FF$hex'; // Add alpha if missing.
//     }
//     return Color(int.parse(hex, radix: 16));
//   }

//   // Convert List<Category> into List<CategoryData> for the chart.
//   // Each category's "percentage" is simply its budget.
//   List<CategoryData> _convertToCategoryData(
//       List<Category> categories, Map<String, Color> colorMapping) {
//     return categories.map((cat) {
//       return CategoryData(
//         name: cat.name,
//         percentage: cat.budget,
//         // Use the mapped color if available; otherwise, default to grey.
//         color: colorMapping[cat.name] ?? Colors.grey,
//       );
//     }).toList();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<Map<String, Color>>(
//       future: loadCategoryColors(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return Center(child: CircularProgressIndicator());
//         }
//         if (snapshot.hasError) {
//           return Center(child: Text("Error loading category colors"));
//         }
//         final colorMapping = snapshot.data!;
//         final categoryData = _convertToCategoryData(categories, colorMapping);

//         // Calculate total budget (sum of all category budgets)
//         final double totalBudget =
//             categoryData.fold(0.0, (sum, cd) => sum + cd.percentage);

//         // If totalBudget is zero, the arcs will have no sweep.
//         // You might want to handle that scenario separately if needed.
//         return Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             // Donut Chart
//             CustomPaint(
//               size: Size(160, 160),
//               painter:
//                   DonutChartPainter(categoryData, totalBudget: totalBudget),
//             ),
//             SizedBox(width: 60),
//             // Legend on the right
//             Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: categoryData.map((cat) {
//                 return Padding(
//                   padding: const EdgeInsets.symmetric(vertical: 4.0),
//                   child: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       // Color bullet
//                       Container(
//                         width: 12,
//                         height: 12,
//                         decoration: BoxDecoration(
//                           color: cat.color,
//                           shape: BoxShape.circle,
//                         ),
//                       ),
//                       SizedBox(width: 8),
//                       // Category name
//                       Text(
//                         cat.name,
//                         style: TextStyle(fontSize: 14, color: Colors.black),
//                       ),
//                     ],
//                   ),
//                 );
//               }).toList(),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }

// /// The custom painter for drawing the donut chart.
// class DonutChartPainter extends CustomPainter {
//   final List<CategoryData> categories;
//   final double totalBudget;

//   DonutChartPainter(this.categories, {required this.totalBudget});

//   @override
//   void paint(Canvas canvas, Size size) {
//     final center = Offset(size.width / 2, size.height / 2);
//     final radius = min(size.width, size.height) / 2;

//     final paint = Paint()
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 10; // Donut ring thickness.

//     double startRadian = -pi / 2; // Start at top.

//     // When totalBudget is zero, we simply don't draw any arcs.
//     if (totalBudget == 0) return;

//     for (var cat in categories) {
//       final sweepRadian = (cat.percentage / totalBudget) * 2 * pi;
//       paint.color = cat.color;
//       canvas.drawArc(
//         Rect.fromCircle(center: center, radius: radius),
//         startRadian,
//         sweepRadian,
//         false,
//         paint,
//       );
//       startRadian += sweepRadian;
//     }
//   }

//   @override
//   bool shouldRepaint(covariant DonutChartPainter oldDelegate) {
//     return oldDelegate.categories != categories ||
//         oldDelegate.totalBudget != totalBudget;
//   }
// }

/// ArcPainter for the top circle (Safe to Spend)
class ArcPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color color;
  final double gapSize;

  ArcPainter({
    required this.progress,
    required this.strokeWidth,
    required this.color,
    this.gapSize = 15,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint trackPaint = Paint()
      ..color = Colors.grey[300]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    Paint progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Draw background track (full circle)
    canvas.drawArc(
      Rect.fromCircle(
        center: size.center(Offset.zero),
        radius: size.width / 2,
      ),
      0,
      2 * pi,
      false,
      trackPaint,
    );

    // Draw the progress arc
    canvas.drawArc(
      Rect.fromCircle(
        center: size.center(Offset.zero),
        radius: size.width / 2,
      ),
      -pi / 2,
      2 * pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Model to hold each category's name, percentage, and color.
// class CategoryData {
//   final String name;
//   final double percentage; // e.g. 40 => 40%
//   final Color color;

//   CategoryData({
//     required this.name,
//     required this.percentage,
//     required this.color,
//   });
// }

// class CategoryCardData {
//   final String name;
//   final double spent;
//   final double budget;
//   final IconData icon;
//   final Color color;

//   CategoryCardData({
//     required this.name,
//     required this.spent,
//     required this.budget,
//     required this.icon,
//     required this.color,
//   });
// }

/// DummyDataService class with static methods to simulate backend calls.
// class DummyDataService {
//   static double getDailySafeToSpend() => 365.0;
//   static double getAmountSpent() => 3028.0;
//   static double getProgress() => 0.5; // 50% usage
//   static List<CategoryData> getCategories() {
//     return [
//       CategoryData(name: "Food", percentage: 0.4, color: Colors.red),
//       CategoryData(name: "Shopping", percentage: 0.3, color: Colors.blue),
//       CategoryData(name: "Travel", percentage: 0.2, color: Colors.green),
//       CategoryData(name: "Others", percentage: 0.1, color: Colors.grey),
//     ];
//   }

//   static List<CategoryCardData> getCategoriesData() {
//     return [
//       CategoryCardData(
//         name: "Food",
//         spent: 500,
//         budget: 1000,
//         icon: Icons.fastfood,
//         color: Colors.red,
//       ),
//       CategoryCardData(
//         name: "Shopping",
//         spent: 300,
//         budget: 500,
//         icon: Icons.shopping_cart,
//         color: Colors.blue,
//       ),
//       CategoryCardData(
//         name: "Travel",
//         spent: 200,
//         budget: 1000,
//         icon: Icons.flight,
//         color: Colors.green,
//       ),
//       CategoryCardData(
//         name: "Travel",
//         spent: 200,
//         budget: 1000,
//         icon: Icons.flight,
//         color: Colors.green,
//       ),
//       CategoryCardData(
//         name: "Travel",
//         spent: 200,
//         budget: 1000,
//         icon: Icons.flight,
//         color: Colors.green,
//       ),
//       CategoryCardData(
//         name: "Travel",
//         spent: 200,
//         budget: 1000,
//         icon: Icons.flight,
//         color: Colors.green,
//       ),
//       CategoryCardData(
//         name: "Add Category",
//         spent: 0,
//         budget: 0,
//         icon: Icons.add,
//         color: Colors.grey,
//       ),
//     ];
//   }

//   static List<String> getCategoriesFromBackend() {
//     return ["Food", "Shopping", "Travel", "Others"];
//   }
// }

// /// Backend
// class MockBackend {
//   static List<Transaction> getTransactions() {
//     return [
//       Transaction(
//           name: "Chetan Singh",
//           amount: -50,
//           date: "25 Jan'25",
//           time: "11:00 am"),
//       Transaction(
//           name: "Darshan", amount: -510, date: "24 Jan'25", time: "10:00 am"),
//       Transaction(
//           name: "Anjali Patra",
//           amount: 1200,
//           date: "23 Jan'25",
//           time: "09:00 am"),
//       Transaction(
//           name: "Extra Transaction",
//           amount: -200,
//           date: "22 Jan'25",
//           time: "08:00 am"),
//     ];
//   }
// }
