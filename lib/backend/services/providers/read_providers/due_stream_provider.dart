class DueFilter {
  final String? dueId;
  final String? merchantId;
  final String? categoryId;

  const DueFilter({this.dueId, this.merchantId, this.categoryId});

  @override
  bool operator ==(Object other) {
    return other is DueFilter &&
        other.dueId == dueId &&
        other.merchantId == merchantId &&
        other.categoryId == categoryId;
  }

  @override
  int get hashCode =>
      (dueId ?? '').hashCode ^
      (merchantId ?? '').hashCode ^
      (categoryId ?? '').hashCode;
}
