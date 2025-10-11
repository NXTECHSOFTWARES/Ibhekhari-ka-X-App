import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../Presentation/ViewModels/pastry_viewmodel.dart';

class AddButton extends StatelessWidget {
  final Widget addNavPage;
  final ChangeNotifier addViewModel;
  const AddButton({super.key, required this.addNavPage,  required this.addViewModel,});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog<void>(
          context: context,
          builder: (BuildContext dialogContext) {
            return ChangeNotifierProvider(
                create: (BuildContext context) =>
                    PastryViewModel(),
                child: addNavPage);
          },
        );
      },
      child: Container(
        width: 27.w,
        height: 27.w,
        decoration: BoxDecoration(
          color: const Color(0xff42321C),
          borderRadius: BorderRadius.circular(4.r),
          border: Border.all(
            width: 1.0.w,
            color: const Color(0xffF5E6D2),
            style: BorderStyle.solid,
          ),
        ),
        child: Icon(
          Icons.add,
          color: const Color(0xffF5E6D2),
          size: 24.w,
        ),
      ),
    );
  }
}
