import 'dart:developer' show log;
import 'dart:math' show pi;
import 'package:brokeo/backend/models/category.dart';
import 'package:brokeo/backend/models/merchant.dart';
import 'package:brokeo/backend/models/schedule.dart';
import 'package:brokeo/backend/models/transaction.dart';
import 'package:brokeo/backend/services/providers/read_providers/category_stream_provider.dart'
    show CategoryFilter, categoryStreamProvider;
import 'package:brokeo/backend/services/providers/read_providers/merchant_stream_provider.dart'
    show MerchantFilter, merchantStreamProvider;
import 'package:brokeo/backend/services/providers/read_providers/schedule_stream_provider.dart'
    show ScheduleFilter, scheduleStreamProvider;
import 'package:brokeo/backend/services/providers/read_providers/split_transaction_stream_provider.dart'
    show SplitTransactionFilter, splitTransactionStreamProvider;
import 'package:brokeo/backend/services/providers/read_providers/transaction_stream_provider.dart'
    show TransactionFilter, transactionStreamProvider;
import 'package:brokeo/backend/services/providers/read_providers/user_id_provider.dart';
import 'package:brokeo/backend/services/providers/write_providers/merchant_service.dart'
    show merchantServiceProvider;
import 'package:brokeo/backend/services/providers/write_providers/schedule_service.dart'
    show scheduleServiceProvider;
import 'package:brokeo/backend/services/providers/write_providers/transaction_service.dart';
import 'package:brokeo/frontend/transactions_pages/categories_page.dart';
import 'package:brokeo/frontend/profile_pages/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:brokeo/frontend/split_pages/manage_splits.dart';
import 'package:brokeo/frontend/profile_pages/budget_page.dart';
import 'package:brokeo/frontend/transactions_pages/category_page.dart';
import 'package:brokeo/frontend/transactions_pages/transaction_detail_page.dart';
import 'package:brokeo/frontend/split_pages/split_history.dart';
import 'package:brokeo/frontend/split_pages/choose_transactions.dart';
import 'package:brokeo/frontend/analytics_pages/analytics_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:brokeo/sms_handler.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

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
  List<dynamic> contacts = [];
  final emptyTransactionFilter = const TransactionFilter();
  final emptyCategoryFilter = const CategoryFilter();

  static const platform = MethodChannel('sms_platform');
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _checkAndRequestSmsPermission();
    startListeningForSms();
    _loadContacts();
  }

  void _initializeNotifications() {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _showNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'sms_channel',
      'SMS Notifications',
      channelDescription: 'Notifications for SMS-based transactions',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
    );
  }

  Future<void> _checkAndRequestSmsPermission() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirstTime = prefs.getBool('isFirstTime') ?? true;

    if (isFirstTime) {
      await _requestSmsPermission();
      await prefs.setBool('isFirstTime', false);
    }
  }

  Future<void> _requestSmsPermission() async {
    final status = await Permission.sms.request();
    if (status.isGranted) {
      log("SMS permission granted");
      // Listen for incoming messages
      startListeningForSms();
    } else if (status.isDenied) {
      log("SMS permission denied");
      // Show a popup to inform the user of the benefits of using sms permission
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("SMS Permission"),
          content: Text(
              "Granting SMS permission allows us to automatically fetch your transactions so you don't have to manually add new transactions."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _requestSmsPermission(); // Retry requesting permission
              },
              child: Text("Retry"),
            ),
            TextButton(
              onPressed: () {
                // Close the popup
                Navigator.pop(context);
              },
              child: Text("Don't Allow"),
            ),
          ],
        ),
      );
    } else if (status.isPermanentlyDenied) {
      log("SMS permission permanently denied");
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("SMS Permission"),
              content: Text(
                  "SMS permission is permanently denied. Please enable it in your device settings."),
              actions: [
                TextButton(
                  onPressed: () {
                    openAppSettings(); // Open app settings for the user
                    Navigator.pop(context); // Close the popup
                  },
                  child: Text("Open Settings"),
                ),
              ],
            );
          });
    } else if (status.isRestricted) {
      log("SMS permission restricted");
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("SMS Permission"),
              content: Text(
                  "SMS permission is restricted. Please check your device settings."),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close the popup
                  },
                  child: Text("OK"),
                ),
              ],
            );
          });
    } else if (status.isLimited) {
      log("SMS permission limited");
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("SMS Permission"),
              content: Text(
                  "SMS permission is limited. Please check your device settings."),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close the popup
                  },
                  child: Text("OK"),
                ),
              ],
            );
          });
    } else {
      log("Unknown SMS permission status: $status");
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("SMS Permission"),
              content: Text(
                  "Unknown SMS permission status. Please check your device settings."),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close the popup
                  },
                  child: Text("OK"),
                ),
              ],
            );
          });
    }
  }

  // Start listening for incoming SMS messages
  void startListeningForSms() {
    log("Starting to listen for SMS messages...");
    platform.setMethodCallHandler((call) async {
      if (call.method == 'onSmsReceived') {
        log("Received SMS message from platform channel");
        final String newMessage = call.arguments as String;
        SmsHandler.fetchTransactionData(newMessage);
      }
    });
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
            _buildScheduledPayments(),
            _buildSplits(),
            _buildBudget(),
          ],
        ),
      ),
      // bottomNavigationBar: buildBottomNavigationBar(),
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
        ref.watch(transactionStreamProvider(emptyTransactionFilter));

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
        // log(userMetadata.toString());
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
            final now = DateTime.now();
            final startOfMonth = DateTime(now.year, now.month, 1);
            final endOfMonth =
                DateTime(now.year, now.month + 1, 0, 23, 59, 59, 999);
            final filteredTransactions = transactions.where((transaction) {
              return transaction.date.isAfter(startOfMonth) &&
                  transaction.date.isBefore(endOfMonth);
            }).toList();
            double totalSpent = 0;
            for (var transaction in filteredTransactions) {
              totalSpent -= transaction.amount < 0 ? transaction.amount : 0;
            }

            final categoriesAsync =
                ref.watch(categoryStreamProvider(emptyCategoryFilter));
            final categories = categoriesAsync.value ?? [];
            double budget = userMetadata['budget'] ?? 0.0;
            // log(budget.toString());
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
                      // IconButton(
                      //   icon: Icon(Icons.notifications,
                      //       size: 28, color: Colors.black54),
                      //   onPressed: () {},
                      // ),
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
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  "${percentageSpent.toStringAsFixed(1)}%",
                                  style: TextStyle(
                                      fontSize: 15,
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

  Widget _buildBudget() {
    final asyncCategories =
        ref.watch(categoryStreamProvider(emptyCategoryFilter));
    return asyncCategories.when(
        loading: () => const CircularProgressIndicator(),
        error: (error, stack) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Homepage Budget error: $error")),
            );
          });
          return SizedBox.shrink();
        },
        data: (categories) {
          double overallBudget = 0;
          for (var category in categories) {
            overallBudget += category.budget;
          }

          List<Category> categoriesToShow = showAllBudgetCategories
              ? categories
              : categories.take(3).toList();

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
                    /// **Header**: "Budget", plus icon, expand icon
                    Row(
                      children: [
                        Text(
                          "Budget",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Spacer(),
                        IconButton(
                          icon:
                              Icon(Icons.edit, size: 22, color: Colors.black54),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => BudgetPage()),
                            );
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
                              showAllBudgetCategories =
                                  !showAllBudgetCategories;
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
        });
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

  Widget _buildBudgetCategoryTile(Category category) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoryPage(
              categoryId: category.categoryId,
            ),
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
              child: Image.asset(
                'assets/category_icon/${category.name}.jpg',
                width: 40,
                height: 40,
                fit: BoxFit.cover,
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
              "₹${category.budget.abs().toStringAsFixed(0)}",
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

  Widget _buildTransactions() {
    final asyncTransactions =
        ref.watch(transactionStreamProvider(emptyTransactionFilter));

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
        final now = DateTime.now();
        final startOfMonth = DateTime(now.year, now.month, 1);
        final endOfMonth =
            DateTime(now.year, now.month + 1, 0, 23, 59, 59, 999);
        final filteredTransactions = transactions.where((transaction) {
          return transaction.date.isAfter(startOfMonth) &&
              transaction.date.isBefore(endOfMonth);
        }).toList();
        // log(transactions.length.toString());
        List<Transaction> transactionsToShow = showAllTransactions
            ? filteredTransactions.take(10).toList()
            : filteredTransactions.take(3).toList();
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
                  filteredTransactions.isEmpty
                      ? Center(
                          child: Text(
                            "No Transactions this month",
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
    String transactionType = "Credit"; // Default transaction type

    // Declare the processing flag before calling the StatefulBuilder so it doesn't reset on rebuild.
    bool isProcessing = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Consumer(
          builder: (context, ref, child) {
            final asyncCategories =
                ref.watch(categoryStreamProvider(emptyCategoryFilter));
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
                return StatefulBuilder(
                  builder: (context, setState) {
                    // Check if form is valid.
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
                              // Transaction type radio buttons
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
                              // Category dropdown
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
                          onPressed: isFormValid && !isProcessing
                              ? () async {
                                  // Set the processing flag.
                                  setState(() {
                                    isProcessing = true;
                                  });
                                  final filter =
                                      MerchantFilter(merchantName: merchant);
                                  try {
                                    // Check if the merchant exists.
                                    final merchants = await ref.read(
                                        merchantStreamProvider(filter).future);
                                    String merchantId;
                                    if (merchants.isNotEmpty) {
                                      merchantId = merchants.first.merchantId;
                                    } else {
                                      // If not found, add a new merchant.
                                      final merchantService =
                                          ref.read(merchantServiceProvider);
                                      if (merchantService == null) {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                                content:
                                                    Text("User not logged in")),
                                          );
                                        }
                                        setState(() {
                                          isProcessing = false;
                                        });
                                        return;
                                      }
                                      final newCloudMerchant = CloudMerchant(
                                        merchantId:
                                            "", // Auto-generated by Firestore.
                                        name: merchant!,
                                        userId: ref.read(userIdProvider) ?? "",
                                        categoryId:
                                            selectedCategory!.categoryId,
                                      );
                                      final insertedMerchant =
                                          await merchantService
                                              .insertMerchant(newCloudMerchant);
                                      if (insertedMerchant == null) {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                                content: Text(
                                                    "Failed to add merchant.")),
                                          );
                                        }
                                        setState(() {
                                          isProcessing = false;
                                        });
                                        return;
                                      }
                                      merchantId = insertedMerchant.merchantId;
                                    }

                                    // Create the transaction.
                                    final newTransaction = Transaction(
                                      transactionId: "",
                                      amount: transactionType == "Credit"
                                          ? double.parse(amount!)
                                          : -1 * double.parse(amount!),
                                      date: DateTime.now(),
                                      merchantId: merchantId,
                                      categoryId: selectedCategory!.categoryId,
                                      userId: ref.read(userIdProvider) ?? "",
                                      sms: "Manually added transaction",
                                    );
                                    final cloudTransaction =
                                        CloudTransaction.fromTransaction(
                                            newTransaction);
                                    final transactionService =
                                        ref.read(transactionServiceProvider);
                                    if (transactionService == null) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content:
                                                  Text("User not logged in")),
                                        );
                                      }
                                      setState(() {
                                        isProcessing = false;
                                      });
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
                                        Navigator.pop(context);
                                      }
                                    } else {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content: Text(
                                                  "Failed to add transaction.")),
                                        );
                                      }
                                      setState(() {
                                        isProcessing = false;
                                      });
                                    }
                                  } catch (error) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                "Error loading merchant data: $error")),
                                      );
                                    }
                                    setState(() {
                                      isProcessing = false;
                                    });
                                  }
                                }
                              : null,
                          child: isProcessing
                              ? SizedBox(
                                  height: 20,
                                  width: 20,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Text("Confirm"),
                        ),
                      ],
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _transactionTile(Transaction transaction, int index) {
    final String merchantId = transaction.merchantId;

    final merchantFilter = MerchantFilter(
      merchantId: merchantId,
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
        // log(merchant.length.toString());
        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TransactionDetailPage(
                  transaction: transaction,
                ),
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
                        merchant[0].name[0],
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
                          "₹${transaction.amount.abs().toStringAsFixed(0)}",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: transaction.amount < 0
                                ? Colors.red
                                : Colors.green,
                          ),
                        ),
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
          sum -= transaction.amount < 0.0 ? transaction.amount : 0.0;
        }
        return InkWell(
          onTap: () {
            // final data = CategoryCardData(
            //   name: category.name,
            //   icon: Icons.category,
            //   color: Colors.blue,
            //   spent: 0,
            //   budget: category.budget,
            // );
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CategoryPage(
                  categoryId: category.categoryId,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              children: [
                // Circle avatar with emoji

                Image.asset(
                  'assets/category_icon/${category.name}.jpg',
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
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

  Widget _buildScheduledPayments() {
    // If not expanded, only show top 3
    final now = DateTime.now();

    final todayMidnight =
        DateTime(now.year, now.month, now.day).subtract(Duration(days: 1));
    final filter = ScheduleFilter(startDate: todayMidnight);
    final asyncSchedules =
        ref.watch(scheduleStreamProvider(filter)); // Fetch scheduled payments

    return asyncSchedules.when(
        loading: () => const CircularProgressIndicator(),
        error: (error, stack) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Scheduled Payment error: $error")),
            );
          });
          return SizedBox.shrink();
        },
        data: (payments) {
          List<Schedule> paymentsToShow =
              showAllScheduledPayments ? payments : payments.take(3).toList();

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
                          "Scheduled Payments",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Spacer(),
                        IconButton(
                          icon:
                              Icon(Icons.add, size: 22, color: Colors.black54),
                          onPressed: () {
                            showAddScheduledPaymentDialog(context);
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
                              showAllScheduledPayments =
                                  !showAllScheduledPayments;
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
                            children:
                                paymentsToShow.asMap().entries.map((entry) {
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
        });
  }

  void showAddScheduledPaymentDialog(BuildContext context) {
    final nameController = TextEditingController();
    final amountController = TextEditingController();
    final descriptionController = TextEditingController();
    DateTime? selectedDate;
    bool isProcessing = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text('Add Scheduled Payment'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(labelText: 'Name'),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: 'Amount (₹)'),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: descriptionController,
                      decoration: InputDecoration(labelText: 'Description'),
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            selectedDate == null
                                ? 'No Date Chosen'
                                : '${selectedDate!.toLocal()}'.split(' ')[0],
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.calendar_today),
                          onPressed: () async {
                            final pickedDate = await showDatePicker(
                              context: context,
                              initialDate:
                                  DateTime.now().add(Duration(days: 1)),
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2100),
                            );
                            if (pickedDate != null) {
                              setState(() {
                                selectedDate = pickedDate;
                              });
                            }
                          },
                        )
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () => Navigator.pop(context),
                ),
                ElevatedButton(
                  onPressed: isProcessing
                      ? null
                      : () async {
                          final name = nameController.text.trim();
                          final amount = amountController.text.trim();
                          final description = descriptionController.text.trim();

                          if (name.isEmpty ||
                              amount.isEmpty ||
                              description.isEmpty ||
                              selectedDate == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Please fill all fields")),
                            );
                            return;
                          }

                          final now = DateTime.now();
                          if (selectedDate!.isBefore(
                              DateTime(now.year, now.month, now.day)
                                  .subtract(Duration(days: 1)))) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text("Please select a future date")),
                            );
                            return;
                          }

                          final userId = ref.read(userIdProvider);
                          if (userId == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("User not logged in")),
                            );
                            return;
                          }

                          setState(() {
                            isProcessing = true;
                          });

                          final schedule = Schedule(
                            merchantName: name,
                            amount: double.parse(amount),
                            description: description,
                            date: selectedDate!,
                            userId: userId,
                            scheduleId: "",
                            paid: false,
                          );

                          final scheduleService =
                              ref.read(scheduleServiceProvider);
                          if (scheduleService == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("User not logged in")),
                            );
                            setState(() => isProcessing = false);
                            return;
                          }

                          try {
                            await scheduleService.insertSchedule(
                              CloudSchedule.fromSchedule(schedule),
                            );
                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text("Scheduled payment added.")),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Error: $e")),
                              );
                            }
                            setState(() => isProcessing = false);
                          }
                        },
                  child: isProcessing
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

// Single Scheduled Payment tile
  Widget _buildScheduledPaymentTile(Schedule payment) {
    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text('Scheduled Payment Details'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text("Name: ",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Expanded(child: Text(payment.merchantName)),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Text("Amount: ",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Expanded(
                          child: Text("₹${payment.amount.toStringAsFixed(0)}")),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Text("Description: ",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Expanded(child: Text(payment.description)),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Text("Scheduled Date: ",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Expanded(
                        child: Text(
                          "${DateFormat("MMM dd, yyyy").format(payment.date.toLocal())}, 23:59",
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Close"),
                ),
                TextButton(
                  onPressed: payment.paid
                      ? null
                      : () {
                          // Mark as paid
                          final newSchedule = Schedule(
                            scheduleId: payment.scheduleId,
                            userId: payment.userId,
                            amount: payment.amount,
                            merchantName: payment.merchantName,
                            date: payment.date,
                            description: payment.description,
                            paid: true,
                          );
                          final scheduleService =
                              ref.read(scheduleServiceProvider);
                          if (scheduleService == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("User not logged in")),
                            );
                            return;
                          } else {
                            scheduleService.updateSchedule(
                                CloudSchedule.fromSchedule(newSchedule));
                          }

                          Navigator.pop(context);
                        },
                  child: Text("Mark as Paid"),
                ),
              ],
            );
          },
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.purple[100],
              child: Text(
                payment.merchantName.isNotEmpty
                    ? payment.merchantName[0].toUpperCase()
                    : "?",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                payment.merchantName,
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ),
            // Display due date above amount using a Column.
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "Due: ${DateFormat("MMM dd, yyyy").format(payment.date.toLocal())}, 23:59",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  "₹${payment.amount.toStringAsFixed(0)}",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: payment.paid ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _loadContacts() async {
    final status = await Permission.contacts.request();
    if (status.isGranted) {
      log("Permission granted. Fetching contacts...");
      try {
        // This calls your platform method to fetch contacts.
        const platform = MethodChannel('com.example.contacts/fetch');
        final List<dynamic> contactDetails =
            await platform.invokeMethod('getContacts');
        log("Contacts fetched successfully: ${contactDetails.length} contacts found.");

        // Use a temporary map to remove duplicates (keyed by a unique field, e.g. phone number).
        final Map<String, Map<String, String>> tempMap = {};

        for (var contact in contactDetails) {
          // Extract the name and phone number from each contact.
          final String name = (contact['name'] as String?)?.trim() ?? "Unknown";
          final String phone =
              (contact['phone'] as String?)?.trim().replaceAll(' ', '') ?? "";
          if (name.isNotEmpty && phone.isNotEmpty) {
            tempMap[phone] = {"name": name, "phone": phone};
          }
        }

        // Convert the deduplicated map values to a list and sort it by name.
        List<Map<String, String>> contactList = tempMap.values.toList();
        contactList.sort((a, b) =>
            a["name"]!.toLowerCase().compareTo(b["name"]!.toLowerCase()));

        // Use setState to update contacts and ensure the UI rebuilds.
        if (mounted) {
          setState(() {
            contacts = contactList;
          });
        }
      } on PlatformException catch (e) {
        log("Failed to fetch contacts: ${e.message}");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to fetch contacts: ${e.message}")),
          );
        }
      }
    } else {
      log("Permission denied.");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Contacts permission denied")),
        );
      }
    }
  }

  Widget _buildSplits() {
    // Fetch the dummy values from MockBackend

    final filter = SplitTransactionFilter();
    final asyncSplitTransactions =
        ref.watch(splitTransactionStreamProvider(filter));
    final asyncMetaData =
        ref.watch(userMetadataStreamProvider); // Get user metadata

    return asyncMetaData.when(
        loading: () => const CircularProgressIndicator(),
        error: (error, stack) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Split Transaction error: $error")),
            );
          });
          return SizedBox.shrink();
        },
        data: (metadata) {
          return asyncSplitTransactions.when(
              loading: () => const CircularProgressIndicator(),
              error: (error, stack) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Split Transaction error: $error")),
                  );
                });
                return SizedBox.shrink();
              },
              data: (splits) {
                // double totalBalance = ;
                // double youOwe = ;
                // double youAreOwed = ;
                double borrowed = 0, lent = 0;
                var splitUsers = {};
                var splitUsersNames = {};
                for (var transaction in splits) {
                  // log(transaction.toString());
                  for (var entry in transaction.splitAmounts.entries) {
                    final user = entry.key;
                    final amount = entry.value;

                    if (transaction.isPayment) {
                      // log('sad');
                      if (user == metadata["phone"]) {
                        continue;
                      }
                      // log(transaction.toString());
                      if (!splitUsers.containsKey(user)) {
                        splitUsers[user] = 0.0;
                        splitUsersNames[user] = contacts.firstWhere(
                            (contact) => contact["phone"] == user, orElse: () {
                          return {"name": user};
                        })["name"];
                      }
                      if (transaction.userPhone == metadata["phone"]) {
                        // log("wowpw");
                        splitUsers[user] = splitUsers[user] + amount;
                      } else {
                        splitUsers[user] = splitUsers[user] -
                            transaction.splitAmounts[metadata["phone"]];
                      }
                    } else {
                      // continue;
                      if (transaction.userPhone == metadata["phone"]) {
                        if (user == metadata["phone"]) continue;
                        if (!splitUsers.containsKey(user)) {
                          if (entry.key == metadata["phone"]) continue;
                          splitUsers[user] = 0.0;
                          splitUsersNames[user] = contacts
                              .firstWhere((contact) => contact["phone"] == user,
                                  orElse: () {
                            return {"name": user};
                          })["name"];
                        }
                        splitUsers[user] = splitUsers[user] + amount;
                      } else if (transaction.userPhone == user) {
                        if (!splitUsers.containsKey(user)) {
                          if (entry.key == metadata["phone"]) continue;
                          splitUsers[user] = 0.0;
                          splitUsersNames[user] = contacts
                              .firstWhere((contact) => contact["phone"] == user,
                                  orElse: () {
                            return {"name": user};
                          })["name"];
                        }
                        splitUsers[user] = splitUsers[user] -
                            transaction.splitAmounts[metadata["phone"]];
                      }
                    }
                  }
                }

                //remove yourself
                splitUsers.remove(metadata["phone"]);

                for (var entry in splitUsers.entries) {
                  final amount = entry.value;
                  if (amount < 0) {
                    borrowed += amount.abs();
                  } else {
                    lent += amount;
                  }
                }
                // Show top 3 splits by default

                final splitUsersList = splitUsers.entries.map(
                  (entry) {
                    return {
                      "name": splitUsersNames[entry.key],
                      "phone": entry.key,
                      "amount": entry.value
                    };
                  },
                ).toList();

                List<Map<String, dynamic>> splitsToShow = showAllSplits
                    ? splitUsersList.take(10).toList()
                    : splitUsersList.take(3).toList();

                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 20),
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
                          /// **Header Row** (Title, Add, Expand/Collapse)
                          Row(
                            children: [
                              Text(
                                "Splits",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              Spacer(),
                              IconButton(
                                icon: Icon(Icons.add,
                                    size: 22, color: Colors.black54),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            ChooseTransactionPage()),
                                  );
                                },
                              ),
                              IconButton(
                                icon: Icon(
                                  showAllSplits
                                      ? Icons.expand_less
                                      : Icons.expand_more,
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
                          ///
                          _buildSplitSummaryTile(
                            "Total Balance",
                            (borrowed - lent) > 0
                                ? borrowed - lent
                                : lent - borrowed,
                            borrowed == lent
                                ? Colors.black
                                : borrowed < lent
                                    ? Colors.green[800]!
                                    : Colors.red[800]!,
                          ),
                          _buildSplitSummaryTile(
                              "You owe", borrowed, Colors.red[800]!),
                          _buildSplitSummaryTile(
                              "You are owed", lent, Colors.green[800]!),

                          // Divider below summaries
                          Divider(color: Colors.grey[300], height: 20),

                          // If no splits, show message
                          if (splitUsers.isEmpty)
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
                              children:
                                  splitsToShow.asMap().entries.map((entry) {
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
              });
        });
  }

  Widget _buildSplitSummaryTile(String label, double amount, Color color) {
    Color amountColor = color;

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

  Widget _buildSplitTile(Map<dynamic, dynamic> split) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            // builder: (context) => HomePage(),
            builder: (context) => SplitHistoryPage(split: split),
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
                    split["name"][0].toUpperCase(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.purple,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        split["name"],
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                // Wrap the lending/borrowing information in a column.
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      split["amount"] < 0
                          ? "You borrowed"
                          : split["amount"] == 0
                              ? "Settled"
                              : "You lent",
                      style: TextStyle(
                        fontSize: 12,
                        color: split["amount"] < 0
                            ? Colors.red
                            : split["amount"] == 0
                                ? Colors.black
                                : Colors.green,
                      ),
                    ),
                    Text(
                      "₹${split["amount"].abs().toStringAsFixed(2)}",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: split["amount"] < 0
                            ? Colors.red
                            : split["amount"] == 0
                                ? Colors.black
                                : Colors.green,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    SmsHandler.saveAppCloseTime(
        DateTime.now()); // Save the app's close time when the app is closed
    super.dispose();
  }
}

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

const String budgetId = "budget";
const String nameId = "name";
