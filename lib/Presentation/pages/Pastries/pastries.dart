import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:nxbakers/Common/AppData.dart';
import 'package:nxbakers/Common/Widgets/reusable_text_widget.dart';
import 'package:nxbakers/Common/common_main.dart';
import 'package:nxbakers/Common/common_page_header.dart';
import 'package:nxbakers/Presentation/pages/Pastries/Utils/Widgets/custom_filter_button.dart';
import 'package:nxbakers/Presentation/pages/Pastries/Utils/Widgets/filter_bottom_sheet.dart';
import 'package:nxbakers/Presentation/pages/Pastries/Utils/Widgets/pastry_card.dart';
import 'package:nxbakers/Presentation/pages/Pastries/Utils/Widgets/sort_bottom_sheet.dart';
import 'package:nxbakers/Presentation/pages/Pastries/pastry_details.dart';
import 'package:provider/provider.dart';
import '../../../Data/Model/pastry.dart';
import '../../ViewModels/pastry_viewmodel.dart';
import 'Utils/Widgets/low_stock_banner.dart';
import 'Utils/Widgets/pastry_settings_bottom_sheet.dart';
import 'add_new_pastry.dart';
import 'low_stock_details_page.dart';

class PastriesPage extends StatefulWidget {
  const PastriesPage({super.key});

  @override
  State<PastriesPage> createState() => _PastriesPageState();
}

