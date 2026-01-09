import 'package:flutter/material.dart';

class CommonMain extends StatelessWidget {
  final Widget child;
  const CommonMain({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      width: size.width,
      height: size.height,
      color: const Color.fromRGBO(242, 234, 222, 1.0),
      child: Container(
        width: size.width,
        height: size.height,
          decoration: const BoxDecoration(
        color: Color.fromRGBO(0, 0, 0, 0.1),
      ),
      child: SafeArea(bottom:false, child: child)),
    );
  }
}
