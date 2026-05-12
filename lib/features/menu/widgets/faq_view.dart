import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/faq_controller.dart';
import '../../../util/dimensions.dart';
import '../../../util/styles.dart';

class FaqView extends StatelessWidget {
  const FaqView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FaqController>(builder: (faqController) {
      return faqController.isLoading
          ? const Center(child: CircularProgressIndicator())
          : faqController.faqList == null || faqController.faqList!.isEmpty
              ? Center(child: Text('no_faq_found'.tr))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'frequently_asked_questions'.tr,
                        style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge),
                      ),
                      const SizedBox(height: Dimensions.paddingSizeDefault),
                      ListView.builder(
                        itemCount: faqController.faqList!.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          final faq = faqController.faqList![index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Theme(
                              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                              child: ExpansionTile(
                                leading: Icon(Icons.help_outline, color: Theme.of(context).primaryColor),
                                title: Text(
                                  faq.question ?? '',
                                  style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault),
                                ),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: Dimensions.paddingSizeExtraLarge + Dimensions.paddingSizeDefault,
                                      right: Dimensions.paddingSizeDefault,
                                      bottom: Dimensions.paddingSizeDefault,
                                    ),
                                    child: Text(
                                      faq.answer ?? '',
                                      style: robotoRegular.copyWith(
                                        fontSize: Dimensions.fontSizeSmall,
                                        color: Theme.of(context).disabledColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
    });
  }
}
