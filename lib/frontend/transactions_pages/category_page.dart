import 'package:flutter/material.dart';
import 'package:brokeo/frontend/transactions_pages/categories_page.dart';
import 'dart:math';
import 'package:brokeo/frontend/transactions_pages/transaction_detail_page.dart';
import 'package:brokeo/models/transaction_model.dart'; // <== new import

class CategoryPage extends StatefulWidget {
  final CategoryCardData data;

  const CategoryPage({Key? key, required this.data}) : super(key: key);

  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  int _currentIndex = 1;

  @override
  Widget build(BuildContext context) {
    final CategoryCardData data = widget.data;
    final int totalSpends = DummyDataService.getSpendsCount(data.name);
    List<Transaction> transactions =
        DummyDataService.getTransactions(data.name);
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
      bottomNavigationBar: buildBottomNavigationBar(),
    );
  }

  /// Builds the complete custom AppBar in one function.
  AppBar buildCustomAppBar(BuildContext context, int totalSpends) {
    final data = widget.data;
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
          Icon(
            data.icon,
            color: data.color,
            size: 30,
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
                  "$totalSpends Spends - ₹${data.spent.toStringAsFixed(0)}/₹${data.budget.toStringAsFixed(0)}",
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

  Widget buildBarChart() {
    // Example data from backend:
    final CategoryCardData data = widget.data;
    final chartData = DummyDataService.getBarChartData(data.name);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: BarChartWidget(
        data: chartData,
        barColor: Colors.deepPurple,
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
          // Already on Categories/Transactions page.
        } else if (index == 2) {
          // TODO: Navigate to Analytics Page
        } else if (index == 3) {
          // TODO: Navigate to Split Page
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
                double updatedBudget =
                    double.tryParse(budgetValueAsString) ?? 0.0;

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

class BarChartWidget extends StatelessWidget {
  final List<BarData> data;
  final Color barColor;

  const BarChartWidget({
    Key? key,
    required this.data,
    this.barColor = Colors.deepPurple,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Limit to 5 bars
    final displayData = data.length > 5 ? data.sublist(0, 5) : data;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Chart area with Y-axis and bars
        Container(
          height: 200,
          width: double.infinity,
          child: CustomPaint(
            painter: BarChartPainter(
              bars: displayData,
              barColor: barColor,
              barWidth: 30,
              maxBarHeight: 180, // space for top axis label
            ),
          ),
        ),
        SizedBox(height: 8),
        // X-axis labels
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: displayData.map((bar) {
            return SizedBox(
              width: 40, // match or slightly exceed barWidth
              child: Text(
                bar.label,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.black),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class BarChartPainter extends CustomPainter {
  final List<BarData> bars;
  final Color barColor;
  final double barWidth;
  final double maxBarHeight;

  // We'll draw 5 ticks: 0, 1/4·max, 1/2·max, 3/4·max, max
  static const int horizontalLinesCount = 4;

  BarChartPainter({
    required this.bars,
    required this.barColor,
    this.barWidth = 20,
    this.maxBarHeight = 200,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (bars.isEmpty) return;

    // 1) Determine the maximum value for scaling
    final maxValue = bars.map((b) => b.value).reduce(max);

    // 2) Reserve a right margin for Y-axis labels (40 pixels)
    final double rightMargin = 40;
    final double chartWidth = size.width - rightMargin;

    // 3) Draw horizontal grid lines and Y-axis tick values on the right side
    final linePaint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 1;

    for (int i = 0; i <= horizontalLinesCount; i++) {
      final fraction = i / horizontalLinesCount; // 0, 0.25, 0.5, 0.75, 1.0
      final yValue = fraction * maxValue;
      final yCoord = size.height - (fraction * maxBarHeight);

      // Draw horizontal line across the chart area (from left edge to chartWidth)
      canvas.drawLine(
        Offset(0, yCoord),
        Offset(chartWidth, yCoord),
        linePaint,
      );

      // Draw the tick value on the right side
      final labelText = yValue.round().toString();
      final textSpan = TextSpan(
        text: labelText,
        style: TextStyle(fontSize: 10, color: Colors.black),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textAlign: TextAlign.left,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      // Place the label with a 4px padding from chartWidth
      final offset = Offset(
        chartWidth + 4,
        yCoord - textPainter.height / 2,
      );
      textPainter.paint(canvas, offset);
    }

    // 4) Draw the bars within the chart area (0 to chartWidth)
    final spacing = (chartWidth - (bars.length * barWidth)) / (bars.length + 1);
    final barPaint = Paint()..color = barColor;

    for (int i = 0; i < bars.length; i++) {
      final bar = bars[i];
      final barHeight = (bar.value / maxValue) * maxBarHeight;
      final barLeft = spacing + i * (barWidth + spacing);
      final barTop = size.height - barHeight;
      final barRect = Rect.fromLTWH(barLeft, barTop, barWidth, barHeight);
      canvas.drawRect(barRect, barPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// A stateful widget for the transaction list, including tap-to-expand functionality.

class TransactionListWidget extends StatelessWidget {
  final List<Transaction> transactions;

  const TransactionListWidget({Key? key, required this.transactions})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                        _transactionTile(context, transaction),
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
  Widget _transactionTile(BuildContext context, Transaction transaction) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TransactionDetailPage(transaction: transaction),
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
                transaction.name.isNotEmpty
                    ? transaction.name[0].toUpperCase()
                    : "?",
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
                transaction.name,
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ),

            // Date/Time + Amount
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "${transaction.date}, ${transaction.time}",
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
  }
}

class BarData {
  final String label;
  final double value;

  BarData({required this.label, required this.value});
}

class DummyDataService {
  static int getSpendsCount(String categoryName) {
    return 15;
  }

  static List<String> getCategoriesFromBackend() {
    return ["Food", "Shopping", "Travel", "Others"];
  }

  static List<BarData> getBarChartData(String categoryName) {
    return [
      BarData(label: "Jan", value: 1000),
      BarData(label: "Feb", value: 2000),
      BarData(label: "Mar", value: 1500),
      BarData(label: "Apr", value: 3000),
      BarData(label: "May", value: 2500),
    ];
  }

  // Dummy transaction list for a given category
  static List<Transaction> getTransactions(String categoryName) {
    return [
      Transaction(
          name: "Belgian Waffles",
          amount: 250,
          date: "25 Jan'25",
          time: "11:00 am"),
      Transaction(
          name: "CC Canteen", amount: 200, date: "31 Jan'25", time: "7:00 pm"),
      Transaction(
          name: "CC Canteen", amount: 150, date: "18 Jan'25", time: "2:30 pm"),
      Transaction(
          name: "DOAA Canteen", amount: 100, date: "5 Jan'25", time: "8:00 pm"),
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
  }
}
