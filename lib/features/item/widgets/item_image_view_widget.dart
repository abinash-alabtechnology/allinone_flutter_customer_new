
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
  late PageController _controller;

  List<String?> _getImageList() {
    if (widget.isCampaign) {
      return [widget.item!.imageFullUrl];
    } else {
      return [widget.item!.imageFullUrl, ...?widget.item!.imagesFullUrl];
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: Get.find<ItemController>().imageSliderIndex);
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
                        final isSelected = itemController.imageSliderIndex == index;

                        return GestureDetector(
                          onTap: () {
                            itemController.setImageSliderIndex(index);
                            _controller.animateToPage(index, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
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
            ],
          ),
        ),
      ]);
    });
  }
}
