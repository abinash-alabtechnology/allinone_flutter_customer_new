import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:handy_allinone/common/widgets/custom_image.dart';
import 'package:handy_allinone/util/dimensions.dart';
import 'package:handy_allinone/util/styles.dart';
import 'package:handy_allinone/common/widgets/custom_app_bar.dart';

class QuotationImageScreen extends StatelessWidget {
  final List<String> images;
  const QuotationImageScreen({super.key, required this.images});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.black,
    appBar: CustomAppBar3(
  title: 'View Document'.tr,
  backButton: true,
  leadingIcon: null,
  iconcolor: Theme.of(context).cardColor,
  bgcolor: Theme.of(context).primaryColor,
  textcolor: Theme.of(context).cardColor,
  onBackPressed: () => Get.back(),
),
      body: ListView.builder(
        itemCount: images.length,
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeLarge),
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                child: CustomImage(
                  image: images[index],
                  width: MediaQuery.of(context).size.width,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
