import 'dart:io';
import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nxbakers/Common/AppData.dart';
import 'package:nxbakers/Common/Widgets/reusable_text_widget.dart';
import 'package:provider/provider.dart';

import '../../../Data/Model/pastry.dart';
import '../../ViewModels/pastry_viewmodel.dart';
import 'Utils/image_util.dart';

class NewPastry extends StatefulWidget {
  final Pastry? pastry;
  const NewPastry({
    super.key,
    this.pastry,
  });

  @override
  State<NewPastry> createState() => _NewPastryState();
}

class _NewPastryState extends State<NewPastry> {
  //Default pastry image
  final String defaultPastryImageUrl = 'assets/Images/default_pastry_img.jpg';

  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  late final TextEditingController _titleController;
  late final TextEditingController _priceController;
  late final TextEditingController _quantityController;
  late final TextEditingController _shelfLifeController;

  String? _selectedCategory;
  File? _selectedImage;
  String? _imageUrl;
  final bool _useDefaultImage = true;

  File? _imageFileFromBytes;

  late PastryViewModel viewModel;
  final FocusNode _focusNode = FocusNode();
  final FocusNode _titleFocusNode = FocusNode();
  final FocusNode _priceFocusNode = FocusNode();
  final FocusNode _quantityFocusNode = FocusNode();
  final FocusNode _shelfLifeFocusNode = FocusNode();

  final FocusNode _dropDownFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _priceController = TextEditingController();
    _quantityController = TextEditingController();
    _shelfLifeController = TextEditingController();

    if (widget.pastry != null) {
      _titleController.text = widget.pastry!.title;
      _priceController.text = widget.pastry!.price.toString();
      _quantityController.text = widget.pastry!.quantity?.toString() ?? '';
      _shelfLifeController.text = widget.pastry!.shelfLife?.toString() ?? '';
      _selectedCategory = widget.pastry!.category;
      if (widget.pastry != null && widget.pastry!.imageBytes.isNotEmpty) {
        _convertBytesToFile(widget.pastry!.imageBytes);
      }
      // Handle image if needed
    }

