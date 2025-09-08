import 'package:flutter/material.dart';
import 'package:nxbakers/Common/Widgets/reusable_text_widget.dart';

class ToastMessage extends StatelessWidget {
  final String message;
  const ToastMessage({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return SnackBar(
          backgroundColor: Colors.white,
          content: ReusableTextWidget(
            text: message,
            color: Colors.black,
            size: 10,
          ),
    );
  }
}