class _PastriesPageState extends State<PastriesPage> {
  late final PastryViewModel _viewModel;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final viewModel = Provider.of<PastryViewModel>(context, listen: false);
      viewModel.loadPastries();
    });

    _viewModel = PastryViewModel();
    _initializeData();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    await _viewModel.initialize();
  }

  void _onSearchChanged() {
    _viewModel.setSearchQuery(_searchController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: _viewModel.pastries.isEmpty
          ? Align(
              alignment: Alignment.center,
              child: FloatingActionButton(
                backgroundColor: Colors.black,
                onPressed: () {
                  _viewModel.loadPastyDemoData();
                },
                child: const Icon(
                  Icons.add,
                  color: Colors.white,
                ),
              ),
            )
          : null,
      body: Consumer<PastryViewModel>(
        builder: (BuildContext context, viewModel, Widget? child) {
          switch (viewModel.state) {
            case ViewState.loading:
              return const Center(child: CircularProgressIndicator());
            case ViewState.error:
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(viewModel.errorMessage ?? 'An error occurred'),
                  ],
                ),
              );
            case ViewState.success:
            case ViewState.idle:
              return _buildPastryList(viewModel);
          }
          // if (viewModel.listOfPastries.isEmpty) {
          //   return CommonMain(
          //       child: Column(
          //           mainAxisAlignment: MainAxisAlignment.center,
          //           crossAxisAlignment: CrossAxisAlignment.center,
          //           children: [
          //         SizedBox(
          //           height: 20.h,
          //         ),
          //         /**
          //      * Header
          //      */
          //         CommonPageHeader(
          //           pageTitle: 'Pastries',
          //           pageSubTitle: 'A List of all pastries in your inventory',
          //           addViewModel: PastryViewModel(),
          //           addNavPage: const NewPastry(),
          //         ),
          //         /**
          //      * Filter button
          //      */
          //         const CustomFilterButton(),
          //         const Expanded(
          //           child: Center(
          //             child: ReusableTextWidget(
          //               text: 'No pastries available',
          //               color: Colors.black,
          //               size: 14,
          //               FW: FontWeight.w400,
          //             ),
          //           ),
          //         )
          //       ]));
          // }

          /**
           * Main Code
           */
          //print(viewModel.listOfPastries.length);
        },
      ),
    );
  }

  // Widget _buildSearchAndFilters() {
  //   return Padding(
  //     padding: const EdgeInsets.all(8.0),
  //     child: Column(
  //       children: [
  //         TextField(
  //           controller: _searchController,
  //           decoration: InputDecoration(
  //             labelText: 'Search pastries',
  //             prefixIcon: const Icon(Icons.search),
  //             suffixIcon: IconButton(
  //               icon: const Icon(Icons.clear),
  //               onPressed: () {
  //                 _searchController.clear();
  //                 _viewModel.setSearchQuery('');
  //               },
  //             ),
  //             border: OutlineInputBorder(
  //               borderRadius: BorderRadius.circular(8.0),
  //             ),
  //           ),
  //         ),
  //         const SizedBox(height: 8),
  //         Row(
  //           children: [
  //             Expanded(
  //               child: DropdownButtonFormField<String>(
  //                 value: _viewModel.selectedCategoryFilter,
  //                 items: [
  //                   const DropdownMenuItem(
  //                     value: null,
  //                     child: Text('All Categories'),
  //                   ),
  //                   ..._viewModel.categories.map((category) {
  //                     return DropdownMenuItem(
  //                       value: category.name,
  //                       child: Text(category.name),
  //                     );
  //                   }).toList(),
  //                 ],
  //                 onChanged: (value) {
  //                   _viewModel.setCategoryFilter(value);
  //                 },
  //                 decoration: InputDecoration(
  //                   labelText: 'Filter by category',
  //                   border: OutlineInputBorder(
  //                     borderRadius: BorderRadius.circular(8.0),
  //                   ),
  //                 ),
  //               ),
  //             ),
  //             const SizedBox(width: 8),
  //             FilterChip(
  //               label: const Text('Available Only'),
  //               selected: _viewModel.showOnlyAvailable,
  //               onSelected: (selected) {
  //                 _viewModel.setShowOnlyAvailable(selected);
  //               },
  //             ),
  //           ],
  //         ),
  //       ],
  //     ),
  //   );
  // }
  //

  Widget _buildPastryList(PastryViewModel viewModel) {
    return CommonMain(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 20.h,
          ),
          /**
           * Header
           */
          CommonPageHeader(
            pageTitle: 'Pastries',
            pageSubTitle: 'A List of all pastries in your inventory',
            addViewModel: PastryViewModel(),
            addNavPage: const NewPastry(),
          ),



          /**
           * Filter and sort button
           */
          Row(
            children: [Expanded(child: Container()), _buildCustomFilterDesign(viewModel)],
          ),

          /**
           * LOW STOCK BANNER
           */

          LowStockBanner(
            onViewDetails: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LowStockDetailsPage(),
                ),
              );
            },
          ),

          /**
           * List of pastries
           */
          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 5.w,
              ),
              child: ListView.builder(
                  padding: EdgeInsets.only(top: 0.h),
                  itemCount: viewModel.displayedPastries.length,
                  itemBuilder: (context, index) {
                    final pastry = viewModel.displayedPastries[index];

                    /**
                     * Pastry Card
                     */
                    return Slidable(
                      key: Key(pastry.id.toString()),
                      endActionPane: ActionPane(motion: const ScrollMotion(), children: [
                        SlidableAction(
                          onPressed: (context) => _confirmDeletePastry(pastry),
                          backgroundColor: Colors.red.shade700,
                          foregroundColor: Colors.white,
                          icon: CommunityMaterialIcons.delete_outline,
                          spacing: 0,
                          padding: EdgeInsets.zero,
                          label: 'Delete',
                        ),
                        SlidableAction(
                          onPressed: (context) => _showEditPastryDialog(pastry),
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(6.r),
                            bottomRight: Radius.circular(6.r),
                          ),
                          icon: Icons.edit,
                          label: 'Edit',
                        ),
                        SlidableAction(
                          onPressed: (context) => _showPastrySettings(pastry),
                          backgroundColor: Colors.orange.shade700,
                          foregroundColor: Colors.white,
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(6.r),
                            bottomRight: Radius.circular(6.r),
                          ),
                          icon: Icons.more_vert,
                          //label: 'Settings',
                        ),
                      ]),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => PastryDetails(pastryId: pastry.id!)));
                        },
                        child: PastryCard(pastry: pastry),
                      ),
                    );
                  }),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCustomFilterDesign(PastryViewModel viewModel) {
    return Container(
      // width: 142.w,
      height: 30.h,
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
      //padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 10.h),
      decoration: BoxDecoration(color: const Color(0xff42321C), borderRadius: BorderRadius.circular(5.r)),
      child: Row(
        children: [
          Container(
            width: 10.w,
            margin: EdgeInsets.only(right: 5.w),
            decoration: BoxDecoration(color: const Color(0xffAC906A), borderRadius: BorderRadius.circular(5.r)),
          ),
          // Filter Button
          TextButton.icon(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                isScrollControlled: true,
                builder: (context) => ChangeNotifierProvider.value(
                  value: viewModel,
                  child: const FilterBottomSheet(),
                ),
              );
            },
            icon: Icon(
              Icons.filter_list,
              size: 18.w,
              color: const Color(0xffA1845C),
            ),
            label: ReusableTextWidget(
              text: viewModel.filterOptions.isActive ? "Filter (Active)" : "Filter",
              color: Colors.white,
              size: sFontSize,
              FW: sFontWeight,
            ),
            style: ElevatedButton.styleFrom(
              // backgroundColor: viewModel.filterOptions.isActive
              //     ? const Color(0xFF573E1A)
              //     : Colors.black,
              padding: EdgeInsets.only(right: 10.w),
              // shape: RoundedRectangleBorder(
              //   borderRadius: BorderRadius.circular(8.r),
              // ),
            ),
          ),
          Stack(
            children: [
              Positioned(
                child: Container(
                  width: 8.w,
                  decoration: BoxDecoration(color: const Color(0xff5B492F), borderRadius: BorderRadius.circular(5.r)),
                ),
              ),
              Container(
                width: 5.w,
                decoration: BoxDecoration(
                    color: const Color(0xffAC906A),
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(5.r),
                      bottomRight: Radius.circular(5.r),
                    )),
              ),
            ],
          ),

          // Sort Button
          TextButton.icon(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                isScrollControlled: true,
                builder: (context) => ChangeNotifierProvider.value(
                  value: viewModel,
                  child: const SortBottomSheet(),
                ),
              );
            },
            icon: Icon(
              Icons.sort,
              size: 18.w,
              color: const Color(0xffA1845C),
            ),
            label: ReusableTextWidget(
              text: viewModel.currentSort != SortType.nameAsc ? "Sort (${_getSortText(viewModel.currentSort)})" : "Sort",
              color: Colors.white,
              size: sFontSize,
              FW: sFontWeight,
            ),
            style: ElevatedButton.styleFrom(
              // backgroundColor: viewModel.currentSort != SortType.nameAsc
              //     ? const Color(0xFF573E1A)
              //     : Colors.black,
              padding: EdgeInsets.only(left: 5.w, right: 10.w),
              //  shape: RoundedRectangleBorder(
              //    borderRadius: BorderRadius.circular(8.r),
              //    side: BorderSide(color: Color(0xff7D6543), width: 1.0.w, style: BorderStyle.solid,)
              //  ),
            ),
          ),
        ],
      ),
    );
  }

  // String _getFilterText(FilterOptions options) {
  //   switch (options.filterType) {
  //     case FilterType.available:
  //       return "Available Only";
  //     case FilterType.outOfStock:
  //       return "Out of Stock";
  //     case FilterType.lowStock:
  //       return "Low Stock (≤${options.lowStockThreshold})";
  //     case FilterType.category:
  //       return "Category: ${options.selectedCategory}";
  //   }
  // }
  //
  void _showEditPastryDialog(Pastry pastry) {
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return ChangeNotifierProvider(
            create: (BuildContext context) => PastryViewModel(),
            child: NewPastry(
              pastry: pastry,
            ));
      },
    );
  }

  void _confirmDeletePastry(Pastry pastry) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: ReusableTextWidget(
          text: 'Delete Pastry',
          size: xxlFontSize,
          color: Colors.brown.shade800,
          FW: lFontWeight,
        ),
        content: ReusableTextWidget(
          text: 'Are you sure you want to delete ${pastry.title}?',
          size: sFontSize,
          color: Colors.brown.shade400,
          FW: sFontWeight,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: ReusableTextWidget(
              text: 'Cancel',
              color: Colors.black,
              size: sFontSize,
              FW: lFontWeight,
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await _viewModel.deletePastry(pastry.id!);
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      backgroundColor: Colors.white,
                      content: ReusableTextWidget(
                        text: '${pastry.title} deleted',
                        color: Colors.black,
                        size: sFontSize,
                        FW: lFontWeight,
                      )),
                );
              }
            },
            child: ReusableTextWidget(
              text: 'Delete',
              color: Colors.black,
              size: sFontSize,
              FW: lFontWeight,
            ),
          ),
        ],
      ),
    );
  }

  String _getSortText(SortType sortType) {
    switch (sortType) {
      case SortType.nameAsc:
        return "Name (A-Z)";
      case SortType.nameDesc:
        return "Name (Z-A)";
      case SortType.priceAsc:
        return "Price (Low-High)";
      case SortType.priceDesc:
        return "Price (High-Low)";
      case SortType.quantityAsc:
        return "Quantity (Low-High)";
      case SortType.quantityDesc:
        return "Quantity (High-Low)";
      case SortType.salesAsc:
        return "Sales (Low-High)";
      case SortType.salesDesc:
        return "Sales (High-Low)";
      case SortType.incomeAsc:
        return "Income (Low-High)";
      case SortType.incomeDesc:
        return "Income (High-Low)";
    }
  }

  void _showPastrySettings(Pastry pastry) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => PastrySettingsBottomSheet(pastry: pastry),
    );
  }
}
