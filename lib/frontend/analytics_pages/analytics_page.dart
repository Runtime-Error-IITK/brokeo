import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:brokeo/frontend/home_pages/home_page.dart' as brokeo_home;
import 'package:brokeo/frontend/transactions_pages/categories_page.dart';
import 'package:brokeo/frontend/split_pages/manage_splits.dart';

class AnalyticsPage extends StatefulWidget {
  @override
  _AnalyticsPageState createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  int _currentIndex = 2;
  String _selectedFilter = 'Daily';
  final List<String> _filters = ['Daily', 'Weekly', 'Monthly'];

  // Mock data for demonstration
  final Map<String, Map<String, dynamic>> _data = {
    'Daily': {
      'spends': [1200, 800, 1500, 900, 1300, 700, 1000],
      'received': [500, 1200, 800, 600, 900, 1300, 700],
      'dates': List.generate(
          7, (i) => DateTime.now().subtract(Duration(days: 6 - i))),
    },
    'Weekly': {
      'spends': [4500, 5200, 4800, 5100, 4900, 5300, 5000],
      'received': [3800, 4200, 4000, 4100, 3900, 4300, 4100],
      'dates': List.generate(
          7, (i) => DateTime.now().subtract(Duration(days: (6 - i) * 7))),
    },
    'Monthly': {
      'spends': [18000, 19500, 21000, 18500, 20000, 19000, 20500],
      'received': [16500, 17500, 18500, 17000, 18000, 17500, 19000],
      'dates': List.generate(7,
          (i) => DateTime(DateTime.now().year, DateTime.now().month - (6 - i))),
    },
  };

  @override
  Widget build(BuildContext context) {
    final currentData = _data[_selectedFilter]!;
    final dates = currentData['dates'] as List<DateTime>;
    final labels = _generateLabels(dates);

    final spends = (currentData['spends'] as List)
        .map((e) => (e as num).toDouble())
        .toList();
    final received = (currentData['received'] as List)
        .map((e) => (e as num).toDouble())
        .toList();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: Text('Analytics'),
            floating: true,
            actions: [
              IconButton(
                icon: Icon(Icons.ios_share),
                onPressed: () => _exportToCSV(currentData, dates),
              ),
              Padding(
                padding: EdgeInsets.only(right: 12),
                child: DropdownButton<String>(
                  value: _selectedFilter,
                  dropdownColor: Theme.of(context).scaffoldBackgroundColor,
                  items: _filters.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value, style: TextStyle(color: Colors.black)),
                    );
                  }).toList(),
                  onChanged: (newValue) =>
                      setState(() => _selectedFilter = newValue!),
                ),
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
                        child: BarChart(
                          spends: spends,
                          labels: labels,
                          maxValue: spends.reduce((a, b) => a > b ? a : b),
                        ),
                      ),
                    ),
                    _buildChartSection(
                      title: 'Cash Flow',
                      child: Container(
                        height: 300,
                        padding: EdgeInsets.only(bottom: 20),
                        child: LineChart(
                          spends: spends,
                          received: received,
                          labels: labels,
                          maxValue: [...spends, ...received]
                              .reduce((a, b) => a > b ? a : b),
                        ),
                      ),
                    ),
                    _buildLegend(),
                    SizedBox(height: 20),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  List<String> _generateLabels(List<DateTime> dates) {
    final format = _selectedFilter == 'Monthly'
        ? DateFormat('MMM')
        : _selectedFilter == 'Weekly'
            ? DateFormat('dd/MM')
            : DateFormat('dd/MM');
    return dates.map((d) => format.format(d)).toList();
  }

  Widget _buildChartSection({required String title, required Widget child}) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
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
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem(Colors.red, 'Spent'),
        SizedBox(width: 20),
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
              builder: (context) =>
                  brokeo_home.HomePage(name: "Darshan", budget: 5000),
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
    const barPadding = 30.0;
    final barWidth =
        (size.width - (barPadding * (spends.length - 1))) / spends.length;
    final scaleY = (size.height * 0.8) / maxValue; // Adjusted space for labels
    final textStyle = TextStyle(color: Colors.black, fontSize: 12);
    double barSeparation = size.width / 12;
    for (int i = 0; i < spends.length; i++) {
      final barHeight = spends[i] * scaleY;
      final x = i * (barWidth + barSeparation);
      final y = size.height - barHeight - 20; // Space for labels

      // Draw bar with red color
      canvas.drawRect(
        Rect.fromLTWH(x, y, barWidth, barHeight),
        Paint()..color = Colors.red, // Changed to red
      );

      // Draw label
      final textPainter = TextPainter(
        text: TextSpan(text: labels[i], style: textStyle),
        textDirection: ui.TextDirection.ltr,
      )..layout();
      textPainter.paint(
        canvas,
        Offset(x + barWidth / 2 - textPainter.width / 2, size.height - 15),
      );
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
    final textStyle = TextStyle(color: Colors.black, fontSize: 12);

    // Draw lines and points
    _drawLine(canvas, size, spends, pointPadding, scaleY, Colors.red);
    _drawLine(canvas, size, received, pointPadding, scaleY, Colors.green);

    // Draw labels
    for (int i = 0; i < labels.length; i++) {
      final x = (i + 1) * pointPadding;
      final textPainter = TextPainter(
        text: TextSpan(text: labels[i], style: textStyle),
        textDirection: ui.TextDirection.ltr,
      )..layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, size.height - 15),
      );
    }
  }

  void _drawLine(Canvas canvas, Size size, List<double> data,
      double pointPadding, double scaleY, Color color) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final path = Path();
    for (int i = 0; i < data.length; i++) {
      print(size.width);
      final x = (i + 1) * pointPadding;
      final y = size.height - data[i] * scaleY;
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
