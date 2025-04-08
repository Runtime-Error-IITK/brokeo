class ScheduledPayment {
  final String merchant;
  final double recurringAmount;
  final DateTime startDate;
  final String recurringPeriod;

  ScheduledPayment({
    required this.merchant,
    required this.recurringAmount,
    required this.startDate,
    required this.recurringPeriod,
  });
}