    final viewModel = Provider.of<PastryViewModel>(context, listen: false);
    viewModel.initialize();
  }

  Future<void> _convertBytesToFile(Uint8List bytes) async {
    try {
      final File file = await ImageUtils.uint8ListToFile(
        bytes,
        fileName: 'pastry_${widget.pastry?.id}_image.jpg',
      );

      setState(() {
        _imageFileFromBytes = file;
        _selectedImage = file; // Also set as selected image
      });
    } catch (e) {
      print('Error converting bytes to file: $e');
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _shelfLifeController.dispose();

    _focusNode.dispose();
    _titleFocusNode.dispose();
    _priceFocusNode.dispose();
    _quantityFocusNode.dispose();

    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
          imageQuality: 85,
          requestFullMetadata: true,
          source: ImageSource.gallery);

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _imageUrl =
              null; // Clear any existing URL when a new image is selected
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: ReusableTextWidget(
          text: 'Failed to pick image: ${e.toString()}',
          color: Colors.white,
          size: sFontSize,
          FW: sFontWeight,
        )),
      );
    }
  }

  Widget _buildImagePreview() {
    if (_selectedImage != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8.0.r),
        child: Image.file(
          _selectedImage!,
          height: 55.w,
          width: 55.h,
          fit: BoxFit.cover,
        ),
      );
    } else if (_imageUrl != null && !_useDefaultImage) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8.0.r),
        child: Image.network(
          _imageUrl!,
          height: 120.h,
          width: 120.w,
          fit: BoxFit.cover,
        ),
      );
    } else {
      // Show default image
      return ClipRRect(
        borderRadius: BorderRadius.circular(8.0.r),
        child: Image.asset(
          defaultPastryImageUrl,
          height: 55.h,
          width: 55.w,
          fit: BoxFit.cover,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PastryViewModel>(
      builder:
          (BuildContext context, PastryViewModel viewModel, Widget? child) {
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
                            viewModel.listOfPastries.isNotEmpty
                                ? Container(
                                    width: 20.w,
                                    height: 20.h,
                                    decoration: BoxDecoration(
                                      color: Colors.orange.shade500,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                        child: ReusableTextWidget(
                                      text: viewModel.listOfPastries.length
                                          .toString(),
                                      color: Colors.white,
                                      size: xsFontSize,
                                      FW: lFontWeight,
                                    )),
                                  )
                                : Container(),
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
                         * Quantity and Price form field
                         */
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            /**
                             * Pastry Quantity form field
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

                            /**
                             * Pastry Price form field
                             */
                            Wrap(
                              direction: Axis.vertical,
                              spacing: 5.h,
                              children: [
                                const ReusableTextWidget(
                                  text: "Price",
                                  color: Color(0xff573E1A),
                                  size: 10,
                                  FW: FontWeight.w200,
                                ),
                                buildTextEditForm(
                                    viewModel.validatePrice,
                                    "enter pastry price",
                                    _priceController,
                                    125,
                                    35,
                                    _priceFocusNode)
                              ],
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 15.h,
                        ),

                        /**
                         * Name of a pastry form field
                         */
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /**
                             * Category drop down
                             */
                            Wrap(
                              direction: Axis.vertical,
                              spacing: 5.h,
                              children: [
                                ReusableTextWidget(
                                  text: "Category",
                                  color: const Color(0xff573E1A),
                                  size: sFontSize,
                                  FW: xsFontWeight,
                                ),
                                SizedBox(
                                  width: 125.w,
                                  height: 30.h,
                                  child: DropdownButtonFormField<String>(
                                    focusNode: _dropDownFocusNode,
                                    elevation: 0,
                                    dropdownColor: const Color(0xffD8C6AD),
                                    style: GoogleFonts.poppins(
                                      fontSize: 10.sp,
                                      color: const Color(0xff351F00),
                                    ),
                                    hint: ReusableTextWidget(
                                      text: "Please select a cat...'",
                                      color: const Color(0xff515151),
                                      size: xsFontSize,
                                      FW: xsFontWeight,
                                    ),
                                    value: _selectedCategory,
                                    items: viewModel.categories.map((category) {
                                      return DropdownMenuItem(
                                        value: category.name,
                                        child: ReusableTextWidget(
                                          text: category.name,
                                          color: const Color(0xff351F00),
                                          size: 10,
                                          FW: FontWeight.w400,
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedCategory = value;
                                      });
                                    },
                                    iconSize: 24.w,
                                    iconEnabledColor: const Color(0xffAEADAD),
                                    focusColor: _dropDownFocusNode.hasFocus
                                        ? Colors.white
                                        : const Color(0xffAEADAD),
                                    borderRadius: BorderRadius.circular(6.r),
                                    decoration: InputDecoration(
                                      isDense: true,
                                      fillColor: const Color(0xffDADADA),
                                      filled: true,
                                      hintText: "select category",
                                      hintStyle: GoogleFonts.poppins(
                                        fontSize: 8.sp,
                                        fontWeight: FontWeight.w200,
                                        color: const Color(0xff515151),
                                      ),
                                    ),
                                    validator: (value) => value == null
                                        ? 'Please select a category'
                                        : null,
                                  ),
                                ),
                              ],
                            ),

                            /**
                             * Select pastry Image
                             */
                            Wrap(
                              direction: Axis.vertical,
                              spacing: 5.h,
                              children: [
                                ReusableTextWidget(
                                  text: "Pastry Image",
                                  color: const Color(0xff573E1A),
                                  size: sFontSize,
                                  FW: xsFontWeight,
                                ),
                                GestureDetector(
                                  onTap: _pickImage,
                                  child: _selectedImage == null
                                      ? Container(
                                          width: 80.w,
                                          height: 30.h,
                                          decoration: BoxDecoration(
                                            color: const Color(0xffDADADA),
                                            borderRadius:
                                                BorderRadius.circular(6.r),
                                          ),
                                          child: const Icon(
                                            CommunityMaterialIcons.image_plus,
                                          ),
                                        )
                                      : GestureDetector(
                                          onTap: _pickImage,
                                          child: Stack(
                                            children: [
                                              _buildImagePreview(),
                                              Container(
                                                width: 55.w,
                                                height: 55.h,
                                                decoration: BoxDecoration(
                                                    color: Colors.black54,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.r)),
                                              ),
                                              Positioned(
                                                top: 18.h,
                                                right: 18.w,
                                                child: Icon(
                                                  CommunityMaterialIcons
                                                      .image_edit,
                                                  size: 18.w,
                                                  color: Colors.grey.shade100,
                                                ),
                                              ),
                                            ],
                                          )),
                                ),
                              ],
                            ),
                          ],
                        ),
                        /**
                         * Pastry Quantity form field
                         */
                        Wrap(
                          direction: Axis.vertical,
                          spacing: 5.h,
                          children: [
                            ReusableTextWidget(
                              text: "Shelf Life",
                              color: const Color(0xff573E1A),
                              size: sFontSize,
                              FW: xsFontWeight,
                            ),
                            buildTextEditForm(
                                viewModel.validateQuantity,
                                "days before expires",
                                _shelfLifeController,
                                300,
                                35,
                                _shelfLifeFocusNode)
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        /**
                         * Save button/ Submission button
                         */
                        GestureDetector(
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
                                  text: widget.pastry == null
                                      ? "save entry"
                                      : "Update",
                                  color: const Color(0xffFFFFFF),
                                  size: sFontSize,
                                  FW: xsFontWeight,
                                )
                              ],
                            ),
                          ),
                        ),

                        /**
                         * Next entry button
                         */
                        widget.pastry == null
                            ? GestureDetector(
                                onTap: () {
                                  // if (_formKey.currentState!.validate()) {
                                  //   viewModel.multipleEntries(
                                  //     title: _titleController.text,
                                  //     price:
                                  //         double.parse(_priceController.text),
                                  //     quantity:
                                  //         int.parse(_quantityController.text),
                                  //     category: _selectedCategory!,
                                  //     imageFile: _selectedImage!,
                                  //   );
                                  //
                                  //   _formKey.currentState?.reset();
                                  //   _quantityController.text = "";
                                  //   _priceController.text = "";
                                  //   _titleController.text = "";
                                  //   setState(() {
                                  //     _selectedCategory = null;
                                  //     _selectedImage = null;
                                  //   });
                                  // }

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        shape: const StadiumBorder(),
                                        backgroundColor: Colors.white,
                                        content: ReusableTextWidget(
                                            text: "No Entry Found!",
                                            color: Colors.black,
                                            size: sFontSize,
                                        ),
                                    ),
                                  );
                                },
                                child: Container(
                                  width: 125.w,
                                  height: 35.h,
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 10.w),
                                  decoration: BoxDecoration(
                                      color: Colors.transparent,
                                      borderRadius: BorderRadius.circular(6.r),
                                      border: Border.all(
                                          width: 1.0.w,
                                          color: const Color(0xff777169),
                                          style: BorderStyle.solid)),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      ReusableTextWidget(
                                        text: "next entry",
                                        color: const Color(0xff351F00),
                                        size: sFontSize,
                                        FW: xsFontWeight,
                                      ),
                                      SizedBox(
                                        width: 15.w,
                                      ),
                                      Container(
                                        width: 22.w,
                                        height: 22.w,
                                        decoration: BoxDecoration(
                                          color: const Color(0xffC2C2C2),
                                          borderRadius:
                                              BorderRadius.circular(4.r),
                                        ),
                                        child: Center(
                                            child: Icon(
                                          Icons.arrow_forward_ios_rounded,
                                          color: const Color(0xff422B0A),
                                          size: 12.w,
                                        )),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : Container(),
                      ],
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

  Future<void> _submitForm(PastryViewModel viewModel) async {
    if (_formKey.currentState!.validate()) {
      final price = double.parse(_priceController.text);
      final quantity = _quantityController.text.isNotEmpty
          ? int.parse(_quantityController.text)
          : 1;
      final shelfLife = _quantityController.text.isNotEmpty
          ? int.parse(_quantityController.text)
          : 1;

      // Add new pastry
      final success = await viewModel.addPastry(
        title: _titleController.text,
        price: price,
        quantity: quantity,
        category: _selectedCategory!,
        imageFile: _selectedImage!, shelfLife: shelfLife,
      );
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pastry Added Successfully')),
        );
        Navigator.pop(context);
      } else {
        // Update existing pastry
        final updatedPastry = widget.pastry!.copyWith(
          title: _titleController.text,
          price: price,
          quantity: quantity,
          category: _selectedCategory!,
          imageBytes: await _selectedImage?.readAsBytes(),
        );
        final success = await viewModel.updatePastry(updatedPastry);
        if (success) {
          Navigator.pop(context);
        }
      }
    }
  }
}

