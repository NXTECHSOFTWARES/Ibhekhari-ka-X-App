import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ibhekhari_ka_x_app/presentation/screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
    designSize: const Size(412, 917),
    builder:(_, child) =>
        MaterialApp(
          debugShowCheckedModeBanner: false,
          home: child,
        ),
  child: const MyHomeScreen(),
    );
  }
}


