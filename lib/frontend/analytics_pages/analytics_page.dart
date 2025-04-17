import 'dart:developer' show log;

import 'package:brokeo/backend/models/transaction.dart' show Transaction;
import 'package:brokeo/backend/services/providers/read_providers/transaction_stream_provider.dart'
    show TransactionFilter, transactionStreamProvider;
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:brokeo/frontend/home_pages/home_page.dart' as brokeo_home;
import 'package:brokeo/frontend/transactions_pages/categories_page.dart';
import 'package:brokeo/frontend/split_pages/manage_splits.dart';

class AnalyticsPage extends ConsumerStatefulWidget {
  @override
  _AnalyticsPageState createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends ConsumerState<AnalyticsPage> {
  int _currentIndex = 2;
  String _selectedFilter = 'Daily';
  final List<String> _filters = ['Daily', 'Weekly', 'Monthly'];
  @override
  Widget build(BuildContext context) {
    final filter = createRecentTransactionFilter();
    final asyncTransactions = ref.watch(transactionStreamProvider(filter));

    return asyncTransactions.when(
      loading: () => Center(child: CircularProgressIndicator()),
      error: (error, stack) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Category error: $error")),
          );
        });
        return SizedBox.shrink();
      },
      data: (transactions) {
        final data = aggregateTransactionData(transactions);
        final currentData = data[_selectedFilter]!;
        final dates = currentData['dates'] as List<DateTime>;
        final spendsNum = currentData['spends'] as List<num>;
        final receivedNum = currentData['received'] as List<num>;
        final spends = spendsNum.map((e) => e.toDouble()).toList();
        final received = receivedNum.map((e) => e.toDouble()).toList();
        final labels = _generateLabels(dates);

        // log(currentData.toString());
        bool allZero = true;
        for (var curr in currentData["spends"]) {
          if (curr > 0) allZero = false;
        }

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                automaticallyImplyLeading: false,
                title: Container(
                  width: 100,
                  decoration: BoxDecoration(
                    color: Colors.purple.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedFilter,
                    underline: SizedBox(),
                    dropdownColor: Theme.of(context).scaffoldBackgroundColor,
                    items: _filters.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Center(
                          child: Text(
                            value,
                            style: const TextStyle(color: Colors.black),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (newValue) =>
                        setState(() => _selectedFilter = newValue!),
                  ),
                ),
                actions: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.purple.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.ios_share),
                      onPressed: () => _exportToCSV(currentData, dates),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: SizedBox(),
                  ),
                ],
              ),
              SliverList(
                delegate: SliverChildListDelegate(
                  [
                    Column(
                      children: [
                        _buildChartSection(
                          title: 'Spends Overview',
                          child: Container(
                            width: double.infinity,
                            height: 300,
                            padding: EdgeInsets.only(bottom: 20),
                            child: allZero
                                ? Center(
                                    child: Text(
                                      'No transactions available',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  )
                                : BarChart(
                                    spends: spends,
                                    labels: labels,
                                    maxValue:
                                        spends.reduce((a, b) => a > b ? a : b),
                                  ),
                          ),
                        ),
                        _buildChartSection(
                          title: 'Cash Flow',
                          child: Container(
                            height: 300,
                            padding: EdgeInsets.only(bottom: 20),
                            child: allZero
                                ? Center(
                                    child: Text(
                                      'No transactions available',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  )
                                : LineChart(
                                    spends: spends,
                                    received: received,
                                    labels: labels,
                                    maxValue: [...spends, ...received]
                                        .reduce((a, b) => a > b ? a : b),
                                  ),
                          ),
                          legend: _buildLegend(),
                        ),
                        SizedBox(height: 20),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<String> _generateLabels(List<DateTime> dates) {
    if (_selectedFilter == 'Monthly') {
      return dates.map((d) => DateFormat("MMM'yy").format(d)).toList();
    } else if (_selectedFilter == 'Weekly') {
      return List.generate(dates.length, (i) {
        final start = dates[i];
        final end = start.add(Duration(days: 6));
        final startMonth = DateFormat("MMM'yy").format(start);
        final endMonth = DateFormat("MMM'yy").format(end);
        final range =
            '${DateFormat('dd').format(start)}-${DateFormat('dd').format(end)}';
        return startMonth == endMonth
            ? '$range $startMonth'
            : '$range $startMonth/$endMonth';
      });
    } else {
      return dates.map((d) {
        final day = DateFormat('dd').format(d);
        final month = DateFormat("MMM'yy").format(d);
        return '$day $month';
      }).toList();
    }
  }

  Widget _buildChartSection({
    required String title,
    required Widget child,
    Widget? legend,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),
                  child,
                ],
              ),
              if (legend != null)
                Positioned(
                  top: 0,
                  right: 0,
                  child: legend,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildLegendItem(Colors.red, 'Spent'),
        SizedBox(width: 10),
        _buildLegendItem(Colors.green, 'Received'),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      children: [
        Container(width: 16, height: 16, color: color),
        SizedBox(width: 8),
        Text(text, style: TextStyle(fontSize: 14)),
      ],
    );
  }

  void _exportToCSV(Map<String, dynamic> data, List<DateTime> dates) async {
    final csvData = StringBuffer();
    csvData.writeln('Date,Spent,Received');
    for (int i = 0; i < dates.length; i++) {
      csvData.writeln('${_generateLabels([dates[i]]).first},'
          '${data['spends']![i]},'
          '${data['received']![i]}');
    }
    await Share.shareXFiles(
      [
        XFile.fromData(Uint8List.fromList(csvData.toString().codeUnits),
            mimeType: 'text/csv', name: 'analytics.csv')
      ],
      subject: 'Analytics Data',
    );
  }

  Widget _buildBottomNavigationBar() {
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
            MaterialPageRoute(
              builder: (context) => brokeo_home.HomePage(),
            ),
          );
        } else if (index == 1) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => CategoriesPage(),
            ),
          );
        } else if (index == 2) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => AnalyticsPage(),
            ),
          );
        } else if (index == 3) {
          Navigator.pushReplacement(
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

class BarChart extends StatelessWidget {
  final List<double> spends;
  final List<String> labels;
  final double maxValue;

  const BarChart(
      {super.key,
      required this.spends,
      required this.labels,
      required this.maxValue});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter:
          _BarChartPainter(spends: spends, labels: labels, maxValue: maxValue),
    );
  }
}

class _BarChartPainter extends CustomPainter {
  final List<double> spends;
  final List<String> labels;
  final double maxValue;

  _BarChartPainter(
      {required this.spends, required this.labels, required this.maxValue});

  @override
  void paint(Canvas canvas, Size size) {
    const yAxisOffset = 40.0; // Space for Y-axis values
    const barPadding = 10.0; // Padding between bars
    final barWidth =
        (size.width - yAxisOffset - (barPadding * (spends.length - 1))) /
            spends.length *
            0.95; // Adjusted bar width
    final scaleY = (size.height * 0.8) / maxValue; // Adjusted space for labels
    final textStyle = TextStyle(
        color: Colors.black,
        fontSize: 9); // Consistent font size for date labels
    final secondLineTextStyle = TextStyle(
        color: Colors.black,
        fontSize: 7); // Consistent font size for second line
    final yAxisTextStyle = TextStyle(
        color: Colors.black,
        fontSize: 9); // Consistent font size for Y-axis labels

    // Draw Y-axis labels and grid lines
    final yDivisions = 5;
    for (int i = 0; i <= yDivisions; i++) {
      final yValue = maxValue / yDivisions * i;
      final y = size.height - (yValue * scaleY) - 20;
      final textPainter = TextPainter(
        text: TextSpan(text: yValue.toStringAsFixed(0), style: yAxisTextStyle),
        textDirection: ui.TextDirection.ltr,
      )..layout();
      textPainter.paint(canvas, Offset(0, y - textPainter.height / 2));
      canvas.drawLine(
        Offset(yAxisOffset, y),
        Offset(size.width, y),
        Paint()
          ..color = Colors.grey.withOpacity(0.3) // Light grid line
          ..strokeWidth = 1,
      );
    }

    // Draw bars and labels
    for (int i = 0; i < spends.length; i++) {
      final barHeight = spends[i] * scaleY;
      final x = yAxisOffset + i * (barWidth + barPadding);
      final y = size.height - barHeight - 20; // Space for labels

      // Draw bar with red color
      canvas.drawRect(
        Rect.fromLTWH(x, y, barWidth, barHeight),
        Paint()..color = Colors.red, // Changed to red
      );

      // Draw label
      final labelParts = labels[i].split('\n');
      final firstLine = labelParts[0];
      final secondLine = labelParts.length > 1 ? labelParts[1] : '';

      // Draw first line
      final firstLinePainter = TextPainter(
        text: TextSpan(text: firstLine, style: textStyle),
        textAlign: TextAlign.center,
        textDirection: ui.TextDirection.ltr,
      )..layout(maxWidth: barWidth);
      firstLinePainter.paint(
        canvas,
        Offset(x + barWidth / 2 - firstLinePainter.width / 2, size.height - 15),
      );

      // Draw second line
      if (secondLine.isNotEmpty) {
        final secondLinePainter = TextPainter(
          text: TextSpan(text: secondLine, style: secondLineTextStyle),
          textAlign: TextAlign.center,
          textDirection: ui.TextDirection.ltr,
        )..layout(maxWidth: barWidth);
        secondLinePainter.paint(
          canvas,
          Offset(x + barWidth / 2 - secondLinePainter.width / 2,
              size.height), // Adjusted position for second line
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _BarChartPainter oldDelegate) {
    return oldDelegate.spends != spends ||
        oldDelegate.labels != labels ||
        oldDelegate.maxValue != maxValue;
  }
}

class LineChart extends StatelessWidget {
  final List<double> spends;
  final List<double> received;
  final List<String> labels;
  final double maxValue;

  const LineChart({
    super.key,
    required this.spends,
    required this.received,
    required this.labels,
    required this.maxValue,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
        painter: _LineChartPainter(
          spends: spends,
          received: received,
          labels: labels,
          maxValue: maxValue,
        ),
        size: Size(double.infinity, 50));
  }
}

class _LineChartPainter extends CustomPainter {
  final List<double> spends;
  final List<double> received;
  final List<String> labels;
  final double maxValue;

  _LineChartPainter({
    required this.spends,
    required this.received,
    required this.labels,
    required this.maxValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final pointPadding = size.width / 8;
    final scaleY = (size.height * 0.8) / maxValue;
    final textStyle = TextStyle(
        color: Colors.black,
        fontSize: 9); // Consistent font size for date labels
    final secondLineTextStyle = TextStyle(
        color: Colors.black,
        fontSize: 7); // Consistent font size for second line
    final yAxisTextStyle = TextStyle(
        color: Colors.black,
        fontSize: 9); // Consistent font size for Y-axis labels

    // Adjust the vertical offset to move the graph higher
    const verticalOffset = -20.0;

    // Draw Y-axis labels and grid lines
    final yDivisions = 5;
    for (int i = 0; i <= yDivisions; i++) {
      final yValue = maxValue / yDivisions * i;
      final y = size.height - (yValue * scaleY) + verticalOffset;
      final textPainter = TextPainter(
        text: TextSpan(text: yValue.toStringAsFixed(0), style: yAxisTextStyle),
        textDirection: ui.TextDirection.ltr,
      )..layout();
      textPainter.paint(canvas, Offset(0, y - textPainter.height / 2));
      canvas.drawLine(
        Offset(30, y),
        Offset(size.width, y),
        Paint()
          ..color = Colors.grey.withOpacity(0.3) // Light grid line
          ..strokeWidth = 1,
      );
    }

    // Draw lines and points
    _drawLine(
        canvas, size, spends, pointPadding, scaleY, Colors.red, verticalOffset);
    _drawLine(canvas, size, received, pointPadding, scaleY, Colors.green,
        verticalOffset);

    // Draw labels below the X-axis
    for (int i = 0; i < labels.length; i++) {
      final x = (i + 1) * pointPadding;
      final labelParts = labels[i].split('\n');
      final firstLine = labelParts[0];
      final secondLine = labelParts.length > 1 ? labelParts[1] : '';

      // Draw first line
      final firstLinePainter = TextPainter(
        text: TextSpan(text: firstLine, style: textStyle),
        textAlign: TextAlign.center,
        textDirection: ui.TextDirection.ltr,
      )..layout(maxWidth: pointPadding);
      firstLinePainter.paint(
        canvas,
        Offset(
            x - firstLinePainter.width / 2, size.height + 5 + verticalOffset),
      );

      // Draw second line
      if (secondLine.isNotEmpty) {
        final secondLinePainter = TextPainter(
          text: TextSpan(text: secondLine, style: secondLineTextStyle),
          textAlign: TextAlign.center,
          textDirection: ui.TextDirection.ltr,
        )..layout(maxWidth: pointPadding);
        secondLinePainter.paint(
          canvas,
          Offset(
              x - secondLinePainter.width / 2,
              size.height +
                  20 +
                  verticalOffset), // Adjusted position for second line
        );
      }
    }
  }

  void _drawLine(Canvas canvas, Size size, List<double> data,
      double pointPadding, double scaleY, Color color, double verticalOffset) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final path = Path();
    for (int i = 0; i < data.length; i++) {
      final x = (i + 1) * pointPadding;
      final y = size.height - data[i] * scaleY + verticalOffset;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
      canvas.drawCircle(Offset(x, y), 4, paint);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) {
    return oldDelegate.spends != spends ||
        oldDelegate.received != received ||
        oldDelegate.labels != labels ||
        oldDelegate.maxValue != maxValue;
  }
}

// Helper function to aggregate transaction data.
Map<String, Map<String, dynamic>> aggregateTransactionData(
    List<Transaction> transactions) {
  final Map<String, Map<String, dynamic>> result = {
    'Daily': {
      'spends': <int>[],
      'received': <int>[],
      'dates': <DateTime>[],
    },
    'Weekly': {
      'spends': <int>[],
      'received': <int>[],
      'dates': <DateTime>[],
    },
    'Monthly': {
      'spends': <int>[],
      'received': <int>[],
      'dates': <DateTime>[],
    },
  };

  // Daily aggregation for the last 7 days.
  for (int i = 6; i >= 0; i--) {
    final day = DateTime.now().subtract(Duration(days: i));
    // Filter transactions for this day (ignoring time)
    final dayTransactions = transactions.where((t) =>
        t.date.year == day.year &&
        t.date.month == day.month &&
        t.date.day == day.day);
    int daySpends = 0;
    int dayReceived = 0;
    for (var t in dayTransactions) {
      if (t.amount < 0) {
        daySpends += t.amount.abs().toInt();
      } else {
        dayReceived += t.amount.toInt();
      }
    }
    result['Daily']!['spends'].add(daySpends);
    result['Daily']!['received'].add(dayReceived);
    result['Daily']!['dates'].add(day);
  }

  // Weekly aggregation for the last 7 weeks.
  // We'll consider each week starting on Monday.
  for (int i = 6; i >= 0; i--) {
    // Calculate the start of the week for week i.
    final now = DateTime.now();
    // Determine the weekday offset (Monday = 1, Sunday = 7)
    final int weekdayOffset = now.weekday - 1;
    // Start of the current week:
    final currentWeekStart = now.subtract(Duration(days: weekdayOffset));
    // For week i ago, subtract i * 7 days:
    final weekStart = currentWeekStart.subtract(Duration(days: i * 7));
    final weekEnd = weekStart.add(Duration(days: 6));

    final weekTransactions = transactions.where((t) =>
        t.date.isAfter(weekStart.subtract(Duration(days: 1))) &&
        t.date.isBefore(weekEnd.add(Duration(days: 1))));
    int weekSpends = 0;
    int weekReceived = 0;
    for (var t in weekTransactions) {
      if (t.amount < 0) {
        weekSpends += t.amount.abs().toInt();
      } else {
        weekReceived += t.amount.toInt();
      }
    }
    result['Weekly']!['spends'].add(weekSpends);
    result['Weekly']!['received'].add(weekReceived);
    result['Weekly']!['dates'].add(weekStart);
  }

  // Monthly aggregation for the last 7 months.
  for (int i = 6; i >= 0; i--) {
    final now = DateTime.now();
    // Calculate the month, adjusting the year if needed.
    final month = DateTime(now.year, now.month - i, 1);
    final monthTransactions = transactions
        .where((t) => t.date.year == month.year && t.date.month == month.month);
    int monthSpends = 0;
    int monthReceived = 0;
    for (var t in monthTransactions) {
      if (t.amount < 0) {
        monthSpends += t.amount.abs().toInt();
      } else {
        monthReceived += t.amount.toInt();
      }
    }
    result['Monthly']!['spends'].add(monthSpends);
    result['Monthly']!['received'].add(monthReceived);
    result['Monthly']!['dates'].add(month);
  }

  return result;
}

TransactionFilter createRecentTransactionFilter({
  String? merchantId,
  String? categoryId,
  int pastMonths = 7,
}) {
  final now = DateTime.now();
  // Compute the start date as the first day of the month, pastMonths ago.
  final startDate = DateTime(now.year, now.month - pastMonths + 1, 1);
  // Compute the end date as the last day of the current month.
  final endDate = DateTime(now.year, now.month + 1, 0, 23, 59, 59, 999);
  return TransactionFilter(
    merchantId: merchantId,
    categoryId: categoryId,
    startDate: startDate,
    endDate: endDate,
  );
}
