import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nxbakers/Common/AppData.dart';
import 'package:nxbakers/Common/Widgets/add_button.dart';
import 'package:nxbakers/Common/Widgets/custom_add_button.dart';
import 'package:nxbakers/Common/Widgets/reusable_text_widget.dart';
import 'package:nxbakers/Data/Model/pastry.dart';
import 'package:nxbakers/Presentation/ViewModels/pastry_viewmodel.dart';
import 'package:nxbakers/Presentation/pages/Pastries/add_new_pastry.dart';
import 'package:provider/provider.dart';

class UpdateOrAddInventoryPage extends StatefulWidget {
  const UpdateOrAddInventoryPage({super.key});

  @override
  State<UpdateOrAddInventoryPage> createState() => _UpdateOrAddInventoryPageState();
}

class _UpdateOrAddInventoryPageState extends State<UpdateOrAddInventoryPage> {
  final TextEditingController _searchController = TextEditingController();
  final Map<int, bool> _selectedItems = {};

  final FocusNode focusNode = FocusNode();
  List<TextEditingController> _controllers = [];
  List<bool> _isInvalid = [];
  List<bool> _isChangedList = [];
  List<int> _originalQuantities = [];
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PastryViewModel>().initialize();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).unfocus();
    });
  }

  void _initializeControllers(List<Pastry> pastries) {
    // Dispose existing controllers
    for (var controller in _controllers) {
      controller.dispose();
    }

    // Create new controllers with initial values and store original quantities
    _controllers = pastries.map((pastry) {
      final controller = TextEditingController();
      controller.text = pastry.quantity.toString();
      return controller;
    }).toList();

    _originalQuantities = pastries.map((pastry) => pastry.quantity).toList();
    _isChangedList = List.generate(pastries.length, (index) => false);
    _isInvalid = List.generate(pastries.length, (index) => false);

    _isInitialized = true;
  }

  void _updateStock() async {
    final viewModel = context.read<PastryViewModel>();
    bool hasUpdates = false;

    for (int i = 0; i < viewModel.displayedPastries.length; i++) {
      if (_isChangedList[i]) {
        final pastry = viewModel.displayedPastries[i];
        final newQuantity = int.tryParse(_controllers[i].text) ?? 0;

        if (newQuantity != pastry.quantity) {
          // Update the pastry quantity
          final success = await viewModel.updatePastryQuantity(pastry.id, newQuantity);
          if (success) {
            hasUpdates = true;
            // Reset the changed state and update original quantity
            setState(() {
              _isChangedList[i] = false;
              _originalQuantities[i] = newQuantity;
            });
          }
        } else {
          // Quantity is same as database, reset color
          setState(() {
            _isChangedList[i] = false;
          });
        }
      }
    }

    if (hasUpdates) {
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Stock updated successfully'),
          backgroundColor: Colors.green,
        ),
      );

      // Refresh the data
      await viewModel.loadPastries();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No changes to update'),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }

  bool _isQuantityChanged(int index) {
    if (!_isInitialized || index >= _controllers.length) return false;

    final currentText = _controllers[index].text;
    final currentQuantity = int.tryParse(currentText) ?? 0;
    final originalQuantity = _originalQuantities[index];

    return currentQuantity != originalQuantity;
  }

  @override
  void dispose() {
    _searchController.dispose();
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Widget _buildQuantityTextField(Pastry pastry, int index) {
    final hasController = _isInitialized && index < _controllers.length;

    return TextFormField(
      focusNode: FocusNode(skipTraversal: true),
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      controller: hasController ? _controllers[index] : null,
      initialValue: hasController ? null : pastry.quantity.toString(),
      onChanged: hasController ? (value) {
        String numericValue = value.replaceAll(RegExp(r'[^0-9]'), '');
        if (value != numericValue) {
          _controllers[index].text = numericValue;
          _controllers[index].selection = TextSelection.collapsed(offset: numericValue.length);
        }

        // Update changed state based on comparison with original quantity
        setState(() {
          _isChangedList[index] = _isQuantityChanged(index);
        });
      } : null,
      style: GoogleFonts.poppins(
        color: const Color(0xff351F00),
        fontSize: 10.sp,
        fontWeight: FontWeight.w400,
      ),
      decoration: InputDecoration(
        border: InputBorder.none,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4.0.r),
          borderSide: (_isInitialized && index < _isInvalid.length && _isInvalid[index])
              ? BorderSide(width: 1.5.w, color: Colors.red)
              : BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.white,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4.0.r),
          borderSide: (_isInitialized && index < _isInvalid.length && _isInvalid[index])
              ? BorderSide(width: 1.5.w, color: Colors.red)
              : BorderSide.none,
        ),
        hintStyle: GoogleFonts.poppins(
          color: const Color(0xff000110),
          fontWeight: FontWeight.w300,
          fontSize: 8.sp,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<PastryViewModel>();

    return Consumer<PastryViewModel>(
      builder: (BuildContext context, viewModel, Widget? child) {
        // Initialize controllers only once when pastries are available
        if (viewModel.pastries.isNotEmpty && !_isInitialized) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _initializeControllers(viewModel.pastries);
          });
        }

        return Dialog(
          insetPadding: EdgeInsets.zero,
          child: Container(
            width: 330.w,
            height: 480.h,
            color: const Color(0xffF2EADE),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /**
                 * Page header or Title And Add Pastry Button
                 */
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 15.0.h, left: 20.w, right: 20.w, bottom: 0.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ReusableTextWidget(
                            text: "INVENTORY",
                            color: const Color(0xff351F00),
                            size: lFontSize,
                          ),
                          AddButton(addNavPage: const NewPastry(), addViewModel: PastryViewModel())
                        ],
                      ),
                    ),
                    const Divider(),
                  ],
                ),
                SizedBox(height: 10.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Wrap(
                        spacing: 5.w,
                        direction: Axis.horizontal,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Container(
                            width: 25.w,
                            height: 25.h,
                            decoration: const BoxDecoration(color: Color(0xff5C4B32), shape: BoxShape.circle),
                            child: Icon(
                              Icons.search,
                              size: 12.w,
                              color: Colors.white,
                            ),
                          ),
                          ReusableTextWidget(
                            text: "Search",
                            color: const Color(0xff6D593D),
                            size: xsFontSize,
                            FW: lFontWeight,
                          )
                        ],
                      ),
                      Wrap(
                        direction: Axis.vertical,
                        crossAxisAlignment: WrapCrossAlignment.end,
                        children: [
                          ReusableTextWidget(
                            text: "Number Of Stock In Inventory",
                            size: xsFontSize,
                            color: const Color(0xff8B7355),
                            FW: sFontWeight,
                          ),
                          ReusableTextWidget(
                            text: "${viewModel.displayedPastries.length}",
                            size: sFontSize,
                            FW: xxlFontWeight,
                            color: const Color(0xff6D593D),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 15.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: ReusableTextWidget(
                    text: "Select To Update Or Add New Pastry If Not Available",
                    size: xsFontSize,
                    color: const Color(0xff8B7355),
                    FW: sFontWeight,
                  ),
                ),
                SizedBox(height: 15.h),
                Expanded(
                  child: viewModel.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : viewModel.displayedPastries.isEmpty
                      ? Center(
                    child: Text(
                      "No pastries found",
                      style: GoogleFonts.poppins(
                        fontSize: sFontSize.sp,
                        color: const Color(0xff8B7355),
                      ),
                    ),
                  )
                      : ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    itemCount: viewModel.displayedPastries.length,
                    itemBuilder: (context, index) {
                      final pastry = viewModel.displayedPastries[index];
                      final isSelected = _selectedItems[pastry.id] ?? false;
                      final isChanged = _isInitialized && index < _isChangedList.length
                          ? _isChangedList[index]
                          : false;

                      return Padding(
                        padding: EdgeInsets.only(bottom: 10.h),
                        child: Container(
                          height: 40.h,
                          padding: EdgeInsets.symmetric(horizontal: 10.w),
                          decoration: BoxDecoration(
                            color: pastry.quantity == 0
                                ? Colors.black.withOpacity(0.20)
                                : isChanged
                                ? const Color(0xffFFE4BD) // Changed color
                                : const Color(0xffD8C6AD), // Default color
                            borderRadius: BorderRadius.circular(5.r),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 27.w,
                                height: 27.h,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    width: 1.0.w,
                                    color: Colors.black.withOpacity(0.35),
                                    style: BorderStyle.solid,
                                  ),
                                  image: DecorationImage(
                                      image: pastry.imageBytes.isNotEmpty
                                          ? MemoryImage(pastry.imageBytes)
                                          : const AssetImage(
                                        "assets/Images/default_pastry_img.jpg",
                                      ) as ImageProvider,
                                      fit: BoxFit.cover),
                                ),
                              ),
                              SizedBox(width: 15.w),
                              Expanded(
                                child: ReusableTextWidget(
                                  text: pastry.title,
                                  size: sFontSize,
                                  FW: lFontWeight,
                                  color:  pastry.quantity == 0 ? Colors.white : const Color(0xff351F00),
                                ),
                              ),
                              SizedBox(
                                width: 45.w,
                                height: 26.h,
                                child: Center(
                                  child: _buildQuantityTextField(pastry, index),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(20.w),
                  child: GestureDetector(
                      onTap: _updateStock,
                      child: const CustomAddButton(buttonTitle: "update stock")
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}