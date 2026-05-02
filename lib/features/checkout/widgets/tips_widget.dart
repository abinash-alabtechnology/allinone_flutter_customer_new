import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:handy_allinone/helper/responsive_helper.dart';
import 'package:handy_allinone/util/dimensions.dart';
import 'package:handy_allinone/util/styles.dart';

class TipsWidget extends StatelessWidget {
  final String title;
  final bool isSelected;
  final Function onTap;
  final bool isSuggested;
  const TipsWidget({super.key, required this.title, required this.isSelected, required this.onTap, required this.isSuggested});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: Dimensions.paddingSizeSmall, top: Dimensions.paddingSizeExtraSmall, bottom: 0),
      child: Column(children: [
        InkWell(
          onTap: onTap as void Function()?,
          child:
          Card(
            elevation: 3,
            child: Column(
              children: [
                Container(
                  padding: ResponsiveHelper.isDesktop(context) ? EdgeInsets.zero :EdgeInsets.symmetric(vertical: isSuggested?0:  5, horizontal: isSuggested?0:Dimensions.paddingSizeSmall),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).cardColor,
                    borderRadius:isSuggested? const BorderRadius.only(topRight: Radius.circular(Dimensions.radiusDefault),topLeft: Radius.circular(Dimensions.radiusDefault)):BorderRadius.circular(Dimensions.radiusDefault),
                    border: isSuggested? null:Border.all(color: ResponsiveHelper.isDesktop(context) ? Theme.of(context).primaryColor : Theme.of(context).cardColor),
                    boxShadow:isSuggested? null: ResponsiveHelper.isDesktop(context) ? [] : const [BoxShadow(color: Colors.black12, spreadRadius: 0.5, blurRadius: 0.5)],
                  ),
                  child: Padding(
                    padding: ResponsiveHelper.isDesktop(context) ? EdgeInsets.only(
                        top: !isSuggested ? Dimensions.fontSizeSmall : Dimensions.paddingSizeExtraSmall,
                        left: Dimensions.paddingSizeSmall, right: Dimensions.paddingSizeSmall,
                    ) : EdgeInsets.zero,
                    child: Padding(
                      padding:  EdgeInsets.only(top:isSuggested?7.0:0),
                      child: Text(
                        title, textDirection: TextDirection.ltr,
                        style: robotoRegular.copyWith(
                          color: isSelected ? Theme.of(context).cardColor : ResponsiveHelper.isDesktop(context)
                              ? Theme.of(context).primaryColor : Theme.of(context).disabledColor,
                        ),
                      ),
                    ),
                  ),
                ),
                isSuggested  ? Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(Dimensions.radiusDefault)),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall, vertical: 5),
                  child: Text(
                    'most_tipped'.tr, style: robotoRegular.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeOverSmall),
                  ),
                ) : SizedBox(height: ResponsiveHelper.isDesktop(context) ? 10 : 0),
              ],
            ),
          ),
        ),
        // const SizedBox(height: Dimensions.paddingSizeExtraSmall -1),
      ]),
    );
  }
}



/// Authore: saravanan jr
/// purpose of the code : parcel required unque tip selection

class TipsWidgetParcel extends StatelessWidget {
  final String title;
  final bool isSelected;
  final Function onTap;
  final bool isSuggested;
  const TipsWidgetParcel(
      {super.key,
        required this.title,
        required this.isSelected,
        required this.onTap,
        required this.isSuggested});

  @override
  Widget build(BuildContext context) {
    Color ifSelected = isSelected
        ? Theme.of(context).primaryColor
        : Theme.of(context).cardColor;
    return Padding(
      padding: const EdgeInsets.only(
          right: Dimensions.paddingSizeSmall,
          top: Dimensions.paddingSizeExtraSmall,
          bottom: 4),
      child: InkWell(
        onTap: onTap as void Function()?,
        child: Container(
          decoration: BoxDecoration(
            color: ifSelected,
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            border: Border.all(color: Theme.of(context).cardColor),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                spreadRadius: 0.5,
                blurRadius: 0.5,
              )
            ],
          ),
          padding: EdgeInsets.symmetric(
            vertical: isSuggested ? 0 : 5,
            horizontal: isSuggested ? 0 : Dimensions.paddingSizeSmall,
          ),
          child: Column(
            mainAxisAlignment:isSuggested? .start: MainAxisAlignment.center,
            children: [
              if (isSuggested)
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: FittedBox(
                          child: Text(
                            "Popular",
                            style: robotoRegular.copyWith(
                              color: Colors.white,
                              fontSize: Dimensions.fontSizeSmall,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              Text(
                title,
                textDirection: TextDirection.ltr,
                style: robotoRegular.copyWith(
                  color: isSelected
                      ? Theme.of(context).cardColor
                      : Colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}