import 'dart:async';
import 'package:nxbakers/Domain/Services/stock_monitor_service.dart';

class BackgroundTaskService {
  static final BackgroundTaskService _instance = BackgroundTaskService._internal();
  factory BackgroundTaskService() => _instance;
  BackgroundTaskService._internal();

  Timer? _stockCheckTimer;
  final StockMonitorService _monitor = StockMonitorService();

  // Start periodic stock checking (every 30 minutes)
  void startPeriodicStockCheck({Duration interval = const Duration(minutes: 30)}) {
    stopPeriodicStockCheck(); // Stop existing timer if any

    _stockCheckTimer = Timer.periodic(interval, (timer) async {
      try {
        await _monitor.checkLowStockPastries();
      } catch (e) {
        print('Background stock check error: $e');
      }
    });
  }

  // Stop periodic checking
  void stopPeriodicStockCheck() {
    _stockCheckTimer?.cancel();
    _stockCheckTimer = null;
  }

  // Check immediately
  Future<void> checkNow() async {
    try {
      await _monitor.checkLowStockPastries();
    } catch (e) {
      print('Manual stock check error: $e');
    }
  }
}