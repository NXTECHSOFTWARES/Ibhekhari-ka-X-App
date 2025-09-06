import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nxbakers/Common/Widgets/add_button.dart';
import 'package:nxbakers/Common/Widgets/header_text_style.dart';
import 'package:nxbakers/Common/Widgets/subheader_text_style.dart';
import 'package:nxbakers/Presentation/ViewModels/pastry_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:nxbakers/Presentation/pages/Pastries/Methods/methods.dart';


class CommonPageHeader extends StatelessWidget {
  final String pageTitle;
  final String pageSubTitle;
  final ChangeNotifier addViewModel;
  final Widget addNavPage;
  const CommonPageHeader({super.key, required this.pageTitle, required this.pageSubTitle, required this.addViewModel, required this.addNavPage});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /**
           * Page Header
           */
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              HeaderTextStyle(text: pageTitle),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 5.w,
                children: [
                  /**
                   * Search button
                   */
                  GestureDetector(
                    onTap: () => buildSearchDialog,
                    child: Container(
                      width: 27.w,
                      height: 27.w,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(4.r),
                        border: Border.all(
                          width: 1.0.w,
                          color: const Color(0xffAA9C88),
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: Icon(
                        color: const Color(0xffAA9C88),
                        Icons.search,
                        size: 18.w,
                      ),
                    ),
                  ),

                  /**
                   * Add button
                   */
                  AddButton(addNavPage: addNavPage, addViewModel: addViewModel,),
                ],
              )
            ],
          ),
          SizedBox(
            height: 5.h,
          ),
          /**
           * Page subheader
           */
          SubHeaderTextStyle(
              text: pageSubTitle)
        ],
      ),
    )
    ;
  }
}
