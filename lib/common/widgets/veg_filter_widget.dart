import 'package:handy_allinone/common/widgets/custom_asset_image_widget.dart';
import 'package:handy_allinone/features/language/controllers/language_controller.dart';
import 'package:handy_allinone/features/item/controllers/item_controller.dart';
import 'package:handy_allinone/features/splash/controllers/splash_controller.dart';
import 'package:handy_allinone/util/dimensions.dart';
import 'package:handy_allinone/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../util/app_constants.dart';

class VegFilterWidget extends StatelessWidget {
  final String? type;
  final bool fromAppBar;
  final Function(String value)? onSelected;

  const VegFilterWidget(
      {super.key,
      required this.type,
      required this.onSelected,
      this.fromAppBar = false});

  @override
  Widget build(BuildContext context) {
    final bool ltr = Get.find<LocalizationController>().isLtr;
    List<PopupMenuEntry> entryList = [];
    for (int i = 0; i < Get.find<ItemController>().itemTypeList.length; i++) {
      entryList.add(PopupMenuItem<int>(
          value: i,
          child: Row(children: [
            Get.find<ItemController>().itemTypeList[i] == type
                ? Icon(Icons.radio_button_checked_sharp,
                    color: Theme.of(context).primaryColor)
                : Icon(Icons.radio_button_off,
                    color: Theme.of(context).disabledColor),
            const SizedBox(width: Dimensions.paddingSizeExtraSmall),
            Text(
              Get.find<ItemController>().itemTypeList[i].tr,
              style: robotoMedium.copyWith(
                  color: Get.find<ItemController>().itemTypeList[i] == type
                      ? Theme.of(context).textTheme.bodyMedium!.color
                      : Theme.of(context).disabledColor),
            ),
          ])));
    }

    return (Get.find<SplashController>()
                .configModel!
                .moduleConfig!
                .module!
                .vegNonVeg! &&
            Get.find<SplashController>().configModel!.toggleVegNonVeg!)
        ? Padding(
            padding: fromAppBar
                ? EdgeInsets.zero
                : EdgeInsets.only(
                    left: ltr ? Dimensions.paddingSizeSmall : 0,
                    right: ltr ? 0 : Dimensions.paddingSizeSmall),
            child: PopupMenuButton<dynamic>(
              offset: const Offset(-20, 20),
              itemBuilder: (BuildContext context) => entryList,
              onSelected: (dynamic value) =>
                  onSelected!(Get.find<ItemController>().itemTypeList[value]),
              shape: const RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.all(Radius.circular(Dimensions.radiusDefault)),
              ),
              child: Container(
                decoration: fromAppBar
                    ? const BoxDecoration()
                    : BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(Dimensions.radiusDefault),
                        color: Theme.of(context).cardColor,
                        border: Border.all(
                            color: Theme.of(context).primaryColor, width: 1),
                      ),
                padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                child: const Icon(Icons.filter_list, size: 24),
              ),
            ),
          )
        : const SizedBox();
  }
}

class VegFilterWidget1 extends StatelessWidget {
  final String? type;
  final bool fromAppBar;
  final Function(String value)? onSelected;

