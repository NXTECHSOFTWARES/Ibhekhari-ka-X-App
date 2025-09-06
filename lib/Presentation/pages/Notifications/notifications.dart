import 'package:flutter/material.dart';
import 'package:nxbakers/Common/common_main.dart';
import 'package:nxbakers/Common/Widgets/reusable_text_widget.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      ),
      body: CommonMain(child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ReusableTextWidget(text: "Notifications", color: Colors.grey.shade600, size: 18),
        ],
      )),
    );
  }
}
