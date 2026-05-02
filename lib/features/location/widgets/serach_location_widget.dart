import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:handy_allinone/features/location/widgets/location_search_dialog_widget.dart';
import 'package:handy_allinone/features/parcel/controllers/parcel_controller.dart';
import 'package:handy_allinone/util/dimensions.dart';
import 'package:handy_allinone/util/styles.dart';

class SearchLocationWidget extends StatefulWidget {
  final GoogleMapController? mapController;
  final String? pickedAddress;
  final bool? isEnabled;
  final bool? isPickedUp;
  final bool? fromDialog;
  final String? hint;
  const SearchLocationWidget({super.key, required this.mapController, required this.pickedAddress, required this.isEnabled, this.isPickedUp, this.hint, this.fromDialog = false});

  @override
  State<SearchLocationWidget> createState() => _SearchLocationWidgetState();
}

class _SearchLocationWidgetState extends State<SearchLocationWidget> {
  bool enabled=false;


  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        setState(() {
          enabled=true;
        });
        Get.dialog(
          LocationSearchDialogWidget(
            mapController: widget.mapController,
            isPickedUp: widget.isPickedUp,
          )).
        whenComplete(() {
          if (mounted) {
            setState(() => enabled = false);
          }
        });
        if(widget.isEnabled != null) {
          Get.find<ParcelController>().setIsPickedUp(widget.isPickedUp, true);
        }
      },
      child: enabled==false?Container(
        decoration:  BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(15),bottomRight: Radius.circular(15))),
        child: IntrinsicHeight(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Gap(15),
              Row(
                children: [
                  const Gap(10),
                  InkWell(
                      onTap:(){
                        Get.back();
                      },
                      child: const Icon(Icons.arrow_back_ios,size: 24,)),
                  const Gap(20),
                  Text('type_your_address_here_to_pick_form_map'.tr,
                      style: robotoRegular.copyWith(color: Colors.grey.shade700)),
                  const Gap(10),
                ],
              ),
              const Gap(15),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                    border: widget.isEnabled != null ? Border.all(
                      color: widget.fromDialog! ? Theme.of(context).disabledColor : widget.isEnabled! ? Theme.of(context).primaryColor : Theme.of(context).disabledColor, width: widget.isEnabled! ? 2 : 1,
                    ) : null,
                  ),
                  child: Row(children: [
                    (/*!fromDialog! &&*/ widget.pickedAddress != null && widget.pickedAddress!.isNotEmpty) ? const Icon(
                      Icons.location_on, size: 25,
                      // color: (isEnabled == null || isEnabled!) ? Theme.of(context).primaryColor : Theme.of(context).disabledColor,
                    ) : Text('search_location'.tr, style: robotoRegular.copyWith()),
                    const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                    Expanded(
                      child: (widget.pickedAddress != null && widget.pickedAddress!.isNotEmpty) ? Text(
                        widget.pickedAddress!,
                        style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault), maxLines: 1, overflow: TextOverflow.ellipsis,
                      ) : Text(
                        widget.hint ?? '',
                        style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).hintColor),
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeSmall),
                    const Icon(Icons.search, size: 25,
                       // color: fromDialog! ? Theme.of(context).disabledColor : Theme.of(context).textTheme.bodyLarge!.color
                    ),
                  ]),
                ),
              ),
              const Gap(15),
            ],
          ),
        ),
      ):const SizedBox(),
    );
  }
}
