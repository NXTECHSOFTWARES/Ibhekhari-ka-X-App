import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nxbakers/Common/common_main.dart';
import 'package:nxbakers/Presentation/ViewModels/shelfViewModel.dart';
import 'package:provider/provider.dart';

import '../../Common/AppData.dart';
import '../../Common/Widgets/add_button.dart';
import '../../Common/Widgets/reusable_text_widget.dart';
import '../../Data/Model/pastry.dart';
import '../ViewModels/pastry_viewmodel.dart';
import 'Inventory/update_or_add_inventory_page.dart';

class ShelfRecordPage extends StatefulWidget {
  const ShelfRecordPage({super.key});

  @override
  State<ShelfRecordPage> createState() => _ShelfRecordPageState();
}

class _ShelfRecordPageState extends State<ShelfRecordPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (BuildContext context) => ShelfViewModel()..loadShelfRecords(),
      child: Consumer<ShelfViewModel>(builder: (BuildContext context, viewModel, Widget? child) {
        return Scaffold(
          appBar: AppBar(
            titleSpacing: 0.w,
            elevation: 0,
            scrolledUnderElevation: 0,
            title: ReusableTextWidget(
              text: "Shelf Inventory",
              color: const Color(0xff351F00),
              size: lFontSize,
              FW: lFontWeight,
            ),
            backgroundColor: const Color(0xffD7CEC2),
            iconTheme: IconThemeData(color: const Color(0xff5D3700), size: 18.w),
            actions: [
              /**
               * Search button
               */
              GestureDetector(
                onTap: () => {},
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
              Padding(
                padding: EdgeInsets.only(right: 20.0.w, left: 10.w),
                child: AddButton(addNavPage: const UpdateOrAddInventoryPage(), addViewModel: PastryViewModel()),
              )
            ],
          ),
          floatingActionButton: viewModel.shelfRecords.isEmpty
              ? Align(
                  alignment: Alignment.center,
                  child: FloatingActionButton(
                    backgroundColor: Colors.black,
                    onPressed: () {
                      viewModel.loadShelfRecords();
                    },
                    child: const Icon(
                      Icons.add,
                      color: Colors.white,
                    ),
                  ),
                )
              : null,
          body: CommonMain(
            child: Column(
              children: [
                SizedBox(
                  height: 10.h,
                ),
                /**
                 * Shelf Summary
                 */
                Container(
                  height: 60.h,
                  padding: EdgeInsets.only(top: 20.h, left: 15.w, right: 15.w),
                  color: const Color(0xffD7CEC2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            direction: Axis.vertical,
                            children: [
                              ReusableTextWidget(
                                text: "Available",
                                color: const Color(0xff5D3700),
                                size: sFontSize,
                                FW: sFontWeight,
                              ),
                              ReusableTextWidget(
                                text: viewModel.availableShelfRecords.length.toString(),
                                color: const Color(0xff5D3700),
                                size: sFontSize,
                                FW: xlFontWeight,
                              ),
                            ],
                          ),
                          SizedBox(
                            width: 15.w,
                          ),
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            direction: Axis.vertical,
                            children: [
                              ReusableTextWidget(
                                text: "High Quantity",
                                color: const Color(0xff5D3700),
                                size: sFontSize,
                                FW: sFontWeight,
                              ),
                              ReusableTextWidget(
                                text: viewModel.pastryQuantityLevels.isEmpty ? "None" : viewModel.pastryQuantityLevels["high"]!,
                                color: const Color(0xff5D3700),
                                size: sFontSize,
                                FW: xlFontWeight,
                              ),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            direction: Axis.vertical,
                            children: [
                              ReusableTextWidget(
                                text: "Least Quantity",
                                color: const Color(0xff5D3700),
                                size: sFontSize,
                                FW: sFontWeight,
                              ),
                              ReusableTextWidget(
                                text: viewModel.pastryQuantityLevels.isEmpty ? "None" : viewModel.pastryQuantityLevels["low"]!,
                                color: const Color(0xff5D3700),
                                size: sFontSize,
                                FW: xlFontWeight,
                              ),
                            ],
                          ),
                          SizedBox(
                            width: 15.w,
                          ),
                          Wrap(
                            direction: Axis.vertical,
                            alignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              ReusableTextWidget(
                                text: "Out of Stock",
                                color: const Color(0xff5D3700),
                                size: sFontSize,
                                FW: sFontWeight,
                              ),
                              ReusableTextWidget(
                                text: viewModel.outOfStockShelf.length.toString(),
                                color: const Color(0xff5D3700),
                                size: sFontSize,
                                FW: xlFontWeight,
                              ),
                            ],
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                Container(
                  height: 1.5.h,
                  color: const Color(0xffF2EADE),
                ),
                Expanded(
                  child: GridView.builder(
                    padding: EdgeInsets.only(left: 20.h, top: 15.w),
                    shrinkWrap: true,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
                    itemCount: viewModel.shelfRecords.length,
                    itemBuilder: (BuildContext context, int index) {
                      final shelf = viewModel.shelfRecords[index];
                      final pastryName = shelf.pastryName;
                      final pastryImage = shelf.imageBytes;
                      final pastryPrice = shelf.price;
                      final shelfLife = shelf.shelfLife;
                      final shelfStatus = shelf.status.name;
                      final lastRestocked = viewModel.getRecordAge(shelf.lastRestockedDate);
                      final stockAvailable = shelf.currentStock;
                      final dayLeftExpiry = (shelf.daysUntilExpiry * -1);
                      final statusColor = viewModel.getStatusColor(shelfStatus);

                      return Container(
                        padding: EdgeInsets.all(10.w),
                        margin: EdgeInsets.only(right: 20.w, bottom: 10.h),
                        decoration: BoxDecoration(
                          color: const Color(0xffF2EADE),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                /**
                                 * Pastry Image
                                 */
                                Container(
                                  width: 110.w,
                                  height: 110.h,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: pastryImage.isEmpty
                                          ? const AssetImage("assets/Images/default_pastry_img.jpg") as ImageProvider
                                          : MemoryImage(
                                              pastryImage,
                                            ),
                                      fit: BoxFit.cover,
                                    ),
                                    borderRadius: BorderRadius.circular(6.r),
                                    border: Border.all(
                                      width: 1.0.w,
                                      color: const Color(0xffAA9C88),
                                      style: BorderStyle.solid,
                                    ),
                                  ),
                                ),
                                Wrap(
                                  spacing: 10.h,
                                  direction: Axis.vertical,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  alignment: WrapAlignment.spaceBetween,
                                  children: [
                                    /**
                                     * Pastry Shelf Status
                                     */
                                    Container(
                                      width: 40.w,
                                      height: 10.h,
                                      padding: EdgeInsets.symmetric(horizontal: 5.w),
                                      decoration: BoxDecoration(
                                        color: const Color(0xffD9D9D9),
                                        borderRadius: BorderRadius.circular(10.r),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            constraints: BoxConstraints(maxWidth: 22.w),
                                            child: ReusableTextWidget(
                                              text: shelfStatus,
                                              color: const Color(0xff5D3700),
                                              size: xxsFontSize,
                                              FW: xsFontWeight,
                                            ),
                                          ),
                                          CircleAvatar(backgroundColor: statusColor, radius: 3.r,)
                                        ],
                                      ),
                                    ),
                                    /**
                                     * Last Date Shelf was Restocked
                                     */
                                    Container(
                                      width: 40.w,
                                      height: 40.h,
                                      decoration: BoxDecoration(
                                        color: const Color(0xffCEC7BD),
                                        borderRadius: BorderRadius.circular(6.r),
                                      ),
                                      child: Center(
                                        child: Wrap(
                                          direction: Axis.vertical,
                                          crossAxisAlignment: WrapCrossAlignment.center,
                                          alignment: WrapAlignment.center,
                                          children: [
                                            ReusableTextWidget(
                                              text: "Restocked",
                                              color: const Color(0xff553609),
                                              size: xxsFontSize,
                                              FW: sFontWeight,
                                            ),
                                            ReusableTextWidget(
                                              text: lastRestocked.split(" ")[0],
                                              color: Colors.white,
                                              size: xsFontSize,
                                              FW: lFontWeight,
                                            ),
                                            ReusableTextWidget(
                                              text: "${lastRestocked.split(" ")[1]} ago",
                                              color: Colors.white,
                                              size: xxsFontSize,
                                              FW: lFontWeight,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    /**
                                     * Pastry Shelf Price
                                     */
                                    Container(
                                      width: 40.w,
                                      height: 40.h,
                                      decoration: BoxDecoration(
                                        color: const Color(0xffAA9C88),
                                        borderRadius: BorderRadius.circular(6.r),
                                      ),
                                      child: Center(
                                        child: Wrap(
                                          direction: Axis.vertical,
                                          crossAxisAlignment: WrapCrossAlignment.center,
                                          alignment: WrapAlignment.center,
                                          children: [
                                            ReusableTextWidget(
                                              text: "Price",
                                              color: const Color(0xff553609),
                                              size: xxsFontSize,
                                              FW: sFontWeight,
                                            ),
                                            ReusableTextWidget(
                                              text: "R${pastryPrice.toStringAsFixed(2)}",
                                              color: Colors.white,
                                              size: xsFontSize,
                                              FW: lFontWeight,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                            SizedBox(
                              height: 5.h,
                            ),
                            ReusableTextWidget(
                              text: pastryName,
                              color: const Color(0xff5D3700),
                              size: lFontSize,
                              FW: lFontWeight,
                            ),
                            SizedBox(
                              height: 5.h,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Wrap(
                                  direction: Axis.vertical,
                                  crossAxisAlignment: WrapCrossAlignment.start,
                                  alignment: WrapAlignment.center,
                                  children: [
                                    ReusableTextWidget(
                                      text: "Available stock",
                                      color: const Color(0xff553609),
                                      size: xsFontSize,
                                      FW: sFontWeight,
                                    ),
                                    ReusableTextWidget(
                                      text: stockAvailable.toString(),
                                      color: const Color(0xff5D3700),
                                      size: sFontSize,
                                      FW: lFontWeight,
                                    ),
                                  ],
                                ),
                                Wrap(
                                  direction: Axis.vertical,
                                  crossAxisAlignment: WrapCrossAlignment.start,
                                  alignment: WrapAlignment.center,
                                  children: [
                                    ReusableTextWidget(
                                      text: "Days Before Expiry",
                                      color: const Color(0xff553609),
                                      size: xsFontSize,
                                      FW: sFontWeight,
                                    ),
                                    ReusableTextWidget(
                                      text: dayLeftExpiry > shelfLife ? "0" : dayLeftExpiry.toString(),
                                      color: const Color(0xff5D3700),
                                      size: sFontSize,
                                      FW: lFontWeight,
                                    ),
                                  ],
                                ),
                              ],
                            )
                          ],
                        ),
                      );
                    },
                  ),
                )
              ],
            ),
          ),
        );
      }),
    );
  }
}
