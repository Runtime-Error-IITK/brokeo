import 'package:flutter/material.dart';
import 'package:brokeo/models/scheduled_payment_model.dart';
import 'package:intl/intl.dart';

class ScheduledPaymentDetailPage extends StatelessWidget {
  final ScheduledPayment payment;

  const ScheduledPaymentDetailPage({Key? key, required this.payment}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Changed title to Scheduled Payment
        title: Text("Scheduled Payment"),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Merchant with category icon on the right of the merchant name
            Text(
              "Merchant",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                Text(
                  payment.merchant,
                  style: TextStyle(fontSize: 24), // removed bold
                ),
                SizedBox(width: 8),
                Icon(Icons.category, color: Colors.purple), // category icon moved to right
              ],
            ),
            SizedBox(height: 20),
            // Recurring Amount
            Text(
              "Recurring Amount",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              "₹${payment.recurringAmount.toStringAsFixed(0)}",
              style: TextStyle(fontSize: 24), // removed bold
            ),
            // Show amount in words like in transaction detail page
            Text(
              "${_convertNumberToWords(payment.recurringAmount.toInt())} Rupees Only",
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            SizedBox(height: 20),
            // Start Date with new format
            Text(
              "Start Date",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              _formatDate(payment.startDate),
              style: TextStyle(fontSize: 24), // removed bold
            ),
            SizedBox(height: 20),
            // Recurring Time Period
            Text(
              "Recurring Time Period",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              payment.recurringPeriod,
              style: TextStyle(fontSize: 24), // removed bold
            ),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _showEditPaymentDialog(context, payment);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    foregroundColor: Colors.black,
                  ),
                  child: Text("Edit Payment"),
                ),
                ElevatedButton(
                  onPressed: () {
                    _showDeleteConfirmationDialog(context, payment);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: Text("Delete Payment"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showEditPaymentDialog(BuildContext context, ScheduledPayment payment) {
    final TextEditingController amountController = 
        TextEditingController(text: payment.recurringAmount.toString());
    final List<String> merchantNames = ["Chetan Singh", "Darshan", "Anjali Patra"];
    String? selectedMerchant = payment.merchant;
    DateTime selectedDate = payment.startDate;
    TimeOfDay selectedTime = TimeOfDay.fromDateTime(payment.startDate);
    String selectedRecurringPeriod = payment.recurringPeriod;
    final periodOptions = ["Daily", "Weekly", "Monthly", "Yearly"];
    
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Edit Scheduled Payment"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Merchant Dropdown
                    DropdownButtonFormField<String>(
                      value: selectedMerchant,
                      decoration: InputDecoration(labelText: "Merchant"),
                      items: merchantNames
                          .map((name) => DropdownMenuItem(
                                value: name,
                                child: Text(name),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedMerchant = value;
                        });
                      },
                    ),
                    SizedBox(height: 12),
                    // Recurring Amount TextField
                    TextFormField(
                      controller: amountController,
                      decoration: InputDecoration(
                        labelText: "Recurring Amount",
                        prefixText: "₹",
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 12),
                    // Start Date Picker
                    InkWell(
                      onTap: () async {
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setState(() {
                            selectedDate = picked;
                          });
                        }
                      },
                      child: InputDecorator(
                        decoration: InputDecoration(labelText: "Start Date"),
                        child: Text(DateFormat('yyyy-MM-dd').format(selectedDate)),
                      ),
                    ),
                    SizedBox(height: 12),
                    // Start Time Picker
                    InkWell(
                      onTap: () async {
                        TimeOfDay? picked = await showTimePicker(
                          context: context,
                          initialTime: selectedTime,
                        );
                        if (picked != null) {
                          setState(() {
                            selectedTime = picked;
                          });
                        }
                      },
                      child: InputDecorator(
                        decoration: InputDecoration(labelText: "Start Time"),
                        child: Text(selectedTime.format(context)),
                      ),
                    ),
                    SizedBox(height: 12),
                    // Recurring Period Dropdown
                    DropdownButtonFormField<String>(
                      value: selectedRecurringPeriod,
                      decoration: InputDecoration(labelText: "Recurring Period"),
                      items: periodOptions
                          .map((p) => DropdownMenuItem(
                                value: p,
                                child: Text(p),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            selectedRecurringPeriod = value;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Cancel"),
                ),
                TextButton(
                  onPressed: () {
                    // Compute updated next due date using both selectedDate and selectedTime.
                    DateTime combinedDateTime = DateTime(
                      selectedDate.year,
                      selectedDate.month,
                      selectedDate.day,
                      selectedTime.hour,
                      selectedTime.minute,
                    );
                    DateTime nextDueDate = combinedDateTime;
                    while (nextDueDate.isBefore(DateTime.now())) {
                      if (selectedRecurringPeriod == "Daily") {
                        nextDueDate = nextDueDate.add(Duration(days: 1));
                      } else if (selectedRecurringPeriod == "Weekly") {
                        nextDueDate = nextDueDate.add(Duration(days: 7));
                      } else if (selectedRecurringPeriod == "Monthly") {
                        nextDueDate = nextDueDate.add(Duration(days: 30));
                      } else if (selectedRecurringPeriod == "Yearly") {
                        nextDueDate = nextDueDate.add(Duration(days: 365));
                      }
                    }
                    print("Updated Merchant: $selectedMerchant, Amount: ${amountController.text}, "
                        "Start Date: ${DateFormat('yyyy-MM-dd').format(selectedDate)}, "
                        "Start Time: ${selectedTime.format(context)}, "
                        "Recurring Period: $selectedRecurringPeriod, "
                        "Next Due Date: ${DateFormat('yyyy-MM-dd').format(nextDueDate)}");
                    Navigator.pop(context);
                  },
                  child: Text("Confirm"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, ScheduledPayment payment) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Delete Scheduled Payment"),
          content: Text("Are you sure you want to delete this scheduled payment?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                // Implement the delete scheduled payment logic
                Navigator.pop(context);
              },
              child: Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}

// Helper function to convert a number to words (basic implementation)
String _convertNumberToWords(int number) {
  if (number == 0) return "Zero";
  final ones = [
    "", "One", "Two", "Three", "Four", "Five", "Six", "Seven", "Eight", "Nine",
    "Ten", "Eleven", "Twelve", "Thirteen", "Fourteen", "Fifteen", "Sixteen",
    "Seventeen", "Eighteen", "Nineteen"
  ];
  final tens = [
    "", "", "Twenty", "Thirty", "Forty", "Fifty", "Sixty", "Seventy", "Eighty", "Ninety"
  ];

  String convert(int n) {
    if (n < 20) return ones[n];
    else if (n < 100) return tens[n ~/ 10] + (n % 10 != 0 ? " " + ones[n % 10] : "");
    else if (n < 1000) return ones[n ~/ 100] + " Hundred" + (n % 100 != 0 ? " " + convert(n % 100) : "");
    else return ones[n ~/ 1000] + " Thousand" + (n % 1000 != 0 ? " " + convert(n % 1000) : "");
  }
  return convert(number).trim();
}

// Helper function to format a date as "3rd March 2025"
String _formatDate(DateTime dt) {
  int day = dt.day;
  String suffix;
  if (day >= 11 && day <= 13) {
    suffix = "th";
  } else {
    switch (day % 10) {
      case 1:
        suffix = "st";
        break;
      case 2:
        suffix = "nd";
        break;
      case 3:
        suffix = "rd";
        break;
      default:
        suffix = "th";
        break;
    }
  }
  String dayStr = "$day$suffix";
  String monthYear = DateFormat("MMMM yyyy").format(dt);
  return "$dayStr $monthYear";
}