// return AlertDialog(
//   title: Text(widget.pastry == null ? 'Add Pastry' : 'Edit Pastry'),
//   content: Form(
//     key: _formKey,
//     child: SingleChildScrollView(
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           _buildImageSelector(),
//           const SizedBox(height: 16),
//           TextFormField(
//             controller: _titleController,
//             decoration: const InputDecoration(labelText: 'Title'),
//             validator: widget.viewModel.validateTitle,
//           ),
//           TextFormField(
//             controller: _priceController,
//             decoration: const InputDecoration(labelText: 'Price (in cents)'),
//             keyboardType: TextInputType.number,
//             validator: widget.viewModel.validatePrice,
//           ),
//           TextFormField(
//             controller: _quantityController,
//             decoration: const InputDecoration(labelText: 'Quantity (optional)'),
//             keyboardType: TextInputType.number,
//             validator: widget.viewModel.validateQuantity,
//           ),
//           DropdownButtonFormField<String>(
//             value: _selectedCategory,
//             items: widget.viewModel.categories.map((category) {
//               return DropdownMenuItem(
//                 value: category.name,
//                 child: Text(category.name),
//               );
//             }).toList(),
//             onChanged: (value) {
//               setState(() {
//                 _selectedCategory = value;
//               });
//             },
//             decoration: const InputDecoration(labelText: 'Category'),
//             validator: (value) =>
//             value == null ? 'Please select a category' : null,
//           ),
//         ],
//       ),
//     ),
//   ),
//   actions: [
//     TextButton(
//       onPressed: () => Navigator.pop(context),
//       child: const Text('Cancel'),
//     ),
//     TextButton(
//       onPressed: _submitForm,
//       child: const Text('Save'),
//     ),
//   ],
// );

