import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nxbakers/Common/Widgets/reusable_text_widget.dart';
import 'package:nxbakers/Presentation/ViewModels/pastry_viewmodel.dart';
import 'package:provider/provider.dart';

class AddNewPastryQuantityStock extends StatefulWidget {
  final int id;
  const AddNewPastryQuantityStock({super.key, required this.id});

  @override
  State<AddNewPastryQuantityStock> createState() =>
      _AddNewPastryQuantityStockState();
}

class _AddNewPastryQuantityStockState extends State<AddNewPastryQuantityStock> {
  final GlobalKey _formKey = GlobalKey<FormState>();
  final TextEditingController _quantityController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (BuildContext context) => PastryViewModel(),
        child: Consumer<PastryViewModel>(
            builder: (BuildContext context, viewModel, Widget? child) {
          return FutureBuilder(
              future: viewModel.getPastryById(widget.id),
              builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data == null) {
                  return const Center(child: Text('Pastry not found'));
                }

                final pastry = snapshot.data!;

                return Dialog(
                    elevation: 0,
                    insetPadding: EdgeInsets.symmetric(horizontal: 10.w),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                        side: BorderSide.none),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: 52.h,
                      padding: EdgeInsets.fromLTRB(5.w, 5.h, 10.w, 5.h),
                      //margin: EdgeInsets.symmetric(horizontal: 10.w),
                      decoration: BoxDecoration(
                        color: const Color(0xff000000).withOpacity(0.4),
                        border: Border.all(color: Colors.grey.shade700),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          /**
                           * Image and pastry title
                           */
                          Wrap(
                            spacing: 10.w,
                            alignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              /**
                               * Pastry Image
                               */
                              Container(
                                width: 40.w,
                                height: 40.h,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.r),
                                  border: Border.all(
                                      width: 1.0.w,
                                      color: Colors.white,
                                      style: BorderStyle.solid),
                                  image: DecorationImage(
                                    image: MemoryImage(pastry.imageBytes),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              /**
                               * Pastry Title
                               */
                              ReusableTextWidget(
                                text: pastry.title,
                                color: Colors.white,
                                size: 10,
                                FW: FontWeight.w400,
                              )
                            ],
                          ),
                          /**
                           * Input the stock quantity
                           */
                          SizedBox(
                            width: 70.w,
                            height: 32.h,
                            child: Form(
                              key: _formKey,
                              child: Center(
                                child: TextFormField(
                                  focusNode: _focusNode,
                                  controller: _quantityController,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 12),
                                  textInputAction: TextInputAction.go,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    hintText: "quantity",
                                    hintStyle: GoogleFonts.poppins(
                                        color: _focusNode.hasFocus
                                            ? Colors.grey
                                            : Colors.grey.shade200,
                                        fontWeight: FontWeight.w300,
                                        fontSize: 8),
                                    enabledBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.r),
                                        borderSide: BorderSide.none,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.r),
                                      borderSide: BorderSide(
                                          color: const Color(0xffAA9C88),
                                          width: 1.5.w,
                                          style: BorderStyle.solid,
                                      ),
                                    ),
                                    focusColor: Colors.white,
                                    fillColor: _focusNode.hasFocus
                                        ? Colors.white
                                        : Colors.grey.shade700,
                                    filled: true,
                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ));
              });
        }));
  }
}
