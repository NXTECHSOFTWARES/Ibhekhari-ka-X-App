import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nxbakers/Common/AppData.dart';
import 'package:nxbakers/Common/Widgets/reusable_text_widget.dart';
import 'package:nxbakers/Presentation/ViewModels/pastry_viewmodel.dart';
import 'package:provider/provider.dart';

class SortBottomSheet extends StatefulWidget {
  const SortBottomSheet({super.key});

  @override
  State<SortBottomSheet> createState() => _SortBottomSheetState();
}

class _SortBottomSheetState extends State<SortBottomSheet> {
  SortType? _selectedSort;

  @override
  void initState() {
    super.initState();
    final viewModel = Provider.of<PastryViewModel>(context, listen: false);
    _selectedSort = viewModel.currentSort;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 25.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF2EADE),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ReusableTextWidget(
                text: "Sort Pastries",
                color: const Color(0xff573E1A),
                size: xlFontSize,
                FW: xxlFontWeight,
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.close, size: 24.w, color: const Color(0xff573E1A)),
              ),
            ],
          ),

          SizedBox(height: 10.h),
          ReusableTextWidget(
            text: "Choose how to sort your pastries",
            color: const Color(0xff7D6543),
            size: sFontSize,
            FW: FontWeight.w400,
          ),

          SizedBox(height: 25.h),

          // Sort Options
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Name Sorting
                  _buildSortSection(
                    title: "Name",
                    options: [
                      _buildSortOption(
                        "A to Z",
                        SortType.nameAsc,
                        Icons.sort_by_alpha,
                      ),
                      _buildSortOption(
                        "Z to A",
                        SortType.nameDesc,
                        Icons.sort_by_alpha,
                      ),
                    ],
                  ),

                  SizedBox(height: 20.h),

                  // Price Sorting
                  _buildSortSection(
                    title: "Price",
                    options: [
                      _buildSortOption(
                        "Low to High",
                        SortType.priceAsc,
                        Icons.attach_money,
                      ),
                      _buildSortOption(
                        "High to Low",
                        SortType.priceDesc,
                        Icons.attach_money,
                      ),
                    ],
                  ),

                  SizedBox(height: 20.h),

                  // Quantity Sorting
                  _buildSortSection(
                    title: "Quantity",
                    options: [
                      _buildSortOption(
                        "Low to High",
                        SortType.quantityAsc,
                        Icons.inventory_2,
                      ),
                      _buildSortOption(
                        "High to Low",
                        SortType.quantityDesc,
                        Icons.inventory_2,
                      ),
                    ],
                  ),

                  SizedBox(height: 20.h),

                  // Sales Sorting
                  _buildSortSection(
                    title: "Sales",
                    options: [
                      _buildSortOption(
                        "Low to High",
                        SortType.salesAsc,
                        Icons.trending_up,
                      ),
                      _buildSortOption(
                        "High to Low",
                        SortType.salesDesc,
                        Icons.trending_down,
                      ),
                    ],
                  ),

                  SizedBox(height: 20.h),

                  // Income Sorting
                  _buildSortSection(
                    title: "Income",
                    options: [
                      _buildSortOption(
                        "Low to High",
                        SortType.incomeAsc,
                        Icons.monetization_on,
                      ),
                      _buildSortOption(
                        "High to Low",
                        SortType.incomeDesc,
                        Icons.monetization_on,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 20.h),

          // Apply Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                final viewModel = Provider.of<PastryViewModel>(context, listen: false);
                if (_selectedSort != null) {
                  viewModel.setSort(_selectedSort!);
                }
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff573E1A),
                padding: EdgeInsets.symmetric(vertical: 15.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              child: ReusableTextWidget(
                text: "Apply Sort",
                color: Colors.white,
                size: lFontSize,
                FW: FontWeight.w600,
              ),
            ),
          ),

          SizedBox(height: 10.h),

          // Clear Button
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () {
                final viewModel = Provider.of<PastryViewModel>(context, listen: false);
                viewModel.setSort(SortType.nameAsc); // Reset to default
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 15.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              child: ReusableTextWidget(
                text: "Clear Sort",
                color: const Color(0xff573E1A),
                size: lFontSize,
                FW: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortSection({
    required String title,
    required List<Widget> options,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ReusableTextWidget(
          text: title,
          color: const Color(0xff573E1A),
          size: lFontSize,
          FW: FontWeight.w600,
        ),
        SizedBox(height: 10.h),
        ...options,
      ],
    );
  }

  Widget _buildSortOption(String text, SortType sortType, IconData icon) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      decoration: BoxDecoration(
        color: _selectedSort == sortType ? const Color(0xff573E1A).withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: _selectedSort == sortType ? const Color(0xff573E1A) : const Color(0xffAA9C88),
          width: 1.w,
        ),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          size: 20.w,
          color: _selectedSort == sortType ? const Color(0xff573E1A) : const Color(0xff7D6543),
        ),
        title: ReusableTextWidget(
          text: text,
          color: _selectedSort == sortType ? const Color(0xff573E1A) : const Color(0xff351F00),
          size: sFontSize,
          FW: _selectedSort == sortType ? FontWeight.w600 : FontWeight.w400,
        ),
        trailing: _selectedSort == sortType
            ? Icon(Icons.check, size: 20.w, color: const Color(0xff573E1A))
            : null,
        onTap: () {
          setState(() {
            _selectedSort = sortType;
          });
        },
        contentPadding: EdgeInsets.symmetric(horizontal: 15.w),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
      ),
    );
  }
}