  const VegFilterWidget1({
    super.key,
    required this.type,
    required this.onSelected,
    this.fromAppBar = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool ltr = Get.find<LocalizationController>().isLtr;

    return (Get.find<SplashController>()
                .configModel!
                .moduleConfig!
                .module!
                .vegNonVeg! &&
            Get.find<SplashController>().configModel!.toggleVegNonVeg!)
        ? Padding(
            padding: fromAppBar
                ? EdgeInsets.zero
                : EdgeInsets.only(
                    left: ltr ? Dimensions.paddingSizeSmall : 0,
                    right: ltr ? 0 : Dimensions.paddingSizeSmall,
                  ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (int i = 0;
                    i < Get.find<ItemController>().itemTypeList.length;
                    i++)
                  GestureDetector(
                    onTap: () {
                      onSelected!(Get.find<ItemController>().itemTypeList[i]);
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Container(
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Get.find<ItemController>().itemTypeList[i] ==
                                  type
                              ? Theme.of(context).primaryColor.withOpacity(0.1)
                              : Theme.of(context).cardColor,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              if (Get.find<ItemController>().itemTypeList[i] ==
                                  'veg')
                                Padding(
                                  padding: const EdgeInsets.only(left: 2.0),
                                  child: Image.asset(
                                    'assets/image/veg.png',
                                    height: 16.0,
                                    width: 16.0,
                                    fit: BoxFit.fill,
                                  ),
                                )
                              else if (Get.find<ItemController>()
                                      .itemTypeList[i] ==
                                  'non_veg')
                                Padding(
                                  padding: const EdgeInsets.only(left: 2.0),
                                  child: Image.asset(
                                    'assets/image/non_veg.png',
                                    height: 16.0,
                                    width: 16.0,
                                    fit: BoxFit.fill,
                                  ),
                                )
                              else
                                Image.asset(
                                  'assets/image/all_spoon.png',
                                  width: 16.0,
                                  height: 16.0,
                                  fit: BoxFit.fill,
                                ),
                              const SizedBox(
                                  width: Dimensions.paddingSizeExtraSmall),
                              Container(
                                child: Row(
                                  children: [
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(right: 3.0),
                                      child: Text(
                                        Get.find<ItemController>()
                                            .itemTypeList[i]
                                            .tr,
                                        style: robotoMedium.copyWith(
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                    const Text(
                                      "Items",
                                      style: TextStyle(
                                        fontFamily: AppConstants.fontFamily,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          )
        : const SizedBox();
  }
}

class VegFilterWidget1Food extends StatefulWidget {
  final String? type;
  final bool fromAppBar;
  final Function(String value)? onSelected;

  const VegFilterWidget1Food({
    super.key,
    required this.type,
    required this.onSelected,
    this.fromAppBar = false,
  });

  @override
  State<VegFilterWidget1Food> createState() => _VegFilterWidget1FoodState();
}

class _VegFilterWidget1FoodState extends State<VegFilterWidget1Food> {
  String? selectedType;

  @override
  void initState() {
    super.initState();
    selectedType = widget.type ?? 'all';
  }

  // void _onChanged(String value) {
  //   setState(() {
  //     selectedType = value;
  //   });
  //   widget.onSelected?.call(value);
  // }
  void _onChanged(String value) {
    setState(() {
      if (selectedType == value) {
        selectedType = null;
        widget.onSelected?.call('all');   // optional: send "all"
      } else {
        selectedType = value;
        widget.onSelected?.call(value);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool ltr = Get.find<LocalizationController>().isLtr;
    final config = Get.find<SplashController>().configModel!;

    if (!(config.moduleConfig?.module?.vegNonVeg ?? false) ||
        !(config.toggleVegNonVeg ?? false)) {
      return const SizedBox();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 7),
              decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                  border: Border.all(color: Colors.grey.shade400)),
              child: Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: _buildImageSwitch(
                  context,
                  type: 'veg',
                  image: 'assets/image/veg.svg',
                ),
              ),
            ),
          ),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 7),
                decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                    border: Border.all(color: Colors.grey.shade400)),
                child: Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: _buildImageSwitch(
                    context,
                    type: 'non_veg',
                    image: 'assets/image/nonveg.svg',
                  ),
                ),
              )),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: GestureDetector(
              onTap: () => _onChanged("all"),
              child: Container(
                decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                    border: Border.all(color: Colors.grey.shade400)),
                padding: const EdgeInsets.symmetric(
                    horizontal: 18, vertical: 4), // Inner padding
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'All Items',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 8),
                    Image.asset(
                      'assets/image/all_spoon.png',
                      height: 12,
                      width: 12,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSwitch(
    BuildContext context, {
    required String type,
    required String image,
  }) {
    final bool isSelected = selectedType == type;

    const double trackWidth = 28;
    const double trackHeight = 16;
    const double thumbSize = 20; // Thumb is slightly bigger than track

    return GestureDetector(
      onTap: () => _onChanged(type),
      child: SizedBox(
        width: trackWidth,
        height: trackHeight,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(trackHeight / 2),
                color: isSelected ? type=='veg'?Colors.green:Colors.red : Colors.grey,
              ),
            ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              left: isSelected ? trackWidth - thumbSize / 2 : -thumbSize / 2,
              top: (trackHeight - thumbSize) / 2,
              // vertically centered
              child: Container(
                width: thumbSize,
                height: thumbSize,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(2),

                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: CustomAssetImageWidget(
                  image,
                  width: thumbSize * 0.6,
                  height: thumbSize * 0.6,
                  fit: BoxFit.cover,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
