import 'package:brokeo/backend/models/merchant.dart' show Merchant;
import 'package:brokeo/backend/models/transaction.dart' show Transaction;
import 'package:brokeo/backend/services/providers/read_providers/merchant_stream_provider.dart';
import 'package:brokeo/backend/services/providers/read_providers/transaction_stream_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:brokeo/frontend/transactions_pages/transaction_detail_page.dart';
import 'package:brokeo/frontend/home_pages/home_page.dart';
import 'package:brokeo/frontend/transactions_pages/categories_page.dart';
import 'package:brokeo/frontend/split_pages/manage_splits.dart';
import 'package:brokeo/frontend/analytics_pages/analytics_page.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart' show DateFormat;

class MerchantsPage extends ConsumerStatefulWidget {
  final String merchantId;

  const MerchantsPage({super.key, required this.merchantId});

  @override
  _MerchantsPageState createState() => _MerchantsPageState();
}

class _MerchantsPageState extends ConsumerState<MerchantsPage> {
  int _currentIndex = 1;

  @override
  Widget build(BuildContext context) {
    final transactionFilter = TransactionFilter(merchantId: widget.merchantId);

    final merchantFilter = MerchantFilter(
      merchantId: widget.merchantId,
    );
    final asyncMerchant = ref.watch(merchantStreamProvider(merchantFilter));

    final asyncTransactions =
        ref.watch(transactionStreamProvider(transactionFilter));

    return asyncMerchant.when(
      loading: () => Center(child: CircularProgressIndicator()),
      error: (error, stack) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: $error")),
          );
        });
        return const SizedBox.shrink();
      },
      data: (merchant) {
        return asyncTransactions.when(
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

            int totalSpends = 0;
            double totalAmount = 0.0;
            for (var transaction in transactions) {
              totalAmount += transaction.amount < 0
                  ? transaction.amount * -1
                  : transaction.amount;

              if (transaction.amount < 0) {
                totalSpends++;
              }
            }

            return Scaffold(
              appBar: buildCustomAppBar(
                  context, totalSpends, totalAmount, merchant[0]),
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
          },
        );
      },
    );
  }

  /// Builds the complete custom AppBar in one function.
  AppBar buildCustomAppBar(BuildContext context, int totalSpends,
      double totalAmount, Merchant merchant) {
    // final data = widget.data;

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
          SizedBox(width: 20), // Extra spacing between the icon and the text
          // Texts in a Column to the right of the icon
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  merchant.name,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // Text(
                //   merchant.categoryId,
                //   style: TextStyle(
                //     color: Colors.black,
                //     fontSize: 16,
                //     fontWeight: FontWeight.bold,
                //   ),
                // ),
                Text(
                  "$totalSpends Spends - ₹$totalAmount",
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      // actions: [
      //   // Edit icon inside a circular container
      //   Padding(
      //     padding: const EdgeInsets.only(right: 8.0),
      //     child: Container(
      //       decoration: BoxDecoration(
      //         shape: BoxShape.circle,
      //         color: Colors.black54.withOpacity(0.2),
      //       ),
      //       child: IconButton(
      //         icon: Icon(Icons.edit, color: Colors.white),
      //         onPressed: () {
      //           // TODO: Add logic to edit category details.
      //           _showEditCategoryDialog(
      //               context, merchant.name // e.g., "Food and Drinks"
      //               // data.category, // e.g., "4000"
      //               );
      //         },
      //       ),
      //     ),
      //   ),
      //   // New delete icon inside a circular container
      //   Padding(
      //     padding: const EdgeInsets.only(right: 8.0),
      //     child: IconButton(
      //       icon: Icon(Icons.delete, color: Colors.red),
      //       onPressed: () {
      //         // TODO: Add logic to delete category details.
      //         _showDeleteConfirmationDialog(context, widget.data.name);
      //       },
      //     ),
      //   ),
      // ],

      elevation: 0,
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

      final int monthsAgo = (filteredTransactions.length - 1) - index;
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
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => ManageSplitsPage()),
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

  // void _showDeleteConfirmationDialog(
  //     BuildContext context, String merchantName) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: Text("Delete Merchant"),
  //         content:
  //             Text("Are you sure you want to delete merchant $merchantName?"),
  //         actions: [
  //           TextButton(
  //             onPressed: () => Navigator.pop(context), // close dialog
  //             child: Text(
  //               "Cancel",
  //               style: TextStyle(color: Colors.black),
  //             ),
  //           ),
  //           TextButton(
  //             onPressed: () {
  //               // TODO: Implement actual delete logic here
  //               Navigator.pop(context); // close dialog
  //             },
  //             child: Text(
  //               "Delete",
  //               style: TextStyle(color: Colors.red),
  //             ),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  // void _showEditCategoryDialog(
  //   BuildContext context,
  //   String initialMerchantName,
  //   String initialCategory, // double
  // ) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: Text("Edit Merchant"),
  //         content: StatefulBuilder(
  //           builder: (context, setState) {
  //             String? selectedMerchant = initialMerchantName;
  //             String? categoryValue = initialCategory; // Start with the string

  //             return Column(
  //               mainAxisSize: MainAxisSize.min,
  //               children: [
  //                 // TextField for budget input
  //                 TextFormField(
  //                   initialValue: selectedMerchant,
  //                   decoration: InputDecoration(
  //                     labelText: "Merchant",
  //                   ),
  //                   keyboardType: TextInputType.name,
  //                   onChanged: (value) {
  //                     setState(() {
  //                       selectedMerchant = value;
  //                       initialMerchantName = value; //?? initialMerchantName;
  //                     });
  //                   },
  //                 ),
  //                 SizedBox(height: 16),
  //                 DropdownButtonFormField<String>(
  //                   value: categoryValue,
  //                   decoration: InputDecoration(labelText: "Category Name"),
  //                   items:
  //                       DummyDataService.getCategoriesFromBackend().map((cat) {
  //                     return DropdownMenuItem<String>(
  //                       value: cat,
  //                       child: Text(cat),
  //                     );
  //                   }).toList(),
  //                   onChanged: (value) {
  //                     setState(() {
  //                       categoryValue = value;
  //                     });
  //                   },
  //                 ),
  //               ],
  //             );
  //           },
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () => Navigator.pop(context), // just close
  //             child: Text("Cancel"),
  //           ),
  //           TextButton(
  //             onPressed: () {
  //               // Convert the updated budget string back to a double
  //               // (handle parsing errors as needed)
  //               // TODO: Perform the update logic here
  //               // e.g., print("Updating category: $selectedCategory with budget $updatedBudget");
  //               Navigator.pop(context); // close dialog
  //             },
  //             child: Text("Confirm"),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }
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
    final double rightMargin = 10;
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

/// A stateful widget for the transaction list, including tap-to-expand functionality.

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

class BarData {
  final String label;
  final double value;

  BarData({required this.label, required this.value});
}

// class DummyDataService {
//   static int getSpendsCount(String categoryName) {
//     return 15;
//   }

//   static List<String> getCategoriesFromBackend() {
//     return ["Food", "Shopping", "Travel", "Others"];
//   }

//   static List<BarData> getBarChartData(String categoryName) {
//     return [
//       BarData(label: "Jan", value: 1000),
//       BarData(label: "Feb", value: 2000),
//       BarData(label: "Mar", value: 1500),
//       BarData(label: "Apr", value: 3000),
//       BarData(label: "May", value: 2500),
//     ];
//   }

//   // Dummy transaction list for a given category
//   static List<Transaction> getTransactions(String categoryName) {
//     return [
//       Transaction(
//           name: "Belgian Waffles",
//           amount: 250,
//           date: "25 Jan'25",
//           time: "11:00 am"),
//       Transaction(
//           name: "CC Canteen", amount: 200, date: "31 Jan'25", time: "7:00 pm"),
//       Transaction(
//           name: "CC Canteen", amount: 150, date: "18 Jan'25", time: "2:30 pm"),
//       Transaction(
//           name: "DOAA Canteen", amount: 100, date: "5 Jan'25", time: "8:00 pm"),
//       Transaction(
//           name: "CC Canteen", amount: 300, date: "20 Dec'24", time: "5:00 pm"),
//       Transaction(
//           name: "CC Canteen", amount: 300, date: "20 Dec'24", time: "5:00 pm"),
//       Transaction(
//           name: "CC Canteen", amount: 300, date: "20 Dec'24", time: "5:00 pm"),
//       Transaction(
//           name: "CC Canteen", amount: 300, date: "20 Dec'24", time: "5:00 pm"),
//       Transaction(
//           name: "CC Canteen", amount: 300, date: "20 Dec'24", time: "5:00 pm"),
//       Transaction(
//           name: "CC Canteen", amount: 300, date: "20 Dec'24", time: "5:00 pm"),
//       Transaction(
//           name: "CC Canteen", amount: 300, date: "20 Dec'24", time: "5:00 pm"),
//       Transaction(
//           name: "CC Canteen", amount: 300, date: "20 Dec'24", time: "5:00 pm"),
//       Transaction(
//           name: "CC Canteen", amount: 300, date: "20 Dec'24", time: "5:00 pm"),
//     ];
//   }
// }
