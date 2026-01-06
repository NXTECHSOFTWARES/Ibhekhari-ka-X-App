class SalesStats {
  final String period;
  final double revenue;
  final int itemsSold;
  final int transactions;
  final double growthRate; // percentage

  SalesStats({
    required this.period,
    required this.revenue,
    required this.itemsSold,
    required this.transactions,
    required this.growthRate,
  });
}

class PastryPerformance {
  final String pastryName;
  final int totalSold;
  final double revenue;
  final double growthRate;
  final int frequency; // how many times it was sold

  PastryPerformance({
    required this.pastryName,
    required this.totalSold,
    required this.revenue,
    required this.growthRate,
    required this.frequency,
  });
}

class DailySalesData {
  final DateTime date;
  final double revenue;
  final int itemsSold;
  final bool isGoodDay; // based on threshold

  DailySalesData({
    required this.date,
    required this.revenue,
    required this.itemsSold,
    required this.isGoodDay,
  });
}