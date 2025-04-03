// import 'package:flutter/material.dart';
// import 'package:hooks_riverpod/hooks_riverpod.dart';
// import 'package:intl/intl.dart';
// import 'package:flutter/services.dart';
// import 'package:brokeo/frontend/transactions_pages/categories_page.dart';
// import 'package:brokeo/frontend/home_pages/home_page.dart' as brokeo_split;
// import 'package:brokeo/frontend/analytics_pages/analytics_page.dart';

// class SplitHistoryPage extends ConsumerStatefulWidget {
//   //final Map<String, dynamic> person;

//   final Map<String, dynamic> split;

//   const SplitHistoryPage({Key? key, required this.split}) : super(key: key);

//   // const SplitHistoryPage({Key? key, required this.split}) : super(key: key);

//   //const SplitHistoryPage({Key? key, required this.person}) : super(key: key);

//   @override
//   _SplitHistoryPageState createState() => _SplitHistoryPageState();
// }

// class _SplitHistoryPageState extends ConsumerState<SplitHistoryPage> {
//   int _currentIndex = 3;
//   List<Map<String, dynamic>> transactions = [];
//   bool _isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _loadTransactions();
//   }

//   Future<void> _loadTransactions() async {
//     // Sample data - two example transactions
//     final mockTransactions = [
//       {
//         'name': widget.split['name'],
//         'amount': 200.0,
//         'date': '31 Jan\'25, 19:00',
//         'avatarText': widget.split['name'][0]
//       },
//       {
//         'name': widget.split['name'],
//         'amount': -150.0,
//         'date': '30 Jan\'25, 12:30',
//         'avatarText': widget.split['name'][0]
//       },
//     ];

//     await Future.delayed(Duration(seconds: 1)); // Simulate network delay

//     setState(() {
//       transactions = mockTransactions;
//       _isLoading = false;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final totalOwed = transactions.fold<double>(
//       0,
//       (sum, transaction) => sum + transaction['amount'],
//     );

//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: Text(widget.split['name'], style: TextStyle(fontSize: 24)),
//         centerTitle: true,
//       ),
//       body: _isLoading
//           ? Center(child: CircularProgressIndicator())
//           : Column(
//               children: [
//                 // "You owe", "owes you", or "Settled" message below app bar
//                 Container(
//                   padding: EdgeInsets.symmetric(
//                     horizontal: 10, // More horizontal padding
//                     vertical: 4, // Less vertical padding
//                   ),
//                   child: Center(
//                     child: Text(
//                       totalOwed > 0
//                           ? 'You owe ${widget.split['name']} ₹${totalOwed.abs().toStringAsFixed(2)}'
//                           : totalOwed < 0
//                               ? '${widget.split['name']} owes you ₹${totalOwed.abs().toStringAsFixed(2)}'
//                               : 'Settled',
//                       style: TextStyle(
//                         fontSize: 17,
//                         fontWeight: FontWeight.bold,
//                         color: totalOwed > 0
//                             ? Colors.red
//                             : totalOwed < 0
//                                 ? Colors.green
//                                 : Colors.black, // Neutral color for "Settled"
//                       ),
//                     ),
//                   ),
//                 ),
//                 // Action buttons
//                 Padding(
//                   padding: EdgeInsets.symmetric(
//                     horizontal: 16, // More horizontal padding
//                     vertical: 4, // Less vertical padding
//                   ),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                     children: [
//                       ElevatedButton(
//                         onPressed: () => _showSettleUpConfirmation(context, totalOwed),
//                         child: Text('Settle Up'),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.purple,
//                           foregroundColor: Colors.white,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),

