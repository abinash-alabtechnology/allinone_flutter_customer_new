
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:handy_allinone/features/item/controllers/item_controller.dart';
import 'package:handy_allinone/features/item/domain/models/item_model.dart';
import 'package:handy_allinone/helper/responsive_helper.dart';
import 'package:handy_allinone/helper/route_helper.dart';
import 'package:handy_allinone/util/dimensions.dart';
import 'package:handy_allinone/common/widgets/custom_image.dart';

class ItemImageViewWidget extends StatefulWidget {
  final Item? item;
  final bool isCampaign;
  const ItemImageViewWidget({super.key, required this.item, this.isCampaign = false});

  @override
  State<ItemImageViewWidget> createState() => _ItemImageViewWidgetState();
}

class _ItemImageViewWidgetState extends State<ItemImageViewWidget> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  List<String?> _getImageList() {
    if (widget.isCampaign) {
      return [widget.item!.imageFullUrl];
    } else {
      return [widget.item!.imageFullUrl, ...?widget.item!.imagesFullUrl];
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final imageList = _getImageList();

    return GetBuilder<ItemController>(builder: (itemController) {
      return Column(mainAxisSize: MainAxisSize.min, children: [
        InkWell(
          onTap: widget.isCampaign
              ? null
              : () {
            Navigator.of(context).pushNamed(
              RouteHelper.getItemImagesRoute(widget.item!),
              arguments: ItemImageViewWidget(item: widget.item),
            );
          },
          child: Stack(
            children: [
              SizedBox(
                height: ResponsiveHelper.isDesktop(context)
                    ? 400
                    : 350,
                child: PageView.builder(
                  controller: _controller,
                  scrollDirection: Axis.horizontal,
                  itemCount: imageList.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                    itemController.setImageSliderIndex(index);
                  },
                  itemBuilder: (context, index) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(16.r),
                      child: CustomImage1(
                        image: '${imageList[index]}',
                        height: 350,
                        width: MediaQuery.of(context).size.width,
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: SizedBox(
                    height: 65,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: imageList.length,
                      itemBuilder: (context, index) {
                        final isSelected = _currentPage == index;

                        return GestureDetector(
                          onTap: () {
                            setState(() => _currentPage = index);
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: isSelected ? Colors.pink : Colors.transparent,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: CustomImage1(
                                image: '${imageList[index]}',
                                width: 55,
                                height: 55,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              // Page indicators
              // Positioned(
              //   left: 0,
              //   right: 0,
              //   bottom: 0,
              //   child: Padding(
              //     padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
              //     child: Row(
              //       mainAxisAlignment: MainAxisAlignment.center,
              //       children: _indicators(context, itemController, imageList),
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ]);
    });
  }

  List<Widget> _indicators(
      BuildContext context, ItemController itemController, List<String?> imageList) {
    return List.generate(imageList.length, (index) {
      return TabPageSelectorIndicator(
        backgroundColor: index == itemController.imageSliderIndex
            ? Theme.of(context).primaryColor
            : Colors.white,
        borderColor: Colors.white,
        size: 10,
      );
    });
  }
}

// class ItemImageViewWidget extends StatefulWidget {
//   final Item? item;
//   final bool isCampaign;
//   const ItemImageViewWidget({super.key, required this.item, this.isCampaign = false});
//
//   @override
//   State<ItemImageViewWidget> createState() => _ItemImageViewWidgetState();
// }
//
// class _ItemImageViewWidgetState extends State<ItemImageViewWidget> {
//   final PageController _controller = PageController();
//   Timer? _timer;
//   int _currentPage = 0;
//
//   @override
//   void initState() {
//     super.initState();
//     _startAutoScroll();
//   }
//
//   void _startAutoScroll() {
//     _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
//       final imageList = _getImageList();
//       if (_controller.hasClients && imageList.isNotEmpty) {
//         _currentPage++;
//         if (_currentPage >= imageList.length) _currentPage = 0;
//
//         _controller.animateToPage(
//           _currentPage,
//           duration: const Duration(milliseconds: 500),
//           curve: Curves.easeInOut,
//         );
//       }
//     });
//   }
//
//   List<String?> _getImageList() {
//     if (widget.isCampaign) {
//       return [widget.item!.imageFullUrl];
//     } else {
//       return [widget.item!.imageFullUrl, ...?widget.item!.imagesFullUrl];
//     }
//   }
//
//   @override
//   void dispose() {
//     _timer?.cancel();
//     _controller.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final imageList = _getImageList();
//
//     return GetBuilder<ItemController>(builder: (itemController) {
//       return Column(mainAxisSize: MainAxisSize.min, children: [
//         InkWell(
//           onTap: widget.isCampaign
//               ? null
//               : () {
//             Navigator.of(context).pushNamed(
//               RouteHelper.getItemImagesRoute(widget.item!),
//               arguments: ItemImageViewWidget(item: widget.item),
//             );
//           },
//           child: Stack(
//             children: [
//               SizedBox(
//                 height: ResponsiveHelper.isDesktop(context)
//                     ? 350
//                     : MediaQuery.of(context).size.width * 0.7,
//                 child: PageView.builder(
//                   controller: _controller,
//                   scrollDirection: Axis.horizontal, // ensures horizontal scrolling
//                   itemCount: imageList.length,
//                   onPageChanged: (index) {
//                     _currentPage = index; // update current page for auto-scroll
//                     itemController.setImageSliderIndex(index);
//                   },
//                   itemBuilder: (context, index) {
//                     return ClipRRect(
//                       borderRadius: BorderRadius.circular(10),
//                       child: CustomImage(
//                         image: '${imageList[index]}',
//                         height: 300,
//                         width: MediaQuery.of(context).size.width,
//                       ),
//                     );
//                   },
//                 ),
//               ),
//               // Page indicators
//               Positioned(
//                 left: 0,
//                 right: 0,
//                 bottom: 0,
//                 child: Padding(
//                   padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: _indicators(context, itemController, imageList),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ]);
//     });
//   }
//
//   List<Widget> _indicators(
//       BuildContext context, ItemController itemController, List<String?> imageList) {
//     return List.generate(imageList.length, (index) {
//       return TabPageSelectorIndicator(
//         backgroundColor: index == itemController.imageSliderIndex
//             ? Theme.of(context).primaryColor
//             : Colors.white,
//         borderColor: Colors.white,
//         size: 10,
//       );
//     });
//   }
// }

// class ItemImageViewWidget extends StatelessWidget {
//   final Item? item;
//   final bool isCampaign;
//   ItemImageViewWidget({super.key, required this.item, this.isCampaign = false});
//
//   final PageController _controller = PageController();
//
//   @override
//   Widget build(BuildContext context) {
//
//     List<String?> imageList = [];
//     List<String?> imageListForCampaign = [];
//
//     if(isCampaign){
//       imageListForCampaign.add(item!.imageFullUrl);
//     }else{
//       imageList.add(item!.imageFullUrl);
//       imageList.addAll(item!.imagesFullUrl!);
//     }
//
//     return GetBuilder<ItemController>(builder: (itemController) {
//
//       return Column(mainAxisSize: MainAxisSize.min, children: [
//
//           InkWell(
//             onTap: isCampaign ? null : () {
//               if(!isCampaign) {
//                 Navigator.of(context).pushNamed(RouteHelper.getItemImagesRoute(item!), arguments: ItemImageViewWidget(item: item));
//               }
//             },
//             child: Stack(children: [
//               SizedBox(
//                 height: ResponsiveHelper.isDesktop(context)? 350: MediaQuery.of(context).size.width * 0.7,
//                 child: PageView.builder(
//                   controller: _controller,
//                   itemCount: isCampaign ? imageListForCampaign.length : imageList.length,
//                   itemBuilder: (context, index) {
//                     return ClipRRect(
//                       borderRadius: BorderRadius.circular(10),
//                       child: CustomImage(
//                         image: '${isCampaign ? imageListForCampaign[index] : imageList[index]}',
//                         height: 200,
//                         width: MediaQuery.of(context).size.width,
//                       ),
//                     );
//                   },
//                   onPageChanged: (index) {
//                     itemController.setImageSliderIndex(index);
//                   },
//                 ),
//               ),
//               Positioned(
//                 left: 0, right: 0, bottom: 0,
//                 child: Padding(
//                   padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: _indicators(context, itemController, isCampaign ? imageListForCampaign : imageList),
//                   ),
//                 ),
//               ),
//
//             ]),
//           ),
//
//       ]);
//     });
//   }
//
//   List<Widget> _indicators(BuildContext context, ItemController itemController, List<String?> imageList) {
//     List<Widget> indicators = [];
//     for (int index = 0; index < imageList.length; index++) {
//       indicators.add(TabPageSelectorIndicator(
//         backgroundColor: index == itemController.imageSliderIndex ? Theme.of(context).primaryColor : Colors.white,
//         borderColor: Colors.white,
//         size: 10,
//       ));
//     }
//     return indicators;
//   }
//
// }
