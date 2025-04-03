// import 'package:brokeo/frontend/transactions_pages/categories_page.dart';
// import 'package:flutter/material.dart';
// import 'package:brokeo/frontend/split_pages/choose_transactions.dart';
// import 'package:brokeo/frontend/home_pages/home_page.dart' as brokeo_split;
// import 'package:brokeo/frontend/split_pages/split_history.dart';
// import 'package:brokeo/frontend/analytics_pages/analytics_page.dart';
// import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:flutter/material.dart';

class ManageSplitsPage extends StatelessWidget {
  const ManageSplitsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text("Hello");
  }
}

// class ManageSplitsPage extends ConsumerStatefulWidget {
//   @override
//   _ManageSplitsPageState createState() => _ManageSplitsPageState();
// }

// class _ManageSplitsPageState extends ConsumerState<ManageSplitsPage> {
//   int _currentIndex = 3;
//   List<brokeo_split.Split> splits =
//       []; // Now using Split model instead of raw data

//   @override
//   void initState() {
//     super.initState();
//     _loadSplits(); // Load data when widget initializes
//   }

//   Future<void> _loadSplits() async {
//     // Simulated data - replace with your actual data fetching logic
//     final mockData = [
//       {"name": "Chetan Singh", "amount": 50.0, "isSettled": false},
//       {"name": "Darshan", "amount": 510.0, "isSettled": false},
//       {"name": "Chinmay Jain", "amount": 75.0, "isSettled": false},
//       {"name": "Aryan Kumar", "amount": 25.0, "isSettled": false},
//       {"name": "Suryansh Verma", "amount": 160.0, "isSettled": false},
//       {"name": "Anjali Patra", "amount": 1200.0, "isSettled": false},
//       {"name": "Rudransh Verma", "amount": 0.0, "isSettled": true},
//       {"name": "Moni Sinha", "amount": 50.0, "isSettled": false},
//       {"name": "Sanjina S", "amount": 1.0, "isSettled": false},
//       {"name": "Prem Bhardwaj", "amount": 3180.0, "isSettled": false},
//       {"name": "Prem Bhardwaj", "amount": 3180.0, "isSettled": false},
//       {"name": "Prem Bhardwaj", "amount": 3180.0, "isSettled": false},
//       {"name": "Prem Bhardwaj", "amount": 3180.0, "isSettled": false},
//       {"name": "Prem afeafa", "amount": 3180.0, "isSettled": false},
//     ];

//     // Convert raw data to Split objects

//     setState(() {
//       splits =
//           mockData.map((item) => brokeo_split.Split.fromMap(item)).toList();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       //backgroundColor: Color.fromARGB(255, 255, 247, 254),
//       body: ListView.separated(
//         padding: const EdgeInsets.symmetric(horizontal: 16.0), // Added horizontal padding
//         itemCount: splits.length + 2, // increased count: spacer + summary card + splits
//         itemBuilder: (context, index) {
//           if (index == 0) {
//             return const SizedBox(height: 20); // Spacer to lower the summary card
//           } else if (index == 1) {
//             // Summary Card moved to be scrollable
//             return Container(
//               margin: const EdgeInsets.all(16.0),
//               decoration: BoxDecoration(
//                 color: const Color.fromARGB(255, 245, 210, 245),
//                 borderRadius: BorderRadius.circular(16.0),
//                 boxShadow: [
//                   BoxShadow(
//                     color: const Color.fromARGB(255, 237, 155, 219).withOpacity(0.2),
//                     blurRadius: 8,
//                     spreadRadius: 1,
//                     offset: const Offset(0, 4),
//                   ),
//                 ],
//               ),
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 children: [
//                   _buildBalanceRow(
//                     label: "Total Balance",
//                     amount: 1441,
//                     amountColor: Colors.green[800]!,
//                   ),
//                   const Divider(
//                     height: 24,
//                     color: Colors.black54,
//                     thickness: 0.75,
//                   ),
//                   _buildBalanceRow(
//                     label: "You Owe",
//                     amount: 200,
//                     amountColor: Colors.red[800]!,
//                   ),
//                   const SizedBox(height: 12),
//                   _buildBalanceRow(
//                     label: "You Are Owed",
//                     amount: 1641,
//                     amountColor: Colors.green[800]!,
//                   ),
//                 ],
//               ),
//             );
//           } else {
//             final split = splits[index - 2];
//             // ...existing code for split tile...
//             return _buildSplitTile(split);
//           }
//         },
//         separatorBuilder: (context, index) => Divider(
//           color: Colors.grey[300],
//         ),
//       ),
//       floatingActionButton: _currentIndex == 3
//           ? FloatingActionButton(
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                       builder: (context) => ChooseTransactionPage()),
//                 );
//               },
//               child: const Icon(Icons.add, color: Colors.white),
//               backgroundColor: const Color.fromARGB(
//                   255, 97, 53, 186), // Your exact purple color
//               shape: const CircleBorder(),
//             )
//           : null,
//       bottomNavigationBar: buildBottomNavigationBar(),
//     );
//   }

//   Widget _buildBalanceRow({
//     required String label,
//     required double amount,
//     required Color amountColor,
//   }) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(
//           label,
//           style: const TextStyle(
//             fontSize: 16,
//             color: Colors.black, // Black text for labels
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//         Text(
//           "₹${amount.toStringAsFixed(2)}",
//           style: TextStyle(
//             fontSize: 17,
//             fontWeight: FontWeight.w600,
//             color: amountColor, // Green/red for amounts
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildSplitTile(brokeo_split.Split split) {
//     return InkWell(
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => SplitHistoryPage(split: split.toMap()),
//           ),
//         );
//       },
//       child: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.symmetric(vertical: 5),
//             child: Row(
//               children: [
//                 CircleAvatar(
//                   backgroundColor: Colors.purple[100],
//                   child: Text(
//                     split.name[0],
//                     style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       color: Colors.purple,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         split.name,
//                         style: TextStyle(
//                           fontSize: 14,
//                           color: Colors.black87,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Text(
//                   "₹${split.amount.abs()}",
//                   style: TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.bold,
//                     color: split.amount < 0 ? Colors.red : Colors.green,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
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
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(
//               builder: (context) =>
//                   brokeo_split.HomePage(name: "Darshan", budget: 5000),
//             ),
//           );
//         } else if (index == 1) {
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(
//               builder: (context) => CategoriesPage(),
//             ),
//           );
//         } else if (index == 2) {
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(
//               builder: (context) => AnalyticsPage(),
//             ),
//           );
//         } else if (index == 3) {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => ManageSplitsPage(),
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
// }
