Widget _buildScheduledPayments(List<ScheduledPayment> payments) {
  // If not expanded, only show top 3
  List<ScheduledPayment> paymentsToShow =
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Spacer(),
                IconButton(
                  icon: Icon(Icons.add, size: 22, color: Colors.black54),
                  onPressed: () {
                    // TODO: Handle "Add Scheduled Payment"
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
                      showAllScheduledPayments = !showAllScheduledPayments;
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
                    children: paymentsToShow.asMap().entries.map((entry) {
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
}
