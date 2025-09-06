import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nxbakers/Common/common_main.dart';
import 'package:nxbakers/Common/common_page_header.dart';

class DailyInventoryEntry extends StatefulWidget {
  const DailyInventoryEntry({super.key});

  @override
  State<DailyInventoryEntry> createState() => _DailyInventoryEntryState();
}

class _DailyInventoryEntryState extends State<DailyInventoryEntry> {
  @override
  Widget build(BuildContext context) {
    return CommonMain(
        child: Column(
      children: [
        Container(
          height: 115.h,
          color: const Color(0xffF2EADE),
          padding: EdgeInsets.only(bottom: 15.h),
          child: Column(
            children: [
              Expanded(child: Container()),
              CommonPageHeader(
                  pageTitle: "Daily Entries",
                  pageSubTitle: "A List of all sales Entries",
                  addViewModel: ChangeNotifier(),
                  addNavPage: Container()),
            ],
          ),
        )
      ],
    ));
  }
}
