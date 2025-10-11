import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nxbakers/Common/AppData.dart';
import 'package:nxbakers/Common/Widgets/reusable_text_widget.dart';
import 'package:nxbakers/Presentation/ViewModels/pastry_viewmodel.dart';
import 'package:provider/provider.dart';

class RightSortSheet extends StatelessWidget {
  const RightSortSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<PastryViewModel>(context, listen: true);

    return Container(
      decoration: BoxDecoration(
        color: viewModel.currentSort != SortType.nameAsc
            ? const Color(0xFF573E1A)
            : Colors.black,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8.r),
          onTap: () => _showRightSheet(context),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 12.h),
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
        ),
      ),
    );
  }

  void _showRightSheet(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierColor: Colors.black54,
      barrierDismissible: true,
      barrierLabel: 'Sort Options',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return RightSheetContent();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOut,
          )),
          child: child,
        );
      },
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

class RightSheetContent extends StatefulWidget {
  const RightSheetContent({super.key});

  @override
  State<RightSheetContent> createState() => _RightSheetContentState();
}

class _RightSheetContentState extends State<RightSheetContent> {
  SortType? _selectedSort;

  @override
  void initState() {
    super.initState();
    final viewModel = Provider.of<PastryViewModel>(context, listen: false);
    _selectedSort = viewModel.currentSort;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Align(
        alignment: Alignment.centerRight,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          height: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFFF2EADE),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.r),
              bottomLeft: Radius.circular(20.r),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 25.h),
                decoration: BoxDecoration(
                  color: const Color(0xff573E1A),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.r),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ReusableTextWidget(
                      text: "Sort Options",
                      color: Colors.white,
                      size: xlFontSize,
                      FW: FontWeight.bold,
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close, size: 24.w, color: Colors.white),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
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

                        SizedBox(height: 25.h),

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

                        SizedBox(height: 25.h),

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

                        SizedBox(height: 25.h),

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

                        SizedBox(height: 25.h),

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
              ),

              // Apply Button
              Padding(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  children: [
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
                          viewModel.setSort(SortType.nameAsc);
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
              ),
            ],
          ),
        ),
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