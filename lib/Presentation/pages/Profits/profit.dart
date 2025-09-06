import 'package:flutter/material.dart';
import 'package:nxbakers/Common/common_main.dart';

class ProfitPage extends StatelessWidget {
  const ProfitPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(  body: CommonMain(child: Center(child: Text("Profit Summary", style: TextStyle(color: Colors.black),),)),);
  }
}
