import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:nxbakers/Common/Widgets/add_button.dart';
import 'package:nxbakers/Common/Widgets/reusable_text_widget.dart';
import 'package:nxbakers/Common/common_main.dart';
import 'package:nxbakers/Data/Model/pastry.dart';
import 'package:nxbakers/Presentation/ViewModels/pastry_viewmodel.dart';
import 'package:nxbakers/Presentation/pages/Pastries/add_new_pastry.dart';
import 'package:nxbakers/Presentation/pages/Pastries/add_new_pastry_quantity.dart';
import 'package:provider/provider.dart';

import 'Utils/Widgets/card_display_widget.dart';

class PastryDetails extends StatefulWidget {
  final int pastryId;
  const PastryDetails({super.key, required this.pastryId});

  @override
  State<PastryDetails> createState() => _PastryDetailsState();
}

class _PastryDetailsState extends State<PastryDetails> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0.w,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const ReusableTextWidget(
          text: "Pastry Details",
          color: Color(0xff351F00),
          size: 10,
          FW: FontWeight.w400,
        ),
        backgroundColor: const Color(0xffD7CEC2),
        iconTheme: IconThemeData(color: const Color(0xff5D3700), size: 18.w),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 20.0.w),
            child: AddButton(addNavPage: AddNewPastryQuantityStock(id: widget.pastryId), addViewModel: PastryViewModel()),
          )
        ],
      ),
      body: ChangeNotifierProvider(
        create: (BuildContext context) => PastryViewModel(),
        child: Consumer<PastryViewModel>(
          builder: (BuildContext context, viewModel, Widget? child) {
            return FutureBuilder<Pastry?>(
              future: viewModel.getPastryById(widget.pastryId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data == null) {
                  return const Center(child: Text('Pastry not found'));
                }

                final pastry = snapshot.data!;

                return CommonMain(
                  child: Column(
                    children: [
                      /**
                       * Pastry Details
                       */
                      Container(
                        width: size.width,
                        height: 220.h,
                        padding: EdgeInsets.all(15.w),
                        margin: EdgeInsets.fromLTRB(
                          20.w,
                          20.w,
                          20.w,
                          15.w,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25.r),
                          color: const Color(0xffF2EADE),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                /**
                                 * Pastry Image
                                 */
                                Container(
                                  width: 125.w,
                                  height: 130.h,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: MemoryImage(pastry.imageBytes!),
                                      fit: BoxFit.cover,
                                    ),
                                    borderRadius: BorderRadius.circular(10.r),
                                    border: Border.all(
                                      color: const Color(0xffAA9C88),
                                      width: 1.0.w,
                                      style: BorderStyle.solid,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 20.w,
                                ),
                                /**
                                 * Pastry manufacturing details
                                 */
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    /**
                                     * Pastry that were sold
                                     */
                                    const CardDisplayWidget(
                                        header: 'Sold', textValue: '23'),
                                    SizedBox(
                                      height: 10.h,
                                    ),
                                    Row(
                                      children: [
                                        Wrap(
                                          spacing: 10.w,
                                          direction: Axis.vertical,
                                          children: [
                                            /**
                                             * Pastry Price
                                             */
                                            CardDisplayWidget(
                                              header: 'Price',
                                              textValue:
                                                  '\R${pastry.price?.toStringAsFixed(2) ?? 'N/A'}',
                                            ),
                                            /**
                                                //      * How many pastry left in inventory
                                                //      */
                                            const CardDisplayWidget(
                                              header: 'Inventory',
                                              textValue: '6',
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          width: 30.w,
                                        ),
                                        Wrap(
                                          spacing: 10.w,
                                          direction: Axis.vertical,
                                          children: const [
                                            /**
                                                //      * Pastry Total sales
                                                     */
                                            CardDisplayWidget(
                                              header: 'Sales',
                                              textValue: 'R276.00',
                                            ),
                                            /**
                                                //      * how many pastries have been made
                                                //      */
                                            CardDisplayWidget(
                                              header: 'Produced',
                                              textValue: '29',
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                )
                              ],
                            ),
                            SizedBox(
                              height: 15.h,
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 15.0.w),
                              child: Wrap(
                                spacing: 5.h,
                                direction: Axis.vertical,
                                children: [
                                  ReusableTextWidget(
                                    text: pastry.title,
                                    color: const Color(0xff573E1A),
                                    size: 14,
                                    FW: FontWeight.w400,
                                  ),
                                  ReusableTextWidget(
                                    text: DateFormat('d MMMM yyyy').format(
                                        DateTime.parse(pastry.createdAt)),
                                    color: const Color(0xffAA9C88),
                                    size: 10,
                                    FW: FontWeight.w300,
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      const Divider(color: Color(0xffF2EADE)),
                      /**
                       * Pastry Recipe
                       */
                      Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 10.h, horizontal: 20.w),
                        child: Expanded(
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const ReusableTextWidget(
                              text: "Recipe",
                              color: Color(0xff6D593D),
                              size: 12,
                              FW: FontWeight.w400,
                            ),
                            SizedBox(
                              height: 10.h,
                            ),
                            Container(
                              height: 370.h,
                              width: size.width,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.r),
                                border: Border.all(
                                    width: 1.0.w,
                                    color: const Color(0xffD7CFBC),
                                    style: BorderStyle.solid),
                                color: const Color(0xffF2EADE),
                              ),
                              child: Transform.rotate(
                                  angle: 120.0,
                                  child: const Center(
                                      child: ReusableTextWidget(
                                    text: "RECIPE CURRENTLY UNAVAILABLE",
                                    color: Color(0xffAA9C88),
                                    size: 14,
                                    FW: FontWeight.w400,
                                  ))),
                            ),
                          ],
                        )),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

}