// Widget _buildImageSelector() {
//   return SlidingUpPanel(
//       padding: EdgeInsets.symmetric(horizontal: 20.w),
//       maxHeight: 300,
//       borderRadius: BorderRadius.only(
//         topLeft: Radius.circular(30.r),
//         topRight: Radius.circular(30.r),
//       ),
//       minHeight: 130.h,
//       panel:
//       Column(
//     children: [
//       _buildImagePreview(),
//       const SizedBox(height: 8),
//       Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           ElevatedButton.icon(
//             icon: const Icon(Icons.photo_library),
//             label: const Text('Gallery'),
//             onPressed: () => _pickImage(ImageSource.gallery),
//           ),
//           const SizedBox(width: 8),
//           ElevatedButton.icon(
//             icon: const Icon(Icons.camera_alt),
//             label: const Text('Camera'),
//             onPressed: () => _pickImage(ImageSource.camera),
//           ),
//         ],
//       ),
//       if (_selectedImage != null || (_imageUrl != null && !_useDefaultImage))
//         TextButton(
//           onPressed: () {
//             setState(() {
//               _selectedImage = null;
//               _useDefaultImage = true;
//               _imageUrl = null;
//             });
//           },
//           child: const Text('Use Default Image'),
//         ),
//     ],),
//   );
// }
