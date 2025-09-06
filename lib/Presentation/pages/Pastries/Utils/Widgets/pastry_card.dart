import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nxbakers/Common/Widgets/reusable_text_widget.dart';
import 'package:nxbakers/Presentation/pages/Pastries/Utils/Widgets/card_display_widget.dart';

class PastryCard extends StatelessWidget {
  final Uint8List imageByte;
  final String name;
  final String category;

  const PastryCard({super.key, required this.imageByte, required this.name, required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80.h,
      margin: EdgeInsets.only(bottom: 5.h),
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: const Color(0xffF2EADE),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        children: [
          /**
           * Pastry Image
           */
          Container(
            width: 60.w,
            height: 60.h,
            decoration: BoxDecoration(
              image: DecorationImage(image: MemoryImage(
                imageByte,
              ),
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.circular(5.r),
              border: Border.all(
                width: 1.0.w,
                color: const Color(0xffAA9C88),
                style: BorderStyle.solid,
              ),
            ),
          ),
          SizedBox(
            width: 15.w,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /**
                 * Pastry name and category
                 */
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    /**
                     * Pastry Name
                     */
                    ReusableTextWidget(
                      text: name,
                      color: const Color(0xff573E1A),
                      size: 12, FW: FontWeight.w500,),
                    /**
                     * Pastry Category
                     */
                    Padding(
                      padding: EdgeInsets.only(right: 5.0.w),
                      child: ReusableTextWidget(
                        text: category,
                        color: Colors.grey.shade700,
                        size: 10,
                        FW: FontWeight.w300,),
                    ),
                  ],
                ),
                SizedBox(
                  height: 7.6.h,
                ),

                /**
                 * out-stock, in-stock, sales and Income display
                 */
                Row(
                  mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Row(
                      //spacing: 10.w,
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: <Widget>[
                        /**
                         * Number of Items Sold
                         */
                        const CardDisplayWidget(header: "out-stock", textValue: "1458"),
                        SizedBox(
                          width: 15.w,
                        ),

                        /**
                         * Number of Items remaining
                         */
                        const CardDisplayWidget(header: "in-stock", textValue: "18"),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.only(right: 20.0.w),
                      child: Wrap(
                        spacing: 15.w,
                        children: const [
                          /**
                           * Total Items Sold
                           */
                          CardDisplayWidget(header: "sales", textValue: "R2 458"),
                          /**
                           * Total income made by Item sold/ Profit Made
                           */
                          CardDisplayWidget(header: "income", textValue: "R1 458"),
                        ],
                      ),
                    )
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
