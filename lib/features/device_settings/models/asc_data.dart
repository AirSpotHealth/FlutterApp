class AscData {
  final int count;
  final int correction;

  AscData({
    this.count = 0,
    this.correction = 0,
  });

  AscData copyWith({
    int? count,
    int? correction,
  }) {
    return AscData(
      count: count ?? this.count,
      correction: correction ?? this.correction,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AscData &&
        other.count == count &&
        other.correction == correction;
  }

  @override
  int get hashCode => count.hashCode ^ correction.hashCode;

  @override
  String toString() => 'AscData(count: $count, correction: $correction)';
}
