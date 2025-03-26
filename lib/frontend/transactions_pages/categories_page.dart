import 'package:brokeo/frontend/home_pages/home_page.dart';
import 'package:brokeo/frontend/split_pages/manage_splits.dart';
import 'package:brokeo/frontend/transactions_pages/category_page.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:brokeo/frontend/transactions_pages/transaction_detail_page.dart';
import 'package:brokeo/models/transaction_model.dart'; // <== new import
import 'package:brokeo/frontend/transactions_pages/merchants_page.dart';

/// Main CategoriesPage
class CategoriesPage extends StatefulWidget {
  @override
  _CategoriesPageState createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage>
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
              child: Icon(Icons.add,
                  color: Colors.white), // Icon color set to white
              backgroundColor: Color.fromARGB(
                  255, 97, 53, 186), // Match the color in the image
              shape: CircleBorder(), // Ensure the shape is circular
            )
          : null,
      bottomNavigationBar: buildBottomNavigationBar(),
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
    final double dailySafeToSpend = DummyDataService.getDailySafeToSpend();
    final double amountSpent = DummyDataService.getAmountSpent();
    final double progress = DummyDataService.getProgress();
    final String currentMonth = "October"; // Dummy current month

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
                "₹${amountSpent.toStringAsFixed(0)}",
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

  /// Builds the donut chart using DonutChartWidget
  Widget buildDonutChart() {
    // In a real app, you'd fetch these from your database.
    // Here, we define some dummy data:
    final rawCategories = DummyDataService.getCategories();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: DonutChartWidget(categories: rawCategories),
    );
  }

  /// Builds a grid of categories (2 columns)..
  Widget buildCategoryGrid() {
    // Example of how you might get data from the backend:
    // final List<CategoryCardData> categories = myBackend.getCategories();

    // For now, dummy data:
    final categories = DummyDataService.getCategoriesData();

    return GridView.builder(
      // Because we are putting this GridView in a ListView,
      // we need to shrink-wrap it and remove the default scrolling.
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
        return buildCategoryCard(cat);
      },
    );
  }

  /// Builds an individual category card (name, icon, spent/budget).
  Widget buildCategoryCard(CategoryCardData data) {
    return GestureDetector(
      onTap: () {
        if (data.name == "Add Category") {
          // show popup
          _showAddCategoryDialog(context);
          // e.g. showDialog(...)
        } else {
          // TODO: Navigate to the category's detail page
          // e.g. Navigator.push(context, MaterialPageRoute(builder: (_) => CategoryDetailPage(data)));
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CategoryPage(data: data),
            ),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: data.color.withOpacity(0.1), // light background tint
          border: Border.all(color: Colors.black, width: 1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Category name
            Text(
              data.name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            // Icon
            Icon(
              data.icon,
              size: 40,
              color: data.color,
            ),
            SizedBox(height: 8),
            // Spent/Budget
            if (data.name != "Add Category")
              Text(
                "₹${data.spent.toStringAsFixed(0)}/₹${data.budget.toStringAsFixed(0)}",
                style: TextStyle(fontSize: 14),
              ),
          ],
        ),
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context) {
    // Example categories from backend (replace with real fetch)
    final List<String> categoriesFromBackend =
        DummyDataService.getCategoriesFromBackend();

    String? selectedCategory;
    String? budgetValue;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Add Category"),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Dropdown for category selection
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    decoration: InputDecoration(
                      labelText: "Category Name",
                    ),
                    items: categoriesFromBackend.map((cat) {
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
                print(
                    "Adding category: $selectedCategory with budget $budgetValue");
                // TODO : Perform the adding process
              },
              child: Text("Confirm"),
            ),
          ],
        );
      },
    );
  }

  void _showAddTransactionDialog(BuildContext context) {
    String? amount;
    String? merchant;
    String? category;

    // TODO: Backend

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Add transaction"),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
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
                  DropdownButtonFormField<String>(
                    value: category,
                    decoration: InputDecoration(
                      labelText: "Category",
                    ),
                    items:
                        DummyDataService.getCategoriesFromBackend().map((cat) {
                      return DropdownMenuItem<String>(
                        value: cat,
                        child: Text(cat),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        category = value;
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
                print("Adding transaction: $amount, $merchant, $category");
                // TODO: Perform the adding process
                Navigator.pop(context); // close dialog
              },
              child: Text("Confirm"),
            ),
          ],
        );
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
        // Navigation logic based on index:
        if (index == 0) {
          // TODO: Navigate to Home Page
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(name: "Darshan", budget: 5000),
            ),
          );
        } else if (index == 1) {
          // Already on Categories/Transactions page
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

  Widget _buildTransactions() {
    List<Transaction> transactions = MockBackend.getTransactions();
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
  }

  Widget _transactionTile(Transaction transaction, int index) {
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
                    transaction.name[0],
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.purple),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.name,
                        style: TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                      Text(
                        "19:30", // Placeholder for time
                        style: TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                    ],
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
        ],
      ),
    );
  }

// Merchant
  Widget _buildMerchants() {
    List<Merchant> merchants = merchantBackend.getMerchants();
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      itemCount: merchants.length,
      itemBuilder: (context, index) {
        return Column(
          children: [
            _merchantTile(merchants[index], index),
            if (index < merchants.length - 1) Divider(color: Colors.grey[300]),
          ],
        );
      },
    );
  }

  Widget _merchantTile(Merchant merchant, int index) {
    merchant.updateAmountSpends();
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MerchantsPage(data: merchant),
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
                        fontWeight: FontWeight.bold, color: Colors.purple),
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
                        "₹${merchant.amount.abs()}",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        merchant.spends.toString(), // Placeholder for time
                        style: TextStyle(fontSize: 12, color: Colors.black54),
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
  }
}

/// DonutChartWidget: draws a donut chart + legend for up to 3 categories + "Others"
class DonutChartWidget extends StatelessWidget {
  final List<CategoryData> categories;

  const DonutChartWidget({Key? key, required this.categories})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Merge categories so that only top 3 remain + "Others" if needed
    final displayCategories = prepareCategories(categories);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // The donut chart
        CustomPaint(
          size: Size(160, 160),
          painter: DonutChartPainter(displayCategories),
        ),
        SizedBox(width: 60),
        // Legend on the right
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: displayCategories.map((cat) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Color bullet
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: cat.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 8),
                  // Category name
                  Text(
                    cat.name,
                    style: TextStyle(fontSize: 14, color: Colors.black),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// If there are more than 3 categories, merges the extras into "Others"
  List<CategoryData> prepareCategories(List<CategoryData> raw) {
    if (raw.length <= 3) {
      return raw;
    }

    // Sort by percentage descending
    final sorted = List<CategoryData>.from(raw)
      ..sort((a, b) => b.percentage.compareTo(a.percentage));

    // Take top 3
    final top3 = sorted.take(3).toList();
    // Sum the rest
    double othersPercentage = 0;
    for (int i = 3; i < sorted.length; i++) {
      othersPercentage += sorted[i].percentage;
    }

    final others = CategoryData(
      name: "Others",
      percentage: othersPercentage,
      color: Colors.grey,
    );

    return [...top3, others];
  }
}

/// The custom painter for drawing the donut chart.
class DonutChartPainter extends CustomPainter {
  final List<CategoryData> categories;

  DonutChartPainter(this.categories);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;

    // We'll draw arcs with a stroke to form a ring.
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10; // ring thickness

    double startRadian = -pi / 2;
    final totalPercent = categories.fold<double>(
      0.0,
      (sum, c) => sum + c.percentage,
    );

    for (var cat in categories) {
      final sweepRadian = (cat.percentage / totalPercent) * 2 * pi;
      paint.color = cat.color;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startRadian,
        sweepRadian,
        false,
        paint,
      );

      startRadian += sweepRadian;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // Repaint if the data changes
    return oldDelegate is DonutChartPainter &&
        oldDelegate.categories != categories;
  }
}

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
class CategoryData {
  final String name;
  final double percentage; // e.g. 40 => 40%
  final Color color;

  CategoryData({
    required this.name,
    required this.percentage,
    required this.color,
  });
}

class CategoryCardData {
  final String name;
  final double spent;
  final double budget;
  final IconData icon;
  final Color color;

  CategoryCardData({
    required this.name,
    required this.spent,
    required this.budget,
    required this.icon,
    required this.color,
  });
}

/// DummyDataService class with static methods to simulate backend calls.
class DummyDataService {
  static double getDailySafeToSpend() => 365.0;
  static double getAmountSpent() => 3028.0;
  static double getProgress() => 0.5; // 50% usage
  static List<CategoryData> getCategories() {
    return [
      CategoryData(name: "Food", percentage: 0.4, color: Colors.red),
      CategoryData(name: "Shopping", percentage: 0.3, color: Colors.blue),
      CategoryData(name: "Travel", percentage: 0.2, color: Colors.green),
      CategoryData(name: "Others", percentage: 0.1, color: Colors.grey),
    ];
  }

  static List<CategoryCardData> getCategoriesData() {
    return [
      CategoryCardData(
        name: "Food",
        spent: 500,
        budget: 1000,
        icon: Icons.fastfood,
        color: Colors.red,
      ),
      CategoryCardData(
        name: "Shopping",
        spent: 300,
        budget: 500,
        icon: Icons.shopping_cart,
        color: Colors.blue,
      ),
      CategoryCardData(
        name: "Travel",
        spent: 200,
        budget: 1000,
        icon: Icons.flight,
        color: Colors.green,
      ),
      CategoryCardData(
        name: "Travel",
        spent: 200,
        budget: 1000,
        icon: Icons.flight,
        color: Colors.green,
      ),
      CategoryCardData(
        name: "Travel",
        spent: 200,
        budget: 1000,
        icon: Icons.flight,
        color: Colors.green,
      ),
      CategoryCardData(
        name: "Travel",
        spent: 200,
        budget: 1000,
        icon: Icons.flight,
        color: Colors.green,
      ),
      CategoryCardData(
        name: "Add Category",
        spent: 0,
        budget: 0,
        icon: Icons.add,
        color: Colors.grey,
      ),
    ];
  }

  static List<String> getCategoriesFromBackend() {
    return ["Food", "Shopping", "Travel", "Others"];
  }
}

/// Backend
class MockBackend {
  static List<Transaction> getTransactions() {
    return [
      Transaction(
          name: "Chetan Singh",
          amount: -50,
          date: "25 Jan'25",
          time: "11:00 am"),
      Transaction(
          name: "Darshan", amount: -510, date: "24 Jan'25", time: "10:00 am"),
      Transaction(
          name: "Anjali Patra",
          amount: 1200,
          date: "23 Jan'25",
          time: "09:00 am"),
      Transaction(
          name: "Extra Transaction",
          amount: -200,
          date: "22 Jan'25",
          time: "08:00 am"),
<<<<<<< HEAD
=======
    ];
  }
}

/// Merchant Backend - TODO: Link to original backend and integrate functionalities
class Merchant {
  String id = "123456789";
  String name = "sample";
  String alaisname = "sample";
  String category = "Others";
  List<Transaction> transactions = [
    Transaction(
        name: "CC Canteen", amount: 200, date: "31 Jan'25", time: "7:00 pm"),
    Transaction(
        name: "CC Canteen", amount: 150, date: "18 Jan'25", time: "2:30 pm"),
    Transaction(
        name: "CC Canteen", amount: 300, date: "20 Dec'24", time: "5:00 pm"),
    Transaction(
        name: "CC Canteen", amount: 300, date: "20 Dec'24", time: "5:00 pm"),
    Transaction(
        name: "CC Canteen", amount: 300, date: "20 Dec'24", time: "5:00 pm"),
    Transaction(
        name: "CC Canteen", amount: 300, date: "20 Dec'24", time: "5:00 pm"),
    Transaction(
        name: "CC Canteen", amount: 300, date: "20 Dec'24", time: "5:00 pm"),
    Transaction(
        name: "CC Canteen", amount: 300, date: "20 Dec'24", time: "5:00 pm"),
    Transaction(
        name: "CC Canteen", amount: 300, date: "20 Dec'24", time: "5:00 pm"),
    Transaction(
        name: "CC Canteen", amount: 300, date: "20 Dec'24", time: "5:00 pm"),
    Transaction(
        name: "CC Canteen", amount: 300, date: "20 Dec'24", time: "5:00 pm"),
  ];
  double amount = 0;
  int spends = 0;

  void updateAmountSpends() {
    spends = 0;
    amount = 0.0;
    Transaction trans;
    for (trans in transactions) {
      spends = spends + 1;
      amount = amount + trans.amount;
    }
  }

  void addTransactions(Transaction trans) {
    transactions.add(trans);
    updateAmountSpends();
  }

  Merchant(String id, String name, String? cat) {
    this.id = id;
    this.name = name;
    this.category = cat ?? this.category;
    this.alaisname = name;
  }
}

class merchantBackend {
  static List<Merchant> getMerchants() {
    return [
      Merchant("1230ABCD", "CC Canteen", null),
      Merchant("1231ABCD", "Hall 12 Canteen", null),
      Merchant("1232ABCD", "Z Square", null),
      Merchant("1234ABCD", "New Merchant", null)
      // Add more if needed
>>>>>>> 9ba5146b386dd15de316f75963f309ecc6691af6
    ];
  }
}
