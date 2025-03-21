import 'dart:convert';

class Schedule {
  int scheduleId;
  double amount;
  int merchantId;
  int categoryId;
  List<DateTime> dates;
  int timePeriod;

  Schedule({
    required this.scheduleId,
    required this.amount,
    required this.merchantId,
    required this.categoryId,
    required this.dates,
    required this.timePeriod,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Schedule && other.scheduleId == scheduleId;
  }

  @override
  int get hashCode {
    return scheduleId.hashCode;
  }

  @override
  String toString() {
    final jsonDates = jsonEncode(dates);
    return "Schedule{scheduleId: $scheduleId, amount: $amount, merchantId: $merchantId, categoryId: $categoryId, dates: $jsonDates, timePeriod: $timePeriod}";
  }

  factory Schedule.fromDatabaseSchedule(DatabaseSchedule databaseSchedule) {
    final parsedDates = jsonDecode(databaseSchedule.dates) as List<String>;
    return Schedule(
      scheduleId: databaseSchedule.scheduleId,
      amount: databaseSchedule.amount,
      merchantId: databaseSchedule.merchantId,
      categoryId: databaseSchedule.categoryId,
      dates: parsedDates.map((date) => DateTime.parse(date)).toList(),
      timePeriod: databaseSchedule.timePeriod,
    );
  }

  factory Schedule.fromJson(String json) {
    Map<String, dynamic> decodedJson = jsonDecode(json) as Map<String, dynamic>;
    return Schedule(
      scheduleId: decodedJson[scheduleIdColumn] as int,
      amount: decodedJson[amountColumn] as double,
      merchantId: decodedJson[merchantIdColumn] as int,
      categoryId: decodedJson[categoryIdColumn] as int,
      dates: List<DateTime>.from(decodedJson[datesColumn] as List),
      timePeriod: decodedJson[timePeriodColumn] as int,
    );
  }
  String toJson() {
    //return json string

    return jsonEncode({
      scheduleIdColumn: scheduleId,
      amountColumn: amount,
      merchantIdColumn: merchantId,
      categoryIdColumn: categoryId,
      datesColumn: dates.map((date) => date.toIso8601String()).toList(),
      timePeriodColumn: timePeriod,
    });
  }
}

class DatabaseSchedule {
  int scheduleId;
  double amount;
  int merchantId;
  int categoryId;
  String dates;
  int timePeriod;

  DatabaseSchedule({
    required this.scheduleId,
    required this.amount,
    required this.merchantId,
    required this.categoryId,
    required this.dates,
    required this.timePeriod,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DatabaseSchedule && other.scheduleId == scheduleId;
  }

  @override
  int get hashCode {
    return scheduleId.hashCode;
  }

  factory DatabaseSchedule.fromRow(Map<String, Object?> row) {
    return DatabaseSchedule(
      scheduleId: row[scheduleIdColumn] as int,
      amount: row[amountColumn] as double,
      merchantId: row[merchantIdColumn] as int,
      categoryId: row[categoryIdColumn] as int,
      dates: row[datesColumn] as String,
      timePeriod: row[timePeriodColumn] as int,
    );
  }

  factory DatabaseSchedule.fromSchedule(Schedule schedule) {
    return DatabaseSchedule(
      scheduleId: schedule.scheduleId,
      amount: schedule.amount,
      merchantId: schedule.merchantId,
      categoryId: schedule.categoryId,
      dates: jsonEncode(schedule.dates),
      timePeriod: schedule.timePeriod,
    );
  }

  @override
  String toString() {
    return "Schedule{scheduledId: $scheduleId, amount: $amount, merchantId: $merchantId, categoryId: $categoryId, dates: $dates, timePeriod: $timePeriod}";
  }
}

String scheduleIdColumn = "scheduleId";
String amountColumn = "amount";
String merchantIdColumn = "merchantId";
String categoryIdColumn = "categoryId";
String datesColumn = "dates";
String timePeriodColumn = "timePeriod";
