import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nxbakers/Common/AppData.dart';
import 'package:nxbakers/Common/Widgets/reusable_text_widget.dart';
import 'package:nxbakers/Presentation/ViewModels/baking_record_viewmodel.dart';
import 'package:provider/provider.dart';

class AddBakingRecord extends StatefulWidget {
  const AddBakingRecord({super.key});

  @override
  State<AddBakingRecord> createState() => _AddBakingRecordState();
}

class _AddBakingRecordState extends State<AddBakingRecord> {
  final _formKey = GlobalKey<FormState>();
  final FocusNode _focusNode = FocusNode();

  final FocusNode _titleFocusNode = FocusNode();
  final FocusNode _priceFocusNode = FocusNode();
  final FocusNode _quantityFocusNode = FocusNode();

  late final TextEditingController _titleController;
  late final TextEditingController _priceController;
  late final TextEditingController _quantityController;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _titleController = TextEditingController();
    _priceController = TextEditingController();
    _quantityController = TextEditingController();
  }


  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _quantityController.dispose();

    _focusNode.dispose();
    _titleFocusNode.dispose();
    _priceFocusNode.dispose();
    _quantityFocusNode.dispose();

    super.dispose();
  }
  @override
  Widget build(BuildContext context) {



    return Consumer<BakingRecordViewModel>(
      builder:
          (BuildContext context, viewModel, Widget? child) {
        return Dialog(
          insetPadding: EdgeInsets.zero,
          child: Form(
            key: _formKey,
            child: Container(
              width: 330.w,
              height: 362.h,
              color: const Color(0xffF2EADE),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /**
                   * Page header or Title
                   */
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                            top: 15.0.h, left: 20.w, right: 20.w, bottom: 0.h),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ReusableTextWidget(
                              text: "New Pastry",
                              color: const Color(0xff351F00),
                              size: lFontSize,
                            ),
                          ],
                        ),
                      ),
                      const Divider(),
                    ],
                  ),

                  SizedBox(
                    height: 25.h,
                  ),

                  /**
                   * Text Forms
                   */
                  Container(
                    // width: 300.w,
                    padding: EdgeInsets.symmetric(horizontal: 15.h),
                    child: Column(
                      // crossAxisAlignment: CrossAxisAlignment.center,
                      // mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        /**
                         * Name of a pastry form field
                         */
                        Wrap(
                          spacing: 5.h,
                          direction: Axis.vertical,
                          children: [
                            ReusableTextWidget(
                              text: "Name of Pastry",
                              color: const Color(0xff573E1A),
                              size: sFontSize,
                              FW: xsFontWeight,
                            ),
                            buildTextEditForm(
                                viewModel.validateTitle,
                                "enter the name of the pastry",
                                _titleController,
                                300,
                                35,
                                _titleFocusNode)
                          ],
                        ),
                        SizedBox(
                          height: 15.h,
                        ),

                        /**
                         *New Quantity form field
                         */
                        Wrap(
                          direction: Axis.vertical,
                          spacing: 5.h,
                          children: [
                            ReusableTextWidget(
                              text: "Quantity",
                              color: const Color(0xff573E1A),
                              size: sFontSize,
                              FW: xsFontWeight,
                            ),
                            buildTextEditForm(
                                viewModel.validateQuantity,
                                "number of pastries",
                                _quantityController,
                                125,
                                35,
                                _quantityFocusNode)
                          ],
                        ),
                      ],
                    ),
                  ),

                  Expanded(child: Container()),
                  /**
                   * Two buttons save and next entry
                   */
                  Padding(
                    padding:
                    EdgeInsets.symmetric(vertical: 20.h, horizontal: 15.w),
                    child: GestureDetector(
                      onTap: () {
                        _submitForm(viewModel);
                      },
                      child: Container(
                        width: 125.w,
                        height: 35.h,
                        padding: EdgeInsets.symmetric(horizontal: 10.w),
                        decoration: BoxDecoration(
                          gradient: RadialGradient(colors: const [
                            Color(0xff634923),
                            Color(0xff351F00),
                          ], radius: 2.r),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              width: 22.w,
                              height: 22.w,
                              decoration: BoxDecoration(
                                  gradient: RadialGradient(colors: const [
                                    Color(0xffAF8850),
                                    Color(0xff482B02),
                                  ], radius: 0.5.r),
                                  borderRadius: BorderRadius.circular(4.r),
                                  border: Border.all(
                                    width: 1.w,
                                    color: const Color(0xff3F2808),
                                    style: BorderStyle.solid,
                                  )),
                              child: Center(
                                  child: Icon(
                                    CommunityMaterialIcons.plus,
                                    color: const Color(0xff422B0A),
                                    size: 18.w,
                                  )),
                            ),
                            SizedBox(
                              width: 15.w,
                            ),
                            ReusableTextWidget(
                              text: "save record",
                              color: const Color(0xffFFFFFF),
                              size: sFontSize,
                              FW: xsFontWeight,
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  //_buildImageSelector(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _submitForm(BakingRecordViewModel viewModel) async {
    if (_formKey.currentState!.validate()) {
      final price = double.parse(_priceController.text);
      final quantity = _quantityController.text.isNotEmpty
          ? int.parse(_quantityController.text)
          : 1;


      // Add new pastry
      //final success = await viewModel.addBakingRecord();
      // if (success) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     const SnackBar(content: Text('Pastry Added Successfully')),
      //   );
      //   Navigator.pop(context);
      // }
      }
  }

  Widget buildTextEditForm(
      validate,
      String hintText,
      TextEditingController _controller,
      double width,
      double height,
      FocusNode focusNode) {
    return SizedBox(
      width: width.w,
      height: height.h,
      child: TextFormField(
        onChanged: (value) {
          // setState(() {
          //   if(_value.isNotEmpty){
          //   _controller.text = _value;
          // }else{
          //     _controller.text = value;
          //   }
          // });
        },
        focusNode: focusNode,
        style: GoogleFonts.poppins(
          color: focusNode.hasFocus ? const Color(0xff553609) : Colors.white,
          fontSize: 10.sp,
        ),
        keyboardType: _controller == _titleController
            ? TextInputType.text
            : TextInputType.number,
        textAlign: TextAlign.center,
        controller: _controller,
        decoration: InputDecoration(
            errorMaxLines: 1,
            errorStyle: GoogleFonts.poppins(
              color: Colors.red.shade800,
              fontSize: 8.sp,
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6.r),
              borderSide: BorderSide(
                width: 1.w,
                color: Colors.red.shade800,
                style: BorderStyle.solid,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6.r),
            ),
            filled: true,
            fillColor:
            focusNode.hasFocus ? Colors.white : const Color(0xff553609),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6.r),
              borderSide: BorderSide(
                width: 2.w,
                color: const Color(0xff553609).withOpacity(0.5),
                style: BorderStyle.solid,
              ),
            ),
            hintStyle: GoogleFonts.poppins(
                color: const Color(0xffD0D0D0),
                fontWeight: FontWeight.w200,
                fontSize: 8.sp,
                fontStyle: FontStyle.italic),
            hintText: hintText),
        validator: validate,
      ),
    );
  }
}
