import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:nxbakers/Common/Widgets/reusable_text_widget.dart';
import 'package:nxbakers/Data/Model/pastry.dart';
import 'package:nxbakers/Presentation/ViewModels/daily_entry_viewmodel.dart';
import 'package:provider/provider.dart';

class AddDailyEntries extends StatefulWidget {
  const AddDailyEntries({super.key});

  @override
  State<AddDailyEntries> createState() => _AddDailyEntriesState();
}

class _AddDailyEntriesState extends State<AddDailyEntries> {
  final FocusNode focusNode = FocusNode();
  List<TextEditingController> _controllers = [];
  List<int> _soldQuantities = [];
  List<bool> _isInvalid = [];
  List<String> _soldQuantitiesDisplayValue = [];
  double totalSales = 0;
  bool isInvalid = false;

  @override
  void initState() {
    super.initState();
  }

  void _initializeControllers(int pastriesCount) {
    for (var controller in _controllers) {
      controller.dispose();
    }

    _controllers =
        List.generate(pastriesCount, (index) => TextEditingController());
    _soldQuantities = List.generate(pastriesCount, (index) => 0);
    _isInvalid = List.generate(pastriesCount, (index) => false);
    _soldQuantitiesDisplayValue = List.generate(pastriesCount, (index) => "...");
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    focusNode.dispose();
    super.dispose();
  }

  void _updateTotalSales(Pastry pastry, int index, String remainingStockText, DailyEntryViewModel viewModel) {
    int remainingStock = 0;
    int initialStock = pastry.quantity ?? 0;
    int soldQuantity = 0;

    try {
      remainingStock =
      remainingStockText.isEmpty ? 0 : int.parse(remainingStockText);
    } catch (e) {
      remainingStock = 0;
    }

    if (remainingStockText.isEmpty) {
      setState(() {
        _soldQuantitiesDisplayValue[index] = "...";
        _isInvalid[index] = true;
        _soldQuantities[index] = 0;
        _recalculateTotalSales(viewModel);
      });
      return;
    }

    if (remainingStock > initialStock) {
      setState(() {
        _isInvalid[index] = true;
        _soldQuantitiesDisplayValue[index] = "error";
        _soldQuantities[index] = 0;
        _recalculateTotalSales(viewModel);
      });
      return;
    }

    soldQuantity = initialStock - remainingStock;

    setState(() {
      _soldQuantitiesDisplayValue[index] = soldQuantity.toString();
      _soldQuantities[index] = soldQuantity;
      _isInvalid[index] = false;
      _recalculateTotalSales(viewModel);
    });
  }

  void _recalculateTotalSales(DailyEntryViewModel viewModel) {
    double newTotal = 0;

    for (int i = 0; i < _soldQuantities.length; i++) {
      if (_soldQuantities[i] > 0 && i < viewModel.pastries.length) {
        newTotal += _soldQuantities[i] * (viewModel.pastries[i].price ?? 0);
      }
    }

    setState(() {
      totalSales = newTotal;
    });
  }

  String? _validateRemainingStock(String? value, Pastry pastry) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    final remaining = int.tryParse(value);
    if (remaining == null) {
      return 'Please enter a valid number';
    }

    if (remaining < 0) {
      return 'Cannot be negative';
    }

    if (remaining > (pastry.quantity ?? 0)) {
      return 'Cannot exceed initial stock (${pastry.quantity ?? 0})';
    }

