import 'dart:math';
import 'package:brokeo/frontend/home_pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Home Page
class TransactionPage extends StatefulWidget {
  final String name;
  final double budget;
  TransactionPage({required this.name, required this.budget});

  @override
  _TransactionPageState createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage>
    with SingleTickerProviderStateMixin {
  int expandedTransactionIndex = -1; // Tracks which transaction is expanded
  int _currentIndex = 1; // Set the initial index to Transactions tab
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    String daysLeft =
        (DateTime(DateTime.now().year, DateTime.now().month + 1, 0).day -
                DateTime.now().day)
            .toString();
    // Get data
    List<Transaction> transactions = MockBackend.getTransactions();
    double totalSpent = MockBackend.getTotalSpent();
    double safeToSpend = (widget.budget - totalSpent) / int.parse(daysLeft);

    return Scaffold(
      backgroundColor: Colors.white,
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              expandedHeight: 130,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Center(
                    child: _buildSafeToSpendSection(totalSpent, safeToSpend)),
              ),
            ),
            SliverPersistentHeader(
              delegate: _SliverAppBarDelegate(
                TabBar(
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
              ),
              pinned: true,
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildTransactions(transactions),
            _buildCategories(),
            _buildMerchants(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index != _currentIndex) {
            setState(() {
              _currentIndex = index;
            });
            if (index == 0) {
              // Home tab index
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => HomePage(
                        name: widget.name,
                        budget: widget.budget)), // Navigate to Home Page
              );
            }
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
          BottomNavigationBarItem(
              icon: Icon(Icons.list), label: "Transactions"),
          BottomNavigationBarItem(
              icon: Icon(Icons.analytics), label: "Analytics"),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: "Split"),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    return Center(child: Text("Categories View"));
  }

  Widget _buildMerchants() {
    return Center(child: Text("Merchants View"));
  }

  /// Profile & Budget Section
  Widget _buildSafeToSpendSection(double spent, double safeToSpend) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 60, horizontal: 15),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Color(0xFFF3E5F5), Colors.white],
          stops: [0.0, 0.5, 1.0],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              Text(
                "Safe to Spend",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Text(
                "₹${safeToSpend.toStringAsFixed(0)}/day",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
          Column(
            children: [
              Text(
                "Amount Spent",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Text(
                "₹${spent.toStringAsFixed(0)}",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Transactions List
  Widget _buildTransactions(List<Transaction> transactions) {
    List<Transaction> transactionsToShow = transactions;

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 20),
      itemCount: transactionsToShow.length,
      itemBuilder: (context, index) {
        return Column(
          children: [
            _transactionTile(transactionsToShow[index], index),
            if (index < transactionsToShow.length - 1)
              Divider(color: Colors.grey[300]),
          ],
        );
      },
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

/// Transaction Model with a dummy getSpent() method.
class Transaction {
  final String name;
  final double amount;
  Transaction(this.name, this.amount);

  /// Dummy function to return a positive spend value.
  /// For now, it returns a fixed dummy value.
  double getSpent() {
    return 100; // Dummy value
  }
}

/// Backend
class MockBackend {
  static List<Transaction> getTransactions() {
    return [
      Transaction("Chetan Singh", -50),
      Transaction("Darshan", -510),
      Transaction("Anjali Patra", 1200),
      Transaction("Extra Transaction", -200),
      Transaction("Extra Transaction", -200),
      Transaction("Extra Transaction", -200),
      Transaction("Extra Transaction", -200),
      Transaction("Extra Transaction", -200),
      Transaction("Extra Transaction", -200),
      Transaction("Extra Transaction", -200),
      Transaction("Extra Transaction", -200),
      Transaction("Extra Transaction", -200),
    ];
  }

  /// Dummy function to return the total spent amount.
  static double getTotalSpent() {
    return 600; // Dummy total spent value
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}