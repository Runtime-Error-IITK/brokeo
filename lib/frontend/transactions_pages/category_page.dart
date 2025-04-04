import 'dart:developer';
import 'package:brokeo/backend/models/category.dart';
import 'package:brokeo/backend/models/transaction.dart' show Transaction;
import 'package:brokeo/backend/services/providers/read_providers/merchant_stream_provider.dart';
import 'package:brokeo/backend/services/providers/read_providers/transaction_stream_provider.dart'
    show TransactionFilter, transactionStreamProvider;
import 'package:brokeo/backend/services/providers/read_providers/category_stream_provider.dart'
    show CategoryFilter, categoryStreamProvider;
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
  final String categoryId;
  const CategoryPage({Key? key, required this.categoryId}) : super(key: key);

  @override
  CategoryPageState createState() => CategoryPageState();
}

class CategoryPageState extends ConsumerState<CategoryPage> {
  int _currentIndex = 1;

  @override
  Widget build(BuildContext context) {
    // Watch the category stream for the specific categoryId.
    final asyncCategory = ref.watch(
      categoryStreamProvider(CategoryFilter(categoryId: widget.categoryId)),
    );

    return asyncCategory.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: $error")),
          );
        });
        return const SizedBox.shrink();
      },
      data: (categories) {
        if (categories.isEmpty) {
          return const Center(child: Text("Category not found"));
        }
        // Get the updated category.
        final category = categories.first;
        final transactionFilter =
            TransactionFilter(categoryId: category.categoryId);
        final asyncTransactions =
            ref.watch(transactionStreamProvider(transactionFilter));

        return asyncTransactions.when(
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
            final now = DateTime.now();
            final List<List<Transaction>> filteredTransactions = [];

            // Build monthly filtered transactions (last 6 months)
            for (int i = 4; i >= 0; i--) {
              final month = DateTime(now.year, now.month - i);
              final monthTransactions = transactions.where((transaction) {
                return transaction.date.year == month.year &&
                    transaction.date.month == month.month;
              }).toList();
              filteredTransactions.add(monthTransactions);
            }
            double totalSpends = 0;
            for (var t in filteredTransactions[4]) {
              totalSpends -= t.amount < 0 ? t.amount : 0;
            }
            return Scaffold(
              appBar: buildCustomAppBar(context, totalSpends, category),
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    buildBarChart(filteredTransactions),
                    const SizedBox(height: 10),
                    TransactionListWidget(transactions: transactions),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  PreferredSizeWidget buildCustomAppBar(
      BuildContext context, double totalSpends, Category category) {
    return AppBar(
      backgroundColor: const Color.fromARGB(255, 243, 225, 247),
      iconTheme: const IconThemeData(color: Colors.black),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Category icon
          Image.asset(
            'assets/category_icon/${category.name}.jpg',
            width: 40,
            height: 40,
            fit: BoxFit.cover,
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  "$totalSpends Spends - ₹${totalSpends.toStringAsFixed(0)}/₹${category.budget.toStringAsFixed(0)}",
                  style: const TextStyle(
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
        // Edit icon to change the budget.
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black54.withOpacity(0.2),
            ),
            child: IconButton(
              icon: const Icon(Icons.edit, color: Colors.white),
              onPressed: () {
                _showEditCategoryDialog(context, category);
              },
            ),
          ),
        ),
      ],
      elevation: 0,
    );
  }

  void _showEditCategoryDialog(BuildContext context, Category category) {
    final initialBudget = category.budget;
    final initialCategoryName = category.name;
    String budgetValueAsString = initialBudget.toString();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Wrap the entire AlertDialog in a StatefulBuilder so that both the text field and the buttons can react to state changes.
        return StatefulBuilder(
          builder: (context, setState) {
            // Use a local variable for the current value of the budget text field.
            String budgetValue = budgetValueAsString;
            // Determine if the current budget value is valid (non-empty and can be parsed to a double).
            final bool isBudgetValid =
                budgetValue.isNotEmpty && double.tryParse(budgetValue) != null;

            return AlertDialog(
              title: Text("Edit Budget for $initialCategoryName"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Category: $initialCategoryName",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: budgetValue,
                    decoration: const InputDecoration(
                      labelText: "Budget",
                      prefixText: "₹",
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        budgetValue = value;
                        budgetValueAsString = value;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                TextButton(
                  // Disable the Confirm button if the budget value is empty or invalid.
                  onPressed: isBudgetValid
                      ? () async {
                          double? updatedBudget = double.tryParse(budgetValue);
                          if (updatedBudget != null) {
                            final categoryService =
                                ref.read(categoryServiceProvider);
                            if (categoryService == null) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text("User not logged in")),
                                );
                              }
                              return;
                            }
                            log(updatedBudget.toString());
                            final updatedCloudCategory = CloudCategory(
                              name: category.name,
                              categoryId: category.categoryId,
                              userId: category.userId,
                              budget: updatedBudget,
                            );

                            final result = await categoryService
                                .updateCloudCategory(updatedCloudCategory);
                            if (result != null) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          "Category updated successfully!")),
                                );
                              }
                            } else {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text("Failed to update category.")),
                                );
                              }
                            }
                          }
                          Navigator.pop(context);
                        }
                      : null,
                  child: const Text("Confirm"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget buildBarChart(List<List<Transaction>> filteredTransactions) {
    final List<BarData> chartData =
        filteredTransactions.asMap().entries.map((entry) {
      final int index = entry.key;
      final List<Transaction> monthTransactions = entry.value;
      double totalSpends = 0;

      for (var t in monthTransactions) {
        if (t.amount < 0) {
          totalSpends -= t.amount;
        }
      }

      final int monthsAgo = (filteredTransactions.length - 2) - index;
      final DateTime now = DateTime.now();
      final DateTime targetDate = DateTime(now.year, now.month - monthsAgo);
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
}

// The remainder of your widgets (TransactionListWidget, BarChartWidget, etc.) can remain unchanged.

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
    final double validAmount =
        (transaction.amount.isNaN) ? 0.0 : transaction.amount;
    final Color amountColor = validAmount < 0 ? Colors.red : Colors.green;

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
                        "₹${validAmount.abs().toStringAsFixed(0)}",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: amountColor,
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

  // We'll draw 4 horizontal grid lines.
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

    // 1) Determine the maximum value for scaling.
    final double maxValue = bars.map((b) => b.value).reduce(max);

    // 2) Reserve a right margin for Y-axis labels (40 pixels)
    final double rightMargin = 40;
    final double chartWidth = size.width - rightMargin;

    // 3) Draw horizontal grid lines and Y-axis tick values on the right side
    final linePaint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 1;

    // Even if maxValue is zero, these lines will show 0.
    for (int i = 0; i <= horizontalLinesCount; i++) {
      final fraction = i / horizontalLinesCount; // 0, 0.25, 0.5, 0.75, 1.0
      final yValue = fraction * maxValue;
      final yCoord = size.height - (fraction * maxBarHeight);

      canvas.drawLine(
        Offset(0, yCoord),
        Offset(chartWidth, yCoord),
        linePaint,
      );

      // Draw tick value (will be "0" if maxValue is zero)
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
      // If maxValue is zero, use 0 height; otherwise, calculate normally.
      final double barHeight =
          maxValue == 0 ? 0 : (bar.value / maxValue) * maxBarHeight;
      final double barLeft = spacing + i * (barWidth + spacing);
      final double barTop = size.height - barHeight;
      final Rect barRect = Rect.fromLTWH(barLeft, barTop, barWidth, barHeight);
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
