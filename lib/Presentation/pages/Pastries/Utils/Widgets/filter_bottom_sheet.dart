import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nxbakers/Common/AppData.dart';
import 'package:nxbakers/Common/Widgets/reusable_text_widget.dart';
import 'package:nxbakers/Presentation/ViewModels/pastry_viewmodel.dart';
import 'package:provider/provider.dart';

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late FilterType _selectedFilter;
  String? _selectedCategory;
  int _lowStockThreshold = 5;

  @override
  void initState() {
    super.initState();
    final viewModel = Provider.of<PastryViewModel>(context, listen: false)..initialize();

    _selectedFilter = viewModel.filterOptions.filterType;
    _selectedCategory = viewModel.filterOptions.selectedCategory;
    _lowStockThreshold = viewModel.filterOptions.lowStockThreshold ?? 5;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PastryViewModel>(
      builder: (context, viewModel, child) {
        return Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: const Color(0xFFF2EADE),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.r),
              topRight: Radius.circular(20.r),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ReusableTextWidget(
                    text: "Filter Pastries",
                    color: const Color(0xFF573E1A),
                    size: xlFontSize,
                    FW: lFontWeight,
                  ),
                  if (viewModel.filterOptions.isActive)
                    TextButton(
                      onPressed: () {
                        viewModel.clearFilters();
                        Navigator.pop(context);
                      },
                      child: ReusableTextWidget(
                        text: "Clear All",
                        color: Colors.red.shade700,
                        size: sFontSize,
                        FW: lFontWeight,
                      ),
                    ),
                ],
              ),
              SizedBox(height: 20.h),

              // Filter Options
              _buildFilterOption(
                title: "All Pastries",
                filterType: FilterType.all,
                icon: Icons.apps,
              ),
              _buildFilterOption(
                title: "Available Only",
                filterType: FilterType.available,
                icon: Icons.check_circle_outline,
              ),
              _buildFilterOption(
                title: "Out of Stock",
                filterType: FilterType.outOfStock,
                icon: Icons.remove_circle_outline,
              ),
              _buildFilterOption(
                title: "Low Stock",
                filterType: FilterType.lowStock,
                icon: Icons.warning_amber_outlined,
                trailing: _selectedFilter == FilterType.lowStock
                    ? _buildLowStockSlider()
                    : null,
              ),
              _buildFilterOption(
                title: "By Category",
                filterType: FilterType.category,
                icon: Icons.category_outlined,
                trailing: _selectedFilter == FilterType.category
                    ? _buildCategoryDropdown(viewModel)
                    : null,
              ),

              SizedBox(height: 20.h),

              // Apply Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    viewModel.setFilter(
                      _selectedFilter,
                      category: _selectedCategory,
                      threshold: _lowStockThreshold,
                    );
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: EdgeInsets.symmetric(vertical: 15.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: ReusableTextWidget(
                    text: "Apply Filter",
                    color: Colors.white,
                    size: lFontSize,
                    FW: lFontWeight,
                  ),
                ),
              ),
              SizedBox(height: 10.h),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterOption({
    required String title,
    required FilterType filterType,
    required IconData icon,
    Widget? trailing,
  }) {
    final isSelected = _selectedFilter == filterType;

    return Column(
      children: [
        InkWell(
          onTap: () {
            setState(() {
              _selectedFilter = filterType;
            });
          },
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 15.w),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF573E1A).withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isSelected
                      ? const Color(0xFF573E1A)
                      : Colors.black54,
                  size: 24.w,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ReusableTextWidget(
                    text: title,
                    color: isSelected
                        ? const Color(0xFF573E1A)
                        : Colors.black87,
                    size: lFontSize,
                    FW: isSelected ? lFontWeight : sFontWeight,
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: const Color(0xFF573E1A),
                    size: 20.w,
                  ),
              ],
            ),
          ),
        ),
        if (trailing != null && isSelected) ...[
          SizedBox(height: 10.h),
          Padding(
            padding: EdgeInsets.only(left: 40.w),
            child: trailing,
          ),
        ],
      ],
    );
  }

  Widget _buildLowStockSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ReusableTextWidget(
          text: "Threshold: $_lowStockThreshold units",
          color: const Color(0xFF573E1A),
          size: sFontSize,
          FW: sFontWeight,
        ),
        Slider(
          value: _lowStockThreshold.toDouble(),
          min: 1,
          max: 20,
          divisions: 19,
          activeColor: const Color(0xFF573E1A),
          onChanged: (value) {
            setState(() {
              _lowStockThreshold = value.toInt();
            });
          },
        ),
      ],
    );
  }

  Widget _buildCategoryDropdown(PastryViewModel viewModel) {
    return DropdownButtonFormField<String>(
      value: _selectedCategory,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: const BorderSide(color: Color(0xFF573E1A)),
        ),
      ),
      hint: ReusableTextWidget(
        text: "Select Category",
        color: Colors.black54,
        size: sFontSize,
        FW: sFontWeight,
      ),
      items: viewModel.categories.map((category) {
        return DropdownMenuItem(
          value: category.name,
          child: ReusableTextWidget(
            text: category.name,
            color: Colors.black87,
            size: sFontSize,
            FW: sFontWeight,
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedCategory = value;
        });
      },
    );
  }
}