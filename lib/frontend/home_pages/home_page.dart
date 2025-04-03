import 'dart:math';
import 'package:brokeo/backend/models/category.dart';
import 'package:brokeo/backend/models/merchant.dart';
import 'package:brokeo/backend/models/transaction.dart';
import 'package:brokeo/backend/services/providers/read_providers/category_stream_provider.dart'
    show CategoryFilter, categoryStreamProvider;
import 'package:brokeo/backend/services/providers/read_providers/merchant_stream_provider.dart'
    show MerchantFilter, merchantStreamProvider;
import 'package:brokeo/backend/services/providers/read_providers/transaction_stream_provider.dart'
    show TransactionFilter, transactionStreamProvider;
import 'package:brokeo/backend/services/providers/read_providers/user_id_provider.dart';
import 'package:brokeo/backend/services/providers/write_providers/transaction_service.dart';
import 'package:brokeo/frontend/transactions_pages/categories_page.dart';
import 'package:brokeo/frontend/profile_pages/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:brokeo/frontend/split_pages/manage_splits.dart';
import 'package:brokeo/frontend/profile_pages/budget_page.dart';
import 'package:brokeo/frontend/transactions_pages/category_page.dart';
import 'package:brokeo/frontend/transactions_pages/transaction_detail_page.dart';
import 'package:brokeo/frontend/split_pages/split_history.dart';
import 'package:brokeo/frontend/split_pages/choose_transactions.dart';
import 'package:brokeo/frontend/analytics_pages/analytics_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _currentIndex = 0;
  int expandedTransactionIndex = -1;
  bool showAllTransactions = false; // Toggle for transaction list
  bool showAllCategories = false;
  bool showAllScheduledPayments = false;
  bool showAllSplits = false;
  bool showAllBudgetCategories = false;

  @override
  void initState() {
    super.initState();
    // Initialize any state variables or perform setup here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileAndBudgetSection(),
            _buildTransactions(),
            _buildCategories(), // <-- NEW CATEGORIES SECTION
            // _buildScheduledPayments(scheduledPayments),
            // _buildSplits(splits),
            // _buildBudget(budgetCategories),
          ],
        ),
      ),
      bottomNavigationBar: buildBottomNavigationBar(),
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
        // Navigation logic based on index:
        if (index == 0) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
            (route) => false,
          );
        } else if (index == 1) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => CategoriesPage()),
            (route) => false,
          );
        } else if (index == 2) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => AnalyticsPage()),
            (route) => false,
          );
        } else if (index == 3) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => ManageSplitsPage()),
            (route) => false,
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

  Widget _buildProfileAndBudgetSection() {
    final transactionsAsync =
        ref.watch(transactionStreamProvider(TransactionFilter()));
    final userMetadataAsync = ref.watch(userMetadataStreamProvider);

    return userMetadataAsync.when(
      loading: () => const CircularProgressIndicator(),
      error: (error, stack) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("User error: $error")),
          );
        });
        return SizedBox.shrink();
      },
      data: (userMetadata) {
        return transactionsAsync.when(
          loading: () => const CircularProgressIndicator(),
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
              totalSpent += transaction.amount > 0 ? transaction.amount : 0;
            }

            double budget = userMetadata[budgetId] ?? 0;
            double percentageSpent = (totalSpent / budget) * 100;
            String currentMonth = DateFormat.MMMM().format(DateTime.now());
            String name = userMetadata[nameId] ?? 'User';

            return Container(
              padding: EdgeInsets.symmetric(vertical: 45, horizontal: 15),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.white, Color(0xFFF3E5F5), Colors.white],
                  stops: [0.0, 0.5, 1.0],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(30)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.account_circle,
                            size: 30, color: Colors.black54),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ProfilePage()),
                          );
                        },
                      ),
                      SizedBox(width: 10),
                      RichText(
                        text: TextSpan(
                          style: TextStyle(fontSize: 25, color: Colors.black),
                          children: [
                            TextSpan(text: "Hi, "),
                            TextSpan(
                              text: name.split(" ")[0],
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      Spacer(),
                      IconButton(
                        icon: Icon(Icons.notifications,
                            size: 28, color: Colors.black54),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: Column(
                      children: [
                        Text(
                          currentMonth,
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black54),
                        ),
                        SizedBox(height: 10),
                        CustomPaint(
                          size: Size(160, 160),
                          painter: ArcPainter(
                            progress: percentageSpent / 100,
                            strokeWidth: 8,
                            color: Colors.deepPurple,
                            gapSize: 20,
                          ),
                          child: Container(
                            width: 160,
                            height: 160,
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "₹${totalSpent.toStringAsFixed(0)}",
                                  style: TextStyle(
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  "${percentageSpent.toStringAsFixed(1)}%",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.normal,
                                      color: Colors.black87),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTransactions() {
    final asyncTransactions =
        ref.watch(transactionStreamProvider(TransactionFilter()));

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
        List<Transaction> transactionsToShow =
            showAllTransactions ? transactions : transactions.take(3).toList();
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, Color(0xFFF3E5F5), Colors.white],
              stops: [0.0, 0.5, 1.0],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
          ),
          child: Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            color: Color(0xFFEDE7F6),
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Header with "Transactions" Title & Icons
                  Row(
                    children: [
                      Text("Transactions",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      Spacer(),
                      IconButton(
                        icon: Icon(Icons.add, size: 22, color: Colors.black54),
                        onPressed: () {
                          _showAddTransactionDialog(context);
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          showAllTransactions
                              ? Icons.expand_less
                              : Icons.expand_more,
                          size: 22,
                          color: Colors.black54,
                        ),
                        onPressed: () {
                          setState(() {
                            showAllTransactions = !showAllTransactions;
                          });
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 10),

                  /// Transaction List or Empty Message
                  transactions.isEmpty
                      ? Center(
                          child: Text(
                            "No Transactions Yet",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black54),
                          ),
                        )
                      : Column(
                          children:
                              transactionsToShow.asMap().entries.map((entry) {
                            return Column(
                              children: [
                                _transactionTile(entry.value, entry.key),
                                if (entry.key < transactionsToShow.length - 1)
                                  Divider(color: Colors.grey[300]),
                              ],
                            );
                          }).toList(),
                        ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showAddTransactionDialog(BuildContext context) {
    String? amount;
    String? merchant;
    Category? selectedCategory;
    String transactionType =
        "Credit"; // Default transaction type set to "Credit"

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Consumer(builder: (context, ref, child) {
          final asyncCategories =
              ref.watch(categoryStreamProvider(CategoryFilter()));
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
                                // Assume you have the merchant name in a variable called merchantInput.
                                final filter =
                                    MerchantFilter(merchantName: merchant);
                                final asyncMerchants =
                                    ref.read(merchantStreamProvider(filter));

                                // Check what state the async value is in.
                                if (asyncMerchants
                                    is AsyncData<List<Merchant>>) {
                                  final merchants = asyncMerchants.value;
                                  if (merchants.isNotEmpty) {
                                    // Use the merchantId from the first matching merchant.
                                    final merchantId =
                                        merchants.first.merchantId;
                                    Transaction newTransaction = Transaction(
                                      transactionId: "",
                                      amount: double.parse(amount!),
                                      date: DateTime.now(),
                                      merchantId: merchantId,
                                      categoryId: selectedCategory!.categoryId,
                                      userId: ref.watch(userIdProvider.select(
                                          (id) =>
                                              id ??
                                              "")), // You'll likely fill this in from your auth provider.
                                      sms: "Manually added transaction",
                                    );
                                    final cloudTransaction =
                                        CloudTransaction.fromTransaction(
                                            newTransaction);
                                    final transactionService =
                                        ref.read(transactionServiceProvider);
                                    if (transactionService == null) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content:
                                                Text("User not logged in")),
                                      );
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
                                      } else {
                                        return;
                                      }
                                    } else {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content: Text(
                                                  "Failed to add transaction.")),
                                        );
                                      } else {
                                        return;
                                      }
                                    }

                                    // Perform any further transaction processing here.
                                    if (context.mounted) {
                                      Navigator.pop(context);
                                    } else {
                                      return;
                                    }
                                  } else {
                                    // No merchant found; you might later add logic to create a new merchant.
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              "No merchant found with that name.")),
                                    );
                                  }
                                } else if (asyncMerchants is AsyncLoading) {
                                  // The data is still loading.
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            "Loading merchant data, please wait...")),
                                  );
                                } else if (asyncMerchants is AsyncError) {
                                  // There was an error retrieving the merchant data.
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            "Error loading merchant data.")),
                                  );
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

  Widget _transactionTile(Transaction transaction, int index) {
    final merchantFilter = MerchantFilter(
      merchantId: transaction.merchantId,
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
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.purple[100],
                      child: Text(
                        merchant[0].name,
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
                    Text(
                      "₹${transaction.amount.abs()}",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color:
                            transaction.amount < 0 ? Colors.red : Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
              if (expandedTransactionIndex == index)
                Padding(
                  padding:
                      const EdgeInsets.only(left: 50, right: 10, bottom: 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Date: ${DateFormat('dd MMM yyyy').format(DateTime.now())}\nCategory: Groceries",
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategories() {
    final categoryFilter = CategoryFilter();
    final asyncCategories = ref.watch(categoryStreamProvider(categoryFilter));

    return asyncCategories.when(
        loading: () => const CircularProgressIndicator(),
        error: (error, stack) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Category error: $error")),
            );
          });
          return SizedBox.shrink();
        },
        data: (categories) {
          List<Category> categoriesToShow =
              showAllCategories ? categories : categories.take(3).toList();

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, Color(0xFFF3E5F5), Colors.white],
                stops: [0.0, 0.5, 1.0],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
            ),
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              color: Color(0xFFEDE7F6),
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header row
                    Row(
                      children: [
                        Text(
                          "Categories",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Spacer(),
                        IconButton(
                          icon: Icon(
                            showAllCategories
                                ? Icons.expand_less
                                : Icons.expand_more,
                            size: 22,
                            color: Colors.black54,
                          ),
                          onPressed: () {
                            setState(() {
                              showAllCategories = !showAllCategories;
                            });
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 10),

                    // If empty
                    categories.isEmpty
                        ? Center(
                            child: Text(
                              "No Categories Yet",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black54,
                              ),
                            ),
                          )
                        : Column(
                            children:
                                categoriesToShow.asMap().entries.map((entry) {
                              return Column(
                                children: [
                                  _buildCategoryTile(entry.value),
                                  if (entry.key < categoriesToShow.length - 1)
                                    Divider(color: Colors.grey[300]),
                                ],
                              );
                            }).toList(),
                          ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  Widget _buildCategoryTile(Category category) {
    final transactionFilter = TransactionFilter(
      categoryId: category.categoryId,
    );
    final asyncCategoryTransactions =
        ref.watch(transactionStreamProvider(transactionFilter));

    return asyncCategoryTransactions.when(
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
        double sum = 0;
        for (var transaction in transactions) {
          sum += transaction.amount > 0 ? transaction.amount : 0;
        }
        return InkWell(
          onTap: () {
            final data = CategoryCardData(
              name: category.name,
              icon: Icons.category,
              color: Colors.blue,
              spent: 0,
              budget: category.budget,
            );
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CategoryPage(data: data),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              children: [
                // Circle avatar with emoji
                CircleAvatar(
                  backgroundColor: Colors.redAccent.withOpacity(0.1),
                  child: Text(
                    "😭",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    category.name,
                    style: TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ),
                Text(
                  "₹${sum.toStringAsFixed(0)}",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

const String budgetId = "budget";
const String nameId = "name";