    return null;
  }

  Map<String, dynamic> _getTopSeller(DailyEntryViewModel viewModel) {
    if (_soldQuantities.isEmpty || viewModel.pastries.isEmpty) {
      return {'name': 'No sales', 'quantity': 0, 'total': 0.0};
    }

    int maxSold = 0;
    int topSellerIndex = -1;

    // Find the pastry with the highest sold quantity
    for (int i = 0; i < _soldQuantities.length && i < viewModel.pastries.length; i++) {
      if (_soldQuantities[i] > maxSold) {
        maxSold = _soldQuantities[i];
        topSellerIndex = i;
      }
    }

    // If no sales or all quantities are 0
    if (topSellerIndex == -1 || maxSold == 0) {
      return {'name': 'No sales', 'quantity': 0, 'total': 0.0};
    }

    Pastry topPastry = viewModel.pastries[topSellerIndex];
    double totalPrice = maxSold * (topPastry.price ?? 0);

    return {
      'name': topPastry.title,
      'quantity': maxSold,
      'total': totalPrice,
    };
  }

  void _submitDailyEntry(DailyEntryViewModel viewModel) {
    bool hasErrors = false;
    for (int i = 0; i < _controllers.length; i++) {
      if (i < viewModel.pastries.length) {
        String? error = _validateRemainingStock(_controllers[i].text, viewModel.pastries[i]);
        if (error != null) {
          hasErrors = true;
          break;
        }
      }
    }

    if (hasErrors) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fix all errors before submitting'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Map<int, int> soldData = {};
    double totalRevenue = 0;

    for (int i = 0; i < viewModel.pastries.length && i < _soldQuantities.length; i++) {
      if (_soldQuantities[i] > 0) {
        soldData[viewModel.pastries[i].id!] = _soldQuantities[i];
        totalRevenue += _soldQuantities[i] * (viewModel.pastries[i].price ?? 0);
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Daily entry saved! Total sales: R${totalRevenue.toStringAsFixed(2)}'),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (BuildContext context) => DailyEntryViewModel()..initialize(),
      child: Consumer<DailyEntryViewModel>(
        builder: (BuildContext context, DailyEntryViewModel viewModel, Widget? child) {
          if (viewModel.pastries.isNotEmpty && _controllers.length != viewModel.pastries.length) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _initializeControllers(viewModel.pastries.length);
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
                            const ReusableTextWidget(
                              text: "Daily Entry",
                              color: Color(0xff351F00),
                              size: 12,
                            ),
                            ReusableTextWidget(
                              text: DateFormat('EEEE, d MMMM y')
                                  .format(DateTime.now()),
                              color: const Color(0xff351F00),
                              size: 8,
                              FW: FontWeight.w300,
                            ),
                          ],
                        ),
                      ),
                      Divider(
                        color: const Color(0xff000000).withOpacity(0.25),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.0.w),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Wrap(
                                direction: Axis.horizontal,
                                spacing: 3.w,
                                children: [
                                  const ReusableTextWidget(
                                    text: "Available For sale: ",
                                    color: Color(0xff6D593D),
                                    size: 8,
                                    FW: FontWeight.w400,
                                  ),
                                  ReusableTextWidget(
                                    text: viewModel.pastries.length.toString(),
                                    color: const Color(0xff6D593D),
                                    size: 8,
                                    FW: FontWeight.w800,
                                  ),
                                ],
                              ),
                              Wrap(
                                direction: Axis.horizontal,
                                spacing: 3.w,
                                children: [
                                  const ReusableTextWidget(
                                    text: "Total Sales:",
                                    color: Color(0xff6D593D),
                                    size: 8,
                                    FW: FontWeight.w400,
                                  ),
                                  ReusableTextWidget(
                                    text: totalSales == 0
                                        ? "R..."
                                        : "R${totalSales.toStringAsFixed(2)}",
                                    color: const Color(0xff6D593D),
                                    size: 8,
                                    FW: FontWeight.w800,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 10.h),
                          Expanded(
                            child: ListView.builder(
                              itemCount: viewModel.pastries.length,
                              itemBuilder: (context, index) {
                                final pastry = viewModel.pastries[index];
                                return Container(
                                  width: 100.w,
                                  height: 38.h,
                                  margin: EdgeInsets.only(bottom: 10.h),
                                  padding: EdgeInsets.symmetric(horizontal: 8.w),
                                  decoration: BoxDecoration(
                                    color: const Color(0xff000000).withOpacity(0.20),
                                    borderRadius: BorderRadius.circular(5.0.r),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Wrap(
                                        spacing: 10.w,
                                        crossAxisAlignment: WrapCrossAlignment.center,
                                        children: [
                                          Container(
                                            width: 22.w,
                                            height: 22.h,
                                            decoration: BoxDecoration(
                                              image: DecorationImage(
                                                image: MemoryImage(pastry.imageBytes),
                                              ),
                                              border: Border.all(
                                                width: 1.0.w,
                                                color: const Color(0xff000000).withOpacity(0.35),
                                                style: BorderStyle.solid,
                                              ),
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          ReusableTextWidget(
                                            text: pastry.title,
                                            color: Colors.white,
                                            size: 10,
                                            FW: FontWeight.w400,
                                          ),
                                        ],
                                      ),
                                      Wrap(
                                        spacing: 10.w,
                                        children: [
                                          ReusableTextWidget(
                                            text: index < _soldQuantitiesDisplayValue.length
                                                ? _soldQuantitiesDisplayValue[index]
                                                : "...",
                                            color: index < _isInvalid.length && _isInvalid[index]
                                                ? Colors.red
                                                : const Color(0xffF2EADE),
                                            size: 10,
                                            FW: FontWeight.w400,
                                          ),
                                          SizedBox(
                                            width: 60.w,
                                            height: 26.h,
                                            child: Center(
                                              child: TextFormField(
                                                keyboardType: TextInputType.number,
                                                textAlign: TextAlign.center,
                                                controller: index < _controllers.length
                                                    ? _controllers[index]
                                                    : null,
                                                onChanged: (value) {
                                                  String numericValue = value.replaceAll(RegExp(r'[^0-9]'), '');
                                                  if (value != numericValue) {
                                                    _controllers[index].text = numericValue;
                                                    _controllers[index].selection = TextSelection.collapsed(offset: numericValue.length);
                                                  }
                                                  _updateTotalSales(pastry, index, numericValue, viewModel);
                                                },
                                                style: GoogleFonts.poppins(
                                                  color: const Color(0xff351F00),
                                                  fontSize: 10.sp,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                                decoration: InputDecoration(
                                                  border: InputBorder.none,
                                                  enabledBorder: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(4.0.r),
                                                    borderSide: index < _isInvalid.length && _isInvalid[index]
                                                        ? BorderSide(width: 1.5.w, color: Colors.red)
                                                        : BorderSide.none,
                                                  ),
                                                  filled: true,
                                                  fillColor: Colors.white,
                                                  focusedBorder: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(4.0.r),
                                                    borderSide: index < _isInvalid.length && _isInvalid[index]
                                                        ? BorderSide(width: 1.5.w, color: Colors.red)
                                                        : BorderSide.none,
                                                  ),
                                                  hintStyle: GoogleFonts.poppins(
                                                    color: const Color(0xff000110),
                                                    fontWeight: FontWeight.w300,
                                                    fontSize: 8.sp,
                                                    fontStyle: FontStyle.italic,
                                                  ),
                                                  hintText: "left",
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      Divider(
                        color: const Color(0xff000000).withOpacity(0.25),
                        thickness: 1,
                        height: 1,
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 20.w, right: 20.w, bottom: 15.h, top: 10.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const ReusableTextWidget(
                              text: "Top Seller",
                              color: Color(0xff351F00),
                              size: 12,
                              FW: FontWeight.w400,
                            ),
                            SizedBox(height: 15.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Top seller name
                                ReusableTextWidget(
                                  text: _getTopSeller(viewModel)['name'] == "No sales" ? "loading..." : _getTopSeller(viewModel)['name'],
                                  color: const Color(0xff634923),
                                  size: 10,
                                  FW: FontWeight.w400,
                                ),
                                // Sold quantity
                                ReusableTextWidget(
                                  text: _getTopSeller(viewModel)['quantity'] == 0 ? "loading..." : _getTopSeller(viewModel)['quantity'].toString(),
                                  color: const Color(0xff634923),
                                  size: 10,
                                  FW: FontWeight.w400,
                                ),
                                // Total price
                                ReusableTextWidget(
                                  text: _getTopSeller(viewModel)['total'] == 0.0 ? "loading" : "R${_getTopSeller(viewModel)['total'].toStringAsFixed(2)}",
                                  color: const Color(0xff634923),
                                  size: 10,
                                  FW: FontWeight.w400,
                                ),
                              ],
                            ),
                            SizedBox(height: 30.h),
                            GestureDetector(
                              onTap: () => _submitDailyEntry(viewModel),
                              child: Container(
                                width: double.infinity,
                                height: 34.h,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6.0.r),
                                  gradient: const RadialGradient(
                                    colors: [Color(0xff634923), Color(0xff351F00)],
                                    radius: 4,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 22.w,
                                      height: 22.h,
                                      decoration: BoxDecoration(
                                        gradient: const RadialGradient(
                                          colors: [Color(0xffAF8850), Color(0xff482B02)],
                                          radius: 0.6,
                                        ),
                                        borderRadius: BorderRadius.circular(4.r),
                                        border: Border.all(color: const Color(0xff3F2808)),
                                      ),
                                      child: Center(
                                        child: Icon(
                                          Icons.add,
                                          size: 18.w,
                                          color: const Color(0xff422B0A),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 25.w),
                                    const Center(
                                      child: ReusableTextWidget(
                                        text: "today's entry",
                                        color: Colors.white,
                                        size: 10,
                                        FW: FontWeight.w300,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}