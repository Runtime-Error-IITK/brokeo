import 'dart:math';
import 'package:brokeo/frontend/transactions_pages/categories_page.dart';
import 'package:brokeo/frontend/profile_pages/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:brokeo/models/transaction_model.dart'; // <== new import
import 'package:brokeo/frontend/split_pages/manage_splits.dart'; // <== new import

/// Home Page
class HomePage extends StatefulWidget {
  final String name;
  final double budget;

  HomePage({required this.name, required this.budget});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool showAllTransactions = false; // Toggle for transaction list
  int expandedTransactionIndex = -1; // Tracks which transaction is expanded
  int _currentIndex = 0; // Tracks the selected bottom navigation index
  bool showAllCategories = false;
  bool showAllScheduledPayments = false;
  bool showAllSplits = false;
  bool showAllBudgetCategories = false;

  @override
  Widget build(BuildContext context) {
    String currentMonth = DateFormat.MMMM().format(DateTime.now());

    // Get data
    List<Transaction> transactions = MockBackend.getTransactions(context);
    List<CategoryItem> categories = MockBackend.getCategories();
    List<ScheduledPayment> scheduledPayments =
        MockBackend.getScheduledPayments();
    List<Split> splits = MockBackend.getSplits();
    List<BudgetCategory> budgetCategories = MockBackend.getBudgetCategories();
    double totalSpent = MockBackend.getTotalSpent();
    double spentPercentage = (totalSpent / widget.budget) * 100;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileAndBudgetSection(
                currentMonth, totalSpent, spentPercentage),
            _buildTransactions(transactions),
            _buildCategories(categories), // <-- NEW CATEGORIES SECTION
            _buildScheduledPayments(scheduledPayments),
            _buildSplits(splits),
            _buildBudget(budgetCategories),
          ],
        ),
      ),
      bottomNavigationBar: buildBottomNavigationBar(),
    );
  }

  /// Profile & Budget Section
  Widget _buildProfileAndBudgetSection(
      String month, double spent, double percentage) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 45, horizontal: 15),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Color(0xFFF3E5F5), Colors.white],
          stops: [0.0, 0.5, 1.0],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              IconButton(
                icon:
                    Icon(Icons.account_circle, size: 30, color: Colors.black54),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProfilePage()),
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
                      text: widget.name,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Spacer(),
              IconButton(
                icon:
                    Icon(Icons.notifications, size: 28, color: Colors.black54),
                onPressed: () {},
              ),
            ],
          ),
          SizedBox(height: 20),
          Center(
            child: Column(
              children: [
                Text(
                  month,
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54),
                ),
                SizedBox(height: 10),
                CustomPaint(
                  size: Size(160, 160),
                  painter: ArcPainter(
                    progress: percentage / 100,
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
                          "₹${spent.toStringAsFixed(0)}",
                          style: TextStyle(
                              fontSize: 30, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 5),
                        Text(
                          "${percentage.toStringAsFixed(1)}%",
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
  }

  /// Transactions List
  Widget _buildTransactions(List<Transaction> transactions) {
    // If not showing all transactions, take only the top 3
    List<Transaction> transactionsToShow =
        showAllTransactions ? transactions : transactions.take(3).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 20),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Spacer(),
                  IconButton(
                    icon: Icon(Icons.add, size: 22, color: Colors.black54),
                    onPressed: () {
                      // TODO: Handle add transaction
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
                      children: transactionsToShow.asMap().entries.map((entry) {
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
  }

  /// Single Transaction Tile
  Widget _transactionTile(Transaction transaction, int index) {
    return InkWell(
      onTap: () {
        setState(() {
          expandedTransactionIndex =
              (expandedTransactionIndex == index) ? -1 : index;
        });
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
                    transaction.name[0],
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.purple),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    transaction.name,
                    style: TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ),
                Text(
                  "₹${transaction.amount.abs()}",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: transaction.amount < 0 ? Colors.red : Colors.green,
                  ),
                ),
              ],
            ),
          ),
          if (expandedTransactionIndex == index)
            Padding(
              padding: const EdgeInsets.only(left: 50, right: 10, bottom: 8),
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
  }

  /// Categories List
  Widget _buildCategories(List<CategoryItem> categories) {
    List<CategoryItem> categoriesToShow =
        showAllCategories ? categories : categories.take(3).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Spacer(),
                  IconButton(
                    icon: Icon(Icons.add, size: 22, color: Colors.black54),
                    onPressed: () {
                      // TODO: Handle "Add Category"
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      showAllCategories ? Icons.expand_less : Icons.expand_more,
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
                      children: categoriesToShow.asMap().entries.map((entry) {
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
  }

// Single Category tile
  Widget _buildCategoryTile(CategoryItem category) {
    return InkWell(
      onTap: () {
        // TODO: Implement onTap logic for category
        // For example, open category details or show a dialog.
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          children: [
            // Circle avatar with emoji
            CircleAvatar(
              backgroundColor: Colors.redAccent.withOpacity(0.1),
              child: Text(
                category.emoji,
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
              "₹${category.amount.toStringAsFixed(0)}",
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
  }

  Widget _buildScheduledPayments(List<ScheduledPayment> payments) {
    // If not expanded, only show top 3
    List<ScheduledPayment> paymentsToShow =
        showAllScheduledPayments ? payments : payments.take(3).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 20),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                    "Scheduled Payments",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Spacer(),
                  IconButton(
                    icon: Icon(Icons.add, size: 22, color: Colors.black54),
                    onPressed: () {
                      // TODO: Handle "Add Scheduled Payment"
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      showAllScheduledPayments
                          ? Icons.expand_less
                          : Icons.expand_more,
                      size: 22,
                      color: Colors.black54,
                    ),
                    onPressed: () {
                      setState(() {
                        showAllScheduledPayments = !showAllScheduledPayments;
                      });
                    },
                  ),
                ],
              ),
              SizedBox(height: 10),

              // If empty
              payments.isEmpty
                  ? Center(
                      child: Text(
                        "No Scheduled Payments Yet",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                      ),
                    )
                  : Column(
                      children: paymentsToShow.asMap().entries.map((entry) {
                        return Column(
                          children: [
                            _buildScheduledPaymentTile(entry.value),
                            if (entry.key < paymentsToShow.length - 1)
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
  }

// Single Scheduled Payment tile
  Widget _buildScheduledPaymentTile(ScheduledPayment payment) {
    return InkWell(
      onTap: () {
        // TODO: Implement onTap logic for scheduled payment
        // For example, open payment details or show a dialog.
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          children: [
            // Circle avatar with first letter
            CircleAvatar(
              backgroundColor: Colors.purple[100],
              child: Text(
                payment.name[0],
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.purple),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                payment.name,
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ),
            Text(
              "₹${payment.amount.toStringAsFixed(0)}",
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
  }

  Widget _buildSplits(List<Split> splits) {
    // Fetch the dummy values from MockBackend
    double totalBalance = MockBackend.getTotalBalance();
    double youOwe = MockBackend.getYouOwe();
    double youAreOwed = MockBackend.getYouAreOwed();

    // Show top 3 splits by default
    List<Split> splitsToShow = showAllSplits ? splits : splits.take(3).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: Color(0xFFEDE7F6),
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// **Header Row** (Title, Add, Expand/Collapse)
              Row(
                children: [
                  Text(
                    "Splits",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Spacer(),
                  IconButton(
                    icon: Icon(Icons.add, size: 22, color: Colors.black54),
                    onPressed: () {
                      // TODO: Handle "Add Split" action
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      showAllSplits ? Icons.expand_less : Icons.expand_more,
                      size: 22,
                      color: Colors.black54,
                    ),
                    onPressed: () {
                      setState(() {
                        showAllSplits = !showAllSplits;
                      });
                    },
                  ),
                ],
              ),
              SizedBox(height: 10),

              /// **Three summary "tiles"** in the same style as transactions
              _buildSplitSummaryTile("Total Balance", totalBalance),
              _buildSplitSummaryTile("You owe", youOwe),
              _buildSplitSummaryTile("You are owed", youAreOwed),

              // Divider below summaries
              Divider(color: Colors.grey[300], height: 20),

              // If no splits, show message
              if (splits.isEmpty)
                Center(
                  child: Text(
                    "No Splits Yet",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                )
              else
                // Otherwise, show the split items
                Column(
                  children: splitsToShow.asMap().entries.map((entry) {
                    return Column(
                      children: [
                        _buildSplitTile(entry.value),
                        if (entry.key < splitsToShow.length - 1)
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
  }

  Widget _buildSplitSummaryTile(String label, double amount) {
    bool isNegative = amount < 0;
    Color amountColor = isNegative ? Colors.red : Colors.green;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          // CircleAvatar(
          //   backgroundColor: Colors.purple[100],
          //   child: Text(
          //     label[0].toUpperCase(), // e.g. 'T' for "Total", 'Y' for "You owe"
          //     style: TextStyle(fontWeight: FontWeight.bold, color: Colors.purple),
          //   ),
          // ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ),
          Text(
            "₹${amount.abs().toStringAsFixed(0)}", // abs() to remove minus sign
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: amountColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSplitTile(Split split) {
    bool isNegative = split.amount < 0;
    Color amountColor = isNegative ? Colors.red : Colors.green;

    return InkWell(
      onTap: () {
        // TODO: Implement onTap logic for each split (e.g., show detail view)
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.purple[100],
              child: Text(
                split.name[0],
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.purple),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                split.name,
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ),
            Text(
              "₹${split.amount.abs().toStringAsFixed(0)}",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: amountColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudget(List<BudgetCategory> categories) {
    // 1) Get the overall budget
    double overallBudget = MockBackend.getOverallBudget();

    // 2) Show top 3 categories by default
    List<BudgetCategory> categoriesToShow =
        showAllBudgetCategories ? categories : categories.take(3).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 18),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: Color(0xFFEDE7F6),
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// **Header**: "Budget", plus icon, expand icon
              Row(
                children: [
                  Text(
                    "Budget",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Spacer(),
                  IconButton(
                    icon: Icon(Icons.add, size: 22, color: Colors.black54),
                    onPressed: () {
                      // TODO: Handle "Add Budget Category" action
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      showAllBudgetCategories
                          ? Icons.expand_less
                          : Icons.expand_more,
                      size: 22,
                      color: Colors.black54,
                    ),
                    onPressed: () {
                      setState(() {
                        showAllBudgetCategories = !showAllBudgetCategories;
                      });
                    },
                  ),
                ],
              ),
              SizedBox(height: 10),

              /// **Overall Budget** row
              _buildBudgetTile("Overall Budget", overallBudget),

              // Divider below the summary row
              Divider(color: Colors.grey[300], height: 20),

              // If no categories, show "No Budget Yet"
              if (categories.isEmpty)
                Center(
                  child: Text(
                    "No Budget Yet",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                )
              else
                // Otherwise, list the categories
                Column(
                  children: categoriesToShow.asMap().entries.map((entry) {
                    return Column(
                      children: [
                        _buildBudgetCategoryTile(entry.value),
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
  }

  Widget _buildBudgetTile(String label, double amount) {
    // bool isNegative = amount < 0;
    // Color amountColor = isNegative ? Colors.red : Colors.green;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          // Circle avatar with first letter
          // CircleAvatar(
          //   backgroundColor: Colors.purple[100],
          //   child: Text(
          //     label[0].toUpperCase(), // e.g. "O" for "Overall"
          //     style: TextStyle(fontWeight: FontWeight.bold, color: Colors.purple),
          //   ),
          // ),
          SizedBox(width: 12),

          // Label
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ),

          // Amount
          Text(
            "₹${amount.abs().toStringAsFixed(0)}",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetCategoryTile(BudgetCategory category) {
    return InkWell(
      onTap: () {
        // TODO: Implement onTap logic for each budget category
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          children: [
            // Circle avatar with emoji
            CircleAvatar(
              backgroundColor: Colors.redAccent.withOpacity(0.1),
              child: Text(
                category.emoji,
                style: TextStyle(fontSize: 18),
              ),
            ),
            SizedBox(width: 12),

            // Category Name
            Expanded(
              child: Text(
                category.name,
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ),

            // Amount (green if positive, red if negative)
            Text(
              "₹${category.amount.abs().toStringAsFixed(0)}",
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
          ],
        ),
      ),
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
          // TODO: Navigate to Home Page
        } else if (index == 1) {
          // Already on Categories/Tran sactions page
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CategoriesPage(),
            ),
          );
        } else if (index == 2) {
          // TODO: Navigate to Analytics Page
        } else if (index == 3) {
          // TODO: Navigate to Split Page
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ManageSplitsPage(),
            ),
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
}

/// Custom ArcPainter to draw the circular progress indicator.
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

    canvas.drawArc(
      Rect.fromCircle(center: size.center(Offset.zero), radius: size.width / 2),
      0,
      2 * pi,
      false,
      trackPaint,
    );
    canvas.drawArc(
      Rect.fromCircle(center: size.center(Offset.zero), radius: size.width / 2),
      -pi / 2,
      2 * pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Models

/// Remove the local Transaction model

/// Category Model
class CategoryItem {
  final String emoji;
  final String name;
  final double amount;

  CategoryItem(this.emoji, this.name, this.amount);
}

class ScheduledPayment {
  final String name;
  final double amount;

  ScheduledPayment(this.name, this.amount);
}

class Split {
  final String name;
  final double amount;

  Split(this.name, this.amount);

    factory Split.fromMap(Map<String, dynamic> map) {
    return Split(
      map['name'] as String,
      (map['amount'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'amount': amount,
      'isSettled': isSettled,
    };
  }

  bool get isSettled => amount == 0;  // Calculated property
}

class BudgetCategory {
  final String emoji;
  final String name;
  final double amount;

  BudgetCategory(this.emoji, this.name, this.amount);
}

/// Backend
class MockBackend {
  static List<Transaction> getTransactions(BuildContext context) {
    return [
      Transaction(name: "Sourav das", amount: -5000, date: DateFormat('yyyy-MM-dd').format(DateTime.now()), time: TimeOfDay.now().format(context)),
      Transaction(name: "Darshan", amount: -510, date: DateFormat('yyyy-MM-dd').format(DateTime.now()), time: TimeOfDay.now().format(context)),
      Transaction(name: "Anjali Patra", amount: 1200, date: DateFormat('yyyy-MM-dd').format(DateTime.now()), time: TimeOfDay.now().format(context)),
      Transaction(name: "Extra Transaction", amount: -200, date: DateFormat('yyyy-MM-dd').format(DateTime.now()), time: TimeOfDay.now().format(context)),
    ];
  }

  /// Dummy function to return the total spent amount.
  static double getTotalSpent() {
    return 600; // Dummy total spent value
  }

  /// Dummy categories
  static List<CategoryItem> getCategories() {
    return [
      CategoryItem("🍔", "Food and Drinks", 1000),
      CategoryItem("🛍️", "Shopping", 510),
      CategoryItem("🎮", "Electronics", 200),
      CategoryItem("🎮", "Ress", 221),
    ];
  }

  static List<ScheduledPayment> getScheduledPayments() {
    return [
      ScheduledPayment("Chetan Singh", 50),
      ScheduledPayment("Darshan", 510),
      ScheduledPayment("Anjali Patra", 1200),
      ScheduledPayment("Darshan", 1000),
    ];
  }

  static List<Split> getSplits() {
    return [
      Split("Chetan Singh", 50),
      Split("Darshan", -510),
      Split("Anjali Patra", 1200),
      Split("Aujasvit", -20)
      // Add more splits if needed
    ];
  }

  // Dummy methods returning fixed values
  static double getTotalBalance() => 1200; // e.g., ₹1200
  static double getYouOwe() => 600; // e.g., ₹600
  static double getYouAreOwed() => -1800; // e.g., ₹1800

  static double getOverallBudget() {
    return 7000; // e.g. ₹7000
  }

  static List<BudgetCategory> getBudgetCategories() {
    return [
      BudgetCategory("🍔", "Food and Drinks", 1000),
      BudgetCategory("🛍️", "Shopping", 510),
      BudgetCategory("🎮", "Electronics", 200),
      BudgetCategory("🎮", "Ress", 221),
      // Add more if needed
    ];
  }
}
