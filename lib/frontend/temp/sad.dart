void _showAddScheduledPaymentDialog() {
  // Retrieve merchants for dropdown
  List<Merchant> merchantsList = MockBackend.getMerchants();
  merchantsList.sort((a, b) => a.name.compareTo(b.name));
  final merchantNames = merchantsList.map((m) => m.name).toList();

  String? selectedMerchant =
      merchantNames.isNotEmpty ? merchantNames.first : null;
  String? recurringAmount;
  DateTime? startDate;
  TimeOfDay? startTime;
  String selectedPeriod = "Monthly"; // default
  final List<String> periodOptions = ["Daily", "Weekly", "Monthly", "Yearly"];

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text("Add Scheduled Payment"),
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
                    decoration: InputDecoration(
                      labelText: "Recurring Amount",
                      prefixText: "₹",
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      recurringAmount = value;
                    },
                  ),
                  SizedBox(height: 12),
                  // Start Date Picker
                  InkWell(
                    onTap: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() {
                          startDate = picked;
                        });
                      }
                    },
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: "Start Date",
                      ),
                      child: Text(
                        startDate != null
                            ? DateFormat('yyyy-MM-dd').format(startDate!)
                            : "Select Date",
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  // Start Time Picker
                  InkWell(
                    onTap: () async {
                      TimeOfDay? picked = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (picked != null) {
                        setState(() {
                          startTime = picked;
                        });
                      }
                    },
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: "Start Time",
                      ),
                      child: Text(
                        startTime != null
                            ? startTime!.format(context)
                            : "Select Time",
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  // Recurring Time Period Dropdown
                  DropdownButtonFormField<String>(
                    value: selectedPeriod,
                    decoration: InputDecoration(labelText: "Recurring Period"),
                    items: periodOptions
                        .map((p) => DropdownMenuItem(
                              value: p,
                              child: Text(p),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedPeriod = value!;
                      });
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
                  print(
                      "Scheduled Payment: Merchant: $selectedMerchant, Amount: $recurringAmount, Date: ${startDate != null ? DateFormat('yyyy-MM-dd').format(startDate!) : 'N/A'}, Time: ${startTime != null ? startTime!.format(context) : 'N/A'}, Period: $selectedPeriod");
                  Navigator.pop(context);
                },
                child: Text("Add"),
              ),
            ],
          );
        },
      );
    },
  );
}
