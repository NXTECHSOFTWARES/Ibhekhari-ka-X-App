import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nxbakers/Common/AppData.dart';
import 'package:nxbakers/Common/Widgets/reusable_text_widget.dart';
import 'package:nxbakers/Data/Model/pastry.dart';
import 'package:nxbakers/Data/Model/pastry_notification_settings.dart';
import 'package:nxbakers/Presentation/pages/Pastries/Utils/Widgets/card_display_widget.dart';

import '../../../../../Domain/Repositories/notification_settings_repo.dart';

class PastryCard extends StatelessWidget {
  final Pastry pastry;

  const PastryCard({super.key, required this.pastry});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PastryNotificationSettings>(
        future: NotificationSettingsRepository().getSettings(pastry.id!),
      builder: (context, snapshot) {
        final hasNotifications = snapshot.hasData && snapshot.data!.notificationEnabled;
        return Stack(
          children: [

            Container(
              height: 80.h,
              margin: EdgeInsets.only(bottom: 5.h),
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: const Color(0xffF2EADE),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Expanded(
                child: Row(
                  children: [
                    /**
                     * Pastry Image
                     */
                    Container(
                      width: 60.w,
                      height: 60.h,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: pastry.imageBytes.isEmpty ? const AssetImage("assets/Images/default_pastry_img.jpg") as ImageProvider : MemoryImage(
                            pastry.imageBytes,
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
                              Expanded(
                                child: ReusableTextWidget(
                                  text: pastry.title,
                                  color: const Color(0xff573E1A),
                                  size: lFontSize,
                                  FW: xlFontWeight,
                                ),
                              ),
                              /**
                               * Pastry Category
                               */
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8.0.w, vertical: 1.5.h),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE6DED3),
                                  borderRadius: BorderRadius.circular(7.r)
                                ),
                                child: Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  spacing: 5.w,
                                  children: [
                                    ReusableTextWidget(
                                      text: pastry.category.toLowerCase(),
                                      color: const Color(0xff6D6457),
                                      size: 8,
                                      FW: FontWeight.w300,
                                    ),
                                    CircleAvatar(
                                      backgroundColor: Colors.green,
                                      radius: 3.r,)
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 7.6.h,
                          ),

                          /**
                           * out-stock, in-stock, sales and Income display
                           */
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  //spacing: 10.w,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    /**
                                     * Number of Items Sold
                                     */
                                    const CardDisplayWidget(
                                        header: "out-stock", textValue: "1458"),
                                    SizedBox(
                                      width: 15.w,
                                    ),

                                    /**
                                     * Number of Items remaining
                                     */
                                    CardDisplayWidget(
                                        header: "in-stock",
                                        textValue: "${pastry.quantity}"),
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
                                      CardDisplayWidget(
                                          header: "sales", textValue: "R2 458"),
                                      /**
                                       * Total income made by Item sold/ Profit Made
                                       */
                                      CardDisplayWidget(
                                          header: "income", textValue: "R1 458"),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),

                  ],
                ),
                ),
              ),
            if (hasNotifications)
              Positioned(
                top: 5.h,
                left: 5.w,
                child: Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade700,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4.r,
                        offset: Offset(0, 2.h),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.notifications_active,
                    color: Colors.white,
                    size: 12.w,
                  ),
                ),
              ),
          ],
        );
      }
    );

  }
}
