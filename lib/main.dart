import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nxbakers/Presentation/pages/Notifications/notifications.dart';
import 'package:nxbakers/Presentation/pages/Pastries/pastry_details.dart';

import 'Presentation/pages/dashboard.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 800),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_ , child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          home: child,
          routes: {
            '/notifications': (context) => const NotificationPage(),
           // '/pastry_details': (context) => const PastryDetails(),
          },
        );
      },
      child: const Dashboard(),
    );

  }
}