//                 // Transaction list
//                 Expanded(
//                   child: ListView.separated(
//                     padding: EdgeInsets.zero,
//                     itemCount: transactions.length,
//                     itemBuilder: (context, index) {
//                       final reversedIndex = transactions.length - 1 - index;
//                       final transaction = transactions[reversedIndex];
//                       final isPositive = transaction['amount'] > 0;
//                       return InkWell(
//                         onTap: () {},
//                         child: Container(
//                           padding: const EdgeInsets.symmetric(
//                               vertical: 5, horizontal: 12),
//                           child: Row(
//                             children: [
//                               CircleAvatar(
//                                 radius: 20,
//                                 backgroundColor: Colors.purple[100],
//                                 child: Text(
//                                   transaction['avatarText'],
//                                   style: TextStyle(
//                                     color: Colors.purple,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                               ),
//                               SizedBox(width: 16),
//                               Expanded(
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Row(
//                                       mainAxisAlignment: MainAxisAlignment
//                                           .spaceBetween, // Aligns name & amount like _buildBalanceRow
//                                       children: [
//                                         Text(
//                                           transaction['name'],
//                                           style: TextStyle(
//                                             // Matches label style
//                                             fontSize: 16,
//                                             color: Colors
//                                                 .black, // Black text for name
//                                           ),
//                                         ),
//                                         Text(
//                                           '₹${transaction['amount'].abs().toStringAsFixed(2)}',
//                                           style: TextStyle(
//                                             color: isPositive
//                                                 ? Colors.green
//                                                 : Colors.red,
//                                             fontSize:
//                                                 17, // Matches amount style
//                                             fontWeight: FontWeight
//                                                 .w600, // Bold like _buildBalanceRow
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                     SizedBox(
//                                         height:
//                                             4), // Small spacing between name and date
//                                     Text(
//                                       transaction['date'],
//                                       style: TextStyle(
//                                         color: Colors.grey.shade600,
//                                         fontSize: 14,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       );
//                     },
//                     separatorBuilder: (context, index) => Divider(
//                       height: 1,
//                       color: Colors.grey.shade300,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//       bottomNavigationBar: buildBottomNavigationBar(),
//     );
//   }

//   Widget buildBottomNavigationBar() {
//     return BottomNavigationBar(
//       currentIndex: _currentIndex,
//       onTap: (index) {
//         if (index != _currentIndex) {
//           setState(() {
//             _currentIndex = index;
//           });
//         }
//         if (index == 0) {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) =>
//                   brokeo_split.HomePage(name: "Darshan", budget: 5000),
//             ),
//           );
//         } else if (index == 1) {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => CategoriesPage(),
//             ),
//           );
//         } else if (index == 2) {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => AnalyticsPage(),
//             ),
//           );
//         }
//       },
//       type: BottomNavigationBarType.fixed,
//       selectedItemColor: Colors.purple,
//       unselectedItemColor: Colors.grey,
//       iconSize: 24,
//       selectedFontSize: 12,
//       unselectedFontSize: 12,
//       items: [
//         BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
//         BottomNavigationBarItem(icon: Icon(Icons.list), label: "Transactions"),
//         BottomNavigationBarItem(
//             icon: Icon(Icons.analytics), label: "Analytics"),
//         BottomNavigationBarItem(icon: Icon(Icons.people), label: "Split"),
//       ],
//     );
//   }

//   // Shows a dialog/popup to add a new transaction
//   void _showAddTransactionDialog(BuildContext context) {
//     // Create variables to store the form data:
//     final _formKey =
//         GlobalKey<FormState>(); // Key to identify and validate form
//     String amount = ''; // Will store the transaction amount
//     DateTime? selectedDate; // Will store selected date
//     TimeOfDay? selectedTime; // Will store selected time
//     String type = 'You Owe'; // Default transaction type

//     // Helper function to show date picker dialog
//     Future<void> _selectDate(BuildContext context) async {
//       final DateTime? picked = await showDatePicker(
//         context: context,
//         initialDate: DateTime.now(), // Default to current date
//         firstDate: DateTime(2000), // Earliest allowed date
//         lastDate: DateTime(2100), // Latest allowed date
//       );
//       if (picked != null) {
//         selectedDate = picked; // Save selected date
//       }
//     }

//     // Helper function to show time picker dialog
//     Future<void> _selectTime(BuildContext context) async {
//       final TimeOfDay? picked = await showTimePicker(
//         context: context,
//         initialTime: TimeOfDay.now(), // Default to current time
//       );
//       if (picked != null) {
//         selectedTime = picked; // Save selected time
//       }
//     }

//     // Actually show the dialog using showDialog()
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return StatefulBuilder(
//           builder: (context, setState) {
//             return AlertDialog(
//               title: Text(
//                 'Add Transaction',
//                 style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//               ),
//               content: Form(
//                 key: _formKey,
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min, // Keep dialog compact
//                   children: [
//                     // Amount input field
//                     TextFormField(
//                       decoration: InputDecoration(
//                         labelText: "Amount",
//                         prefixText: "₹", // Indian Rupee symbol
//                         border: OutlineInputBorder(), // Styled border
//                       ),
//                       keyboardType:
//                           TextInputType.numberWithOptions(decimal: true),
//                       inputFormatters: [
//                         // Only allow numbers with optional decimal point
//                         FilteringTextInputFormatter.allow(
//                             RegExp(r'^\d+\.?\d{0,2}')),
//                       ],
//                       validator: (value) {
//                         // Validation rules:
//                         if (value == null || value.isEmpty) {
//                           return 'Please enter amount';
//                         }
//                         if (double.tryParse(value) == null) {
//                           return 'Enter valid amount';
//                         }
//                         if (double.parse(value) <= 0) {
//                           return 'Amount must be positive';
//                         }
//                         return null; // No error
//                       },
//                       onChanged: (value) => amount = value,
//                     ),
//                     SizedBox(height: 16), // Add spacing between fields

//                     // Date and Time row
//                     Row(
//                       children: [
//                         // Date picker field
//                         Expanded(
//                           child: InkWell(
//                             onTap: () => _selectDate(context)
//                                 .then((_) => setState(() {})),
//                             child: InputDecorator(
//                               decoration: InputDecoration(
//                                 labelText: "Date",
//                                 border: OutlineInputBorder(),
//                               ),
//                               child: Text(
//                                 selectedDate != null
//                                     ? DateFormat('dd/MM/yyyy')
//                                         .format(selectedDate!)
//                                     : 'Select date',
//                               ),
//                             ),
//                           ),
//                         ),
//                         SizedBox(width: 16), // Spacing between date and time
//                         // Time picker field
//                         Expanded(
//                           child: InkWell(
//                             onTap: () => _selectTime(context)
//                                 .then((_) => setState(() {})),
//                             child: InputDecorator(
//                               decoration: InputDecoration(
//                                 labelText: "Time",
//                                 border: OutlineInputBorder(),
//                               ),
//                               child: Text(
//                                 selectedTime != null
//                                     ? selectedTime!.format(context)
//                                     : 'Select time',
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                     SizedBox(height: 16),

//                     // Transaction type dropdown
//                     DropdownButtonFormField<String>(
//                       value: type,
//                       decoration: InputDecoration(
//                         labelText: "Type",
//                         border: OutlineInputBorder(),
//                       ),
//                       items: ['You Owe', 'You Are Owed'].map((String value) {
//                         return DropdownMenuItem<String>(
//                           value: value,
//                           child: Text(value),
//                         );
//                       }).toList(),
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return 'Please select type';
//                         }
//                         return null;
//                       },
//                       onChanged: (value) {
//                         setState(() {
//                           type = value!;
//                         });
//                       },
//                     ),
//                   ],
//                 ),
//               ),
//               // Dialog action buttons
//               actions: [
//                 // Cancel button
//                 TextButton(
//                   onPressed: () => Navigator.pop(context),
//                   child: Text(
//                     'Cancel',
//                     style: TextStyle(color: Colors.grey),
//                   ),
//                 ),
//                 // Confirm button
//                 ElevatedButton(
//                   onPressed: () {
//                     // Validate all form fields
//                     if (_formKey.currentState!.validate()) {
//                       // Check date/time were selected
//                       if (selectedDate == null) {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                             SnackBar(content: Text('Please select date')));
//                         return;
//                       }
//                       if (selectedTime == null) {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                             SnackBar(content: Text('Please select time')));
//                         return;
//                       }

//                       // In a real app, this would save to database
//                       print('''
//                       New Transaction:
//                       Amount: ₹${double.parse(amount).toStringAsFixed(2)}
//                       Type: $type
//                       Date: ${DateFormat('dd/MM/yyyy').format(selectedDate!)}
//                       Time: ${selectedTime!.format(context)}
//                       ''');

//                       Navigator.pop(context); // Close dialog
//                     }
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color.fromARGB(255, 97, 53, 186),
//                   ),
//                   child: Text(
//                     'Confirm',
//                     style: TextStyle(color: Colors.white),
//                   ),
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     );
//   }

//   // Shows confirmation dialog when settling up
//   void _showSettleUpConfirmation(BuildContext context, double totalOwed) {
//     final _formKey = GlobalKey<FormState>();
//     String settleAmount = totalOwed.abs().toStringAsFixed(2);

//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text(
//             'Settle Up',
//             style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//           ),
//           content: Form(
//             key: _formKey,
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 TextFormField(
//                   initialValue: settleAmount,
//                   decoration: InputDecoration(
//                     labelText: "Amount",
//                     prefixText: "₹",
//                     border: OutlineInputBorder(),
//                   ),
//                   keyboardType: TextInputType.numberWithOptions(decimal: true),
//                   inputFormatters: [
//                     FilteringTextInputFormatter.allow(RegExp(r'^-?\d+\.?\d{0,2}')),
//                   ],
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter an amount';
//                     }
//                     if (double.tryParse(value) == null) {
//                       return 'Enter a valid amount';
//                     }
//                     return null;
//                   },
//                   onChanged: (value) => settleAmount = value,
//                 ),
//                 SizedBox(height: 16),
//                 Text(
//                   'Current balance: ₹${totalOwed.toStringAsFixed(2)}',
//                   style: TextStyle(color: Colors.grey),
//                 ),
//               ],
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: Text(
//                 'Cancel',
//                 style: TextStyle(color: Colors.grey),
//               ),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 if (_formKey.currentState!.validate()) {
//                   final enteredAmount = double.parse(settleAmount);
//                   final newBalance = totalOwed - enteredAmount;

//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(
//                       content: Text(
//                         newBalance > 0
//                             ? 'You owe ₹${newBalance.toStringAsFixed(2)}'
//                             : newBalance < 0
//                                 ? '${widget.split['name']} owes you ₹${newBalance.abs().toStringAsFixed(2)}'
//                                 : 'You are settled up with ${widget.split['name']}',
//                       ),
//                     ),
//                   );

//                   setState(() {
//                     transactions.add({
//                       'name': widget.split['name'],
//                       'amount': -enteredAmount,
//                       'date': DateFormat('dd MMM\'yy, HH:mm').format(DateTime.now()),
//                       'avatarText': widget.split['name'][0],
//                     });
//                   });

//                   Navigator.pop(context);
//                 }
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color.fromARGB(255, 97, 53, 186),
//               ),
//               child: Text(
//                 'Confirm',
//                 style: TextStyle(color: Colors.white),
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }
