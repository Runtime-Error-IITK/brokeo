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
import 'package:brokeo/backend/services/providers/read_providers/transaction_stream_provider.dart'
    show TransactionFilter, transactionStreamProvider;
import 'package:brokeo/backend/services/providers/read_providers/user_id_provider.dart';
import 'package:brokeo/backend/services/providers/write_providers/merchant_service.dart'
    show merchantServiceProvider;
import 'package:brokeo/backend/services/providers/write_providers/transaction_service.dart';
import 'package:brokeo/frontend/transactions_pages/categories_page.dart';
import 'package:brokeo/frontend/profile_pages/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
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
    SmsHandler.processNewSmsOnAppOpen();
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
            // _buildSplits(splits),
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
        log(userMetadata.toString());
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
            log(budget.toString());
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
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  "${percentageSpent.toStringAsFixed(1)}%",
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
            ? filteredTransactions
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
    String transactionType =
        "Credit"; // Default transaction type set to "Credit"

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Consumer(builder: (context, ref, child) {
          final asyncCategories =
              ref.watch(categoryStreamProvider(emptyCategoryFilter));
          // log(asyncCategories.toString());
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
              // Wrap the entire AlertDialog in a StatefulBuilder so that
              // any changes update both the content and the actions.
              // log(categories.length.toString());
              return StatefulBuilder(
                builder: (context, setState) {
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
                            // Radio buttons for transaction type
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
                            // Dropdown for selecting a category
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
                        onPressed: isFormValid
                            ? () async {
                                // Create a filter for the merchant using the merchant name from input.
                                final filter =
                                    MerchantFilter(merchantName: merchant);
                                try {
                                  // Await the first snapshot from the merchant stream.
                                  final merchants = await ref.read(
                                      merchantStreamProvider(filter).future);
                                  String merchantId;

                                  if (merchants.isNotEmpty) {
                                    // Merchant exists, so use the merchantId from the first one.
                                    merchantId = merchants.first.merchantId;
                                  } else {
                                    // Merchant not found. Insert a new merchant first.
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
                                      return;
                                    }
                                    // Create a new CloudMerchant using the merchant name and the selected category.
                                    final newCloudMerchant = CloudMerchant(
                                      merchantId:
                                          "", // Will be auto-generated by Firestore.
                                      name: merchant!,
                                      userId: ref.read(userIdProvider) ?? "",
                                      categoryId: selectedCategory!.categoryId,
                                      // Add any additional fields if needed.
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
                                      return;
                                    }
                                    merchantId = insertedMerchant.merchantId;
                                  }

                                  // Now, create the transaction using the obtained merchantId.
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
                                  }
                                } catch (error) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              "Error loading merchant data: $error")),
                                    );
                                  }
                                }
                              }
                            : null,
                        child: Text("Confirm"),
                      ),
                    ],
                  );
                },
              );
            },
          );
        });
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
                    // Text(
                    //   "₹${transaction.amount.abs()}",
                    //   style: TextStyle(
                    //     fontSize: 14,
                    //     fontWeight: FontWeight.bold,
                    //     color:
                    //         transaction.amount < 0 ? Colors.red : Colors.green,
                    //   ),
                    // ),
                  ],
                ),
              ),
              // if (expandedTransactionIndex == index)
              //   Padding(
              //     padding:
              //         const EdgeInsets.only(left: 50, right: 10, bottom: 8),
              //     child: Align(
              //       alignment: Alignment.centerLeft,
              //       child: Text(
              //         "Date: ${DateFormat('dd MMM yyyy').format(DateTime.now())}\nCategory: Groceries",
              //         style: TextStyle(fontSize: 12, color: Colors.black54),
              //       ),
              //     ),
              //   ),
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
    final todayMidnight = DateTime(now.year, now.month, now.day);
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
                            // TODO: Handle "Add Scheduled Payment"
                            // log("aaaaa");
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
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? selectedDate;

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
                    controller: _nameController,
                    decoration: InputDecoration(labelText: 'Name'),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'Amount (₹)'),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: _descriptionController,
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
                            initialDate: DateTime.now().add(Duration(days: 1)),
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
                child: Text('Add'),
                onPressed: () {
                  final name = _nameController.text.trim();
                  final amount = _amountController.text.trim();
                  final description = _descriptionController.text.trim();

                  if (name.isEmpty || amount.isEmpty || description.isEmpty || selectedDate == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Please fill all fields")),
                    );
                    return;
                  }

                  final now = DateTime.now();
                  if (selectedDate!.isBefore(DateTime(now.year, now.month, now.day))) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Please select a future date")),
                    );
                    return;
                  }

                  // Everything is valid, proceed (just print for now)
                  print("Name: $name");
                  print("Amount: ₹$amount");
                  print("Description: $description");
                  print("Date: ${selectedDate!.toLocal()}");

                  Navigator.pop(context);
                },
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
                    Text("Name: ", style: TextStyle(fontWeight: FontWeight.bold)),
                    Expanded(child: Text(payment.merchantName)),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Text("Amount: ", style: TextStyle(fontWeight: FontWeight.bold)),
                    Expanded(child: Text("₹${payment.amount.toStringAsFixed(0)}")),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Text("Description: ", style: TextStyle(fontWeight: FontWeight.bold)),
                    Expanded(child: Text(payment.description ?? "—")),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  // children: [
                  //   Text("Scheduled Date: ", style: TextStyle(fontWeight: FontWeight.bold)),
                  //   Expanded(
                  //     child: Text("${payment.scheduledDate.toLocal()}".split(' ')[0]),
                  //   ),
                  // ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Close"),
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

  @override
  void dispose() {
    SmsHandler
        .saveAppCloseTime(); // Save the app's close time when the app is closed
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
