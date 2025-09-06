import 'package:flutter/material.dart';
import 'package:nxbakers/Common/common_main.dart';

class IngredientsPage extends StatelessWidget {
  const IngredientsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CommonMain(child: Center(child: Text("List Of Ingredients", style: TextStyle(color: Colors.black),),)),
    );
  }
}
