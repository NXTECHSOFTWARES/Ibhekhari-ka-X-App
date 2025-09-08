import 'dart:typed_data';

import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:nxbakers/Common/Widgets/reusable_text_widget.dart';
import 'package:nxbakers/Common/common_main.dart';
import 'package:nxbakers/Common/common_page_header.dart';
import 'package:nxbakers/Presentation/pages/Pastries/Utils/Widgets/custom_filter_button.dart';
import 'package:nxbakers/Presentation/pages/Pastries/Utils/Widgets/pastry_card.dart';
import 'package:nxbakers/Presentation/pages/Pastries/pastry_details.dart';
import 'package:provider/provider.dart';
import '../../../Data/Model/pastry.dart';
import '../../ViewModels/pastry_viewmodel.dart';
import 'add_new_pastry.dart';

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
    return ChangeNotifierProvider(
      create: (BuildContext context) => PastryViewModel()..loadPastries(),
      child: Scaffold(
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
           * Filter button
           */
          const CustomFilterButton(),

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
                  itemCount: viewModel.pastries.length,
                  itemBuilder: (context, index) {
                    final pastry = viewModel.pastries[index];

                    /**
                     * Pastry Card
                     */
                    return Slidable(
                      key: Key(index.toString()),
                      endActionPane:
                          ActionPane(motion: const ScrollMotion(), children: [
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
                          onPressed: (context) =>
                              _showEditPastryDialog(viewModel.pastries[index]),
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(6.r),
                            bottomRight: Radius.circular(6.r),
                          ),
                          icon: Icons.edit,
                          label: 'Edit',
                        ),
                      ]),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => PastryDetails(
                                      pastryId:
                                          viewModel.pastries[index].id!)));
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
          size: 14,
          color: Colors.brown.shade800,
          FW: FontWeight.w400,
        ),
        content: ReusableTextWidget(
          text: 'Are you sure you want to delete ${pastry.title}?',
          size: 10,
          color: Colors.brown.shade400,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const ReusableTextWidget(
              text: 'Cancel',
              color: Colors.black,
              size: 10,
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
                        size: 10,
                      )),
                );
              }
            },
            child: const ReusableTextWidget(
              text: 'Delete',
              color: Colors.black,
              size: 10,
            ),
          ),
        ],
      ),
    );
  }
}
