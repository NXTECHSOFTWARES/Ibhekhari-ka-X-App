import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nxbakers/Domain/Services/background_task_service.dart';
import 'package:nxbakers/Presentation/pages/Notifications/notifications.dart';
import 'package:nxbakers/Presentation/pages/Pastries/pastries.dart';
import 'package:nxbakers/Presentation/pages/Pastries/pastry_details.dart';

import 'Domain/Services/notification_service.dart';
import 'Domain/Services/stock_monitor_service.dart';
import 'Presentation/pages/Dashboard/dashboard.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize notification service
  final notificationService = NotificationService();
  await notificationService.initialize();
  await notificationService.requestPermissions();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final StockMonitorService _stockMonitor = StockMonitorService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Check stock on app start
    _checkStockLevels();

    // Start periodic checks (every 30 minutes)
    BackgroundTaskService().startPeriodicStockCheck();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Check stock when app comes to foreground
    if (state == AppLifecycleState.resumed) {
      _checkStockLevels();
    }
  }

  Future<void> _checkStockLevels() async {
    await _stockMonitor.checkLowStockPastries();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(420, 890),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'NX Bakers',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
            useMaterial3: true,
          ),
          home: const Dashboard(),
          routes: {
            '/notifications': (context) => const NotificationsPage(),
            '/list_of_pastries': (context) => const PastriesPage(),
            // '/pastry_details': (context) => const PastryDetails(),
          },
        );
      },
    );
  }
}

class NotificationNavigationHandler {
  static final NotificationNavigationHandler _instance =
  NotificationNavigationHandler._internal();
  factory NotificationNavigationHandler() => _instance;
  NotificationNavigationHandler._internal();

  // Callback for navigation
  void Function(int pastryId, String pastryName)? onPastryNotificationTapped;

  void handleNotificationNavigation(String? payload) {
    if (payload == null) return;

    final parts = payload.split(':');
    if (parts.length >= 2) {
      final type = parts[0];
      final pastryId = int.tryParse(parts[1]) ?? 0;
      final pastryName = parts.length > 2 ? parts[2] : '';

      switch (type) {
        case 'low_stock':
        case 'restock':
        case 'reminder':
          if (onPastryNotificationTapped != null && pastryId > 0) {
            onPastryNotificationTapped!(pastryId, pastryName);
          }
          break;
        case 'summary':
        // Navigate to notifications page
          break;
      }
    }
  }
}