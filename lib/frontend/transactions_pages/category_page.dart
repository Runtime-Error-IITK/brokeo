import 'package:brokeo/backend/models/category.dart';
import 'package:brokeo/backend/models/transaction.dart' show Transaction;
import 'package:brokeo/backend/services/providers/read_providers/merchant_stream_provider.dart';
import 'package:brokeo/backend/services/providers/read_providers/transaction_stream_provider.dart'
    show TransactionFilter, transactionStreamProvider;
import 'package:brokeo/backend/services/providers/write_providers/category_service.dart'
    show categoryServiceProvider;
import 'package:brokeo/frontend/home_pages/home_page.dart';
import 'package:brokeo/frontend/transactions_pages/transaction_detail_page.dart'
    show TransactionDetailPage;
import 'package:flutter/material.dart';
import 'dart:math' hide log;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart' show DateFormat;

class CategoryPage extends ConsumerStatefulWidget {
  final Category category;
  const CategoryPage({super.key, required this.category});

  @override
  CategoryPageState createState() => CategoryPageState();
}

class CategoryPageState extends ConsumerState<CategoryPage> {
  int _currentIndex = 1;
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
          for (var t in filteredTransactions[5]) {
            totalSpends -= t.amount < 0 ? t.amount : 0;
          }
          return Scaffold(
            appBar: buildCustomAppBar(context, totalSpends),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 20),
                  buildBarChart(filteredTransactions),
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
        // Navigation logic based on index:
        if (index == 0) {
          // TODO: Navigate to Home Page
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(),
            ),
          );
        } else if (index == 1) {
          // Already on Categories/Transactions page
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(),
            ),
          );
        } else if (index == 2) {
          // TODO: Navigate to Analytics Page
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(),
            ),
          );
        } else if (index == 3) {
          // TODO: Navigate to Split Page
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(),
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

  Widget buildBarChart(List<List<Transaction>> filteredTransactions) {
    // Example data from backend:

    final Category data = widget.category;
    final currenMonth = DateTime.now().month;
    final List<BarData> chartData =
        filteredTransactions.asMap().entries.map((entry) {
      final int index = entry.key;
      final List<Transaction> monthTransactions = entry.value;
      double totalSpends = 0;

      // Sum the absolute values of debit transactions (assuming debit is negative).
      for (var t in monthTransactions) {
        if (t.amount < 0) {
          totalSpends += -t.amount;
        }
      }

      // Calculate the month corresponding to this entry.
      // If filteredTransactions has 6 elements and the last element (index 5) is the current month,
      // then the number of months ago for this entry is:
      final int monthsAgo = (filteredTransactions.length - 1) - index;
      final DateTime now = DateTime.now();
      // Construct a target date by subtracting the monthsAgo.
      // The DateTime constructor automatically adjusts the year if the month becomes out of range.
      final DateTime targetDate = DateTime(now.year, now.month - monthsAgo);
      // Format the month abbreviation (e.g. "Jan", "Feb", etc.)
      final String label = DateFormat("MMM").format(targetDate);

      return BarData(label: label, value: totalSpends);
    }).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: BarChartWidget(
        data: chartData,
        barColor: Colors.deepPurple,
      ),
    );
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
                _showEditCategoryDialog(context, data);
              },
            ),
          ),
        ),
        // New delete icon inside a circular container
      ],
      elevation: 0,
    );
  }

  void _showEditCategoryDialog(BuildContext context, Category category) {
    final initialBudget = category.budget;
    final initialCategoryName = category.name;
    // Convert the double to a string for the text field
    String budgetValueAsString = initialBudget.toString();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Edit Budget for $initialCategoryName"),
          content: StatefulBuilder(
            builder: (context, setState) {
              String budgetValue = budgetValueAsString; // initial value

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Show the category name as read-only text
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Category: $initialCategoryName",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
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
              onPressed: () async {
                // Only update if the budget field is non-empty.
                if (budgetValueAsString.isNotEmpty) {
                  // Convert the updated budget string back to a double.
                  double? updatedBudget = double.tryParse(budgetValueAsString);
                  if (updatedBudget != null) {
                    // Retrieve the CategoryService instance.
                    final categoryService = ref.read(categoryServiceProvider);
                    if (categoryService == null) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("User not logged in")),
                        );
                      }
                      return;
                    }

                    // Create an updated CloudCategory with the new budget,
                    // preserving the existing category values.
                    final updatedCloudCategory = CloudCategory(
                      // The document ID is used as the categoryId
                      name: widget.category.name,
                      categoryId: widget.category.categoryId,
                      userId: widget.category.userId,
                      // Here, updatedBudget replaces the old budget.
                      // (Assuming your CloudCategory model has a "budget" field.)
                      budget: updatedBudget,
                    );

                    // Call the service to update the category.
                    final result = await categoryService
                        .updateCloudCategory(updatedCloudCategory);
                    if (result != null) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Category updated successfully!")),
                        );
                      }
                    } else {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Failed to update category.")),
                        );
                      }
                    }
                  }
                }
                // Close the dialog.
                Navigator.pop(context);
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
                      name.isNotEmpty ? name.toUpperCase()[0] : "?",
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
                        DateFormat("MMM dd, yyyy, hh:mm ")
                            .format(transaction.date),
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
                  SizedBox(width: 12),
                ],
              ),
            ),
          );
        });
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
              width: 50, // match or slightly exceed barWidth
              child: Text(
                bar.label,
                textAlign: TextAlign.left,
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

class BarData {
  final String label;
  final double value;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is BarData && other.label == label && other.value == value;
  }

  @override
  int get hashCode => label.hashCode ^ value.hashCode;

  BarData({required this.label, required this.value});
}
