class IncomePrediction {
  final DateTime month;
  final double predictedAmount;
  final double confidence; // 0.0 to 1.0
  final double changePercentage; // Compared to previous month
  final String reason;
  final List<double> historicalData;

  IncomePrediction({
    required this.month,
    required this.predictedAmount,
    required this.confidence,
    required this.changePercentage,
    required this.reason,
    required this.historicalData,
  });

  bool get isIncrease => changePercentage > 0;
  bool get isDecrease => changePercentage < 0;

  String get confidenceLevel {
    if (confidence >= 0.8) return 'High';
    if (confidence >= 0.6) return 'Medium';
    return 'Low';
  }

  String get trendDescription {
    if (changePercentage.abs() < 2) return 'Stable';
    if (isIncrease) return 'Increasing';
    return 'Decreasing';
  }
}
