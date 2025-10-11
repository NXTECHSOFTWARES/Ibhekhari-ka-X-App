import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nxbakers/Common/AppData.dart';
import 'package:nxbakers/Common/Widgets/reusable_text_widget.dart';
import 'package:nxbakers/Presentation/ViewModels/pastry_viewmodel.dart';
import 'package:provider/provider.dart';

class SortPopupMenu extends StatelessWidget {
  const SortPopupMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<PastryViewModel>(context, listen: true);

    return PopupMenuButton<SortType>(
      onSelected: (SortType sortType) {
        viewModel.setSort(sortType);
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<SortType>>[
        // Name Sorting
        _buildPopupHeader('Name'),
        _buildPopupItem('A to Z', SortType.nameAsc, Icons.sort_by_alpha, viewModel),
        _buildPopupItem('Z to A', SortType.nameDesc, Icons.sort_by_alpha, viewModel),

        const PopupMenuDivider(),

        // Price Sorting
        _buildPopupHeader('Price'),
        _buildPopupItem('Low to High', SortType.priceAsc, Icons.attach_money, viewModel),
        _buildPopupItem('High to Low', SortType.priceDesc, Icons.attach_money, viewModel),

        const PopupMenuDivider(),

        // Quantity Sorting
        _buildPopupHeader('Quantity'),
        _buildPopupItem('Low to High', SortType.quantityAsc, Icons.inventory_2, viewModel),
        _buildPopupItem('High to Low', SortType.quantityDesc, Icons.inventory_2, viewModel),

        const PopupMenuDivider(),

        // Sales Sorting
        _buildPopupHeader('Sales'),
        _buildPopupItem('Low to High', SortType.salesAsc, Icons.trending_up, viewModel),
        _buildPopupItem('High to Low', SortType.salesDesc, Icons.trending_down, viewModel),

        const PopupMenuDivider(),

        // Income Sorting
        _buildPopupHeader('Income'),
        _buildPopupItem('Low to High', SortType.incomeAsc, Icons.monetization_on, viewModel),
        _buildPopupItem('High to Low', SortType.incomeDesc, Icons.monetization_on, viewModel),

        const PopupMenuDivider(),

        // Clear Sort
        PopupMenuItem<SortType>(
          value: SortType.nameAsc, // Use nameAsc as clear indicator
          child: Row(
            children: [
              Icon(Icons.clear, size: 20.w, color: const Color(0xff573E1A)),
              SizedBox(width: 12.w),
              ReusableTextWidget(
                text: 'Clear Sort',
                color: const Color(0xff573E1A),
                size: sFontSize,
                FW: FontWeight.w500,
              ),
            ],
          ),
        ),
      ],
      offset: Offset(0, 50.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: viewModel.currentSort != SortType.nameAsc
              ? const Color(0xFF573E1A)
              : Colors.black,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.sort,
              size: 18.w,
              color: Colors.white,
            ),
            SizedBox(width: 8.w),
            ReusableTextWidget(
              text: _getSortButtonText(viewModel.currentSort),
              color: Colors.white,
              size: sFontSize,
              FW: sFontWeight,
            ),
            SizedBox(width: 4.w),
            Icon(
              Icons.arrow_drop_down,
              size: 18.w,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<SortType> _buildPopupItem(
      String text,
      SortType sortType,
      IconData icon,
      PastryViewModel viewModel
      ) {
    return PopupMenuItem<SortType>(
      value: sortType,
      child: Row(
        children: [
          Icon(
            icon,
            size: 20.w,
            color: viewModel.currentSort == sortType
                ? const Color(0xff573E1A)
                : const Color(0xff7D6543),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: ReusableTextWidget(
              text: text,
              color: viewModel.currentSort == sortType
                  ? const Color(0xff573E1A)
                  : const Color(0xff351F00),
              size: sFontSize,
              FW: viewModel.currentSort == sortType
                  ? FontWeight.w600
                  : FontWeight.w400,
            ),
          ),
          if (viewModel.currentSort == sortType)
            Icon(
              Icons.check,
              size: 18.w,
              color: const Color(0xff573E1A),
            ),
        ],
      ),
    );
  }

  PopupMenuItem<SortType> _buildPopupHeader(String title) {
    return PopupMenuItem<SortType>(
      enabled: false,
      height: 40.h,
      child: ReusableTextWidget(
        text: title,
        color: const Color(0xff573E1A),
        size: sFontSize,
        FW: FontWeight.w600,
      ),
    );
  }

  String _getSortButtonText(SortType sortType) {
    switch (sortType) {
      case SortType.nameAsc:
        return "Sort";
      case SortType.nameDesc:
        return "Name (Z-A)";
      case SortType.priceAsc:
        return "Price (Low)";
      case SortType.priceDesc:
        return "Price (High)";
      case SortType.quantityAsc:
        return "Qty (Low)";
      case SortType.quantityDesc:
        return "Qty (High)";
      case SortType.salesAsc:
        return "Sales (Low)";
      case SortType.salesDesc:
        return "Sales (High)";
      case SortType.incomeAsc:
        return "Income (Low)";
      case SortType.incomeDesc:
        return "Income (High)";
    }
  }
}