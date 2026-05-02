import 'package:flutter/cupertino.dart';
import 'package:handy_allinone/features/location/controllers/location_controller.dart';
import 'package:handy_allinone/features/location/domain/models/prediction_model.dart';
import 'package:handy_allinone/features/parcel/controllers/parcel_controller.dart';
import 'package:handy_allinone/helper/responsive_helper.dart';
import 'package:handy_allinone/util/dimensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:handy_allinone/util/styles.dart';

class LocationSearchDialogWidget extends StatelessWidget {
  final GoogleMapController? mapController;
  final bool? isPickedUp;
  final bool isFrom;

  const LocationSearchDialogWidget(
      {super.key,
      required this.mapController,
      this.isPickedUp,
      this.isFrom = false});

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller = TextEditingController();

    return Container(
      width: 500,
      margin: EdgeInsets.only(
        top: ResponsiveHelper.isDesktop(context) ? 180 : 0,
      ),
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      alignment: Alignment.topCenter,
      child: Column(
        children: [
          Material(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Dimensions.radiusLarge)),
            child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color: Theme.of(context).cardColor),
                width: ResponsiveHelper.isDesktop(context)
                    ? 600
                    : Dimensions.webMaxWidth,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      TypeAheadField<PredictionModel>(
                        controller: controller,
                        suggestionsCallback: (pattern) async {
                          return await Get.find<LocationController>()
                              .searchLocation(context, pattern);
                        },

                        builder: (context, textController, focusNode) {
                          return TextField(
                            controller: textController,
                            focusNode: focusNode,
                            textInputAction: TextInputAction.search,
                            autofocus: true,
                            textCapitalization: TextCapitalization.words,
                            keyboardType: TextInputType.streetAddress,
                            decoration: InputDecoration(
                              prefixIcon: InkWell(
                                onTap: () => Get.back(),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                    ),
                                    child: const Padding(
                                      padding: EdgeInsets.all(3.0),
                                      child: Icon(Icons.arrow_back),
                                    ),
                                  ),
                                ),
                              ),
                              hintText: 'Search for Area,street name....etc',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                              hintStyle: Theme.of(context).textTheme.displayMedium!.copyWith(
                                fontSize: Dimensions.fontSizeDefault,
                                color: Theme.of(context).disabledColor,
                              ),
                              filled: true,
                              fillColor: Theme.of(context).cardColor,
                            ),
                            style: Theme.of(context).textTheme.displayMedium!.copyWith(
                              color: Theme.of(context).textTheme.bodyLarge!.color,
                              fontSize: Dimensions.fontSizeLarge,
                            ),
                          );
                        },

                        itemBuilder: (context, suggestion) {
                          final parts = suggestion.description?.split(',') ?? [];
                          final city = parts.isNotEmpty ? parts.first.trim() : '';
                          final rest =
                          parts.length > 1 ? parts.sublist(1).join(',').trim() : '';

                          return Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(10),
                                          color: Colors.green.withAlpha(15),
                                        ),
                                        padding: const EdgeInsets.all(4.0),
                                        child: const Icon(Icons.location_on_outlined,
                                            color: Colors.green),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(city,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: Theme.of(context).textTheme.displayMedium!.copyWith(
                                                  color: Theme.of(context)
                                                      .textTheme
                                                      .bodyLarge!
                                                      .color,
                                                  fontSize: Dimensions.fontSizeLarge,
                                                )),
                                            const SizedBox(height: 5),
                                            Text(rest,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: Theme.of(context).textTheme.displayMedium!.copyWith(
                                                  color: Colors.grey.shade400,
                                                  fontSize: Dimensions.fontSizeDefault,
                                                )),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Icon(
                                        CupertinoIcons.arrow_up_left,
                                        color: Colors.grey.shade500,
                                        size: 18,
                                      ),
                                    ],
                                  ),
                                  Divider(color: Colors.grey.shade200),
                                ],
                              ),
                            ),
                          );
                        },

                        onSelected: (suggestion) {
                          if (isPickedUp == null) {
                            Get.find<LocationController>().setLocation(
                              suggestion.placeId,
                              suggestion.description,
                              mapController,
                            );
                          } else {
                            Get.find<ParcelController>().setLocationFromPlace(
                              suggestion.placeId,
                              suggestion.description,
                              isPickedUp,
                            );
                          }
                          Get.back();
                        },

                        emptyBuilder: (_) => const Padding(
                          padding: EdgeInsets.all(10),
                          child: Text('No results found'),
                        ),
                        decorationBuilder: (context, child) {
                          return Material(
                            elevation: 4,
                            borderRadius: BorderRadius.circular(18),
                            color: Theme.of(context).cardColor,
                            child: child,
                          );
                        },

                      ),

                      // TypeAheadField(
                      //   textFieldConfiguration: TextFieldConfiguration(
                      //     controller: controller,
                      //     textInputAction: TextInputAction.search,
                      //     autofocus: true,
                      //     textCapitalization: TextCapitalization.words,
                      //     keyboardType: TextInputType.streetAddress,
                      //     decoration: InputDecoration(
                      //       prefixIcon: InkWell(
                      //         onTap: () {
                      //           Get.back();
                      //         },
                      //         child: Padding(
                      //           padding: const EdgeInsets.all(8.0),
                      //           child: Container(
                      //               decoration: BoxDecoration(
                      //                   color: Colors.grey.shade100,
                      //                   borderRadius: BorderRadius.circular(
                      //                       Dimensions.radiusDefault)),
                      //               child: const Padding(
                      //                 padding: EdgeInsets.all(3.0),
                      //                 child: Icon(Icons.arrow_back),
                      //               )),
                      //         ),
                      //       ),
                      //       hintText: 'Search for Area,street name....etc',
                      //       border: OutlineInputBorder(
                      //         borderRadius: BorderRadius.circular(10),
                      //         borderSide: const BorderSide(
                      //             style: BorderStyle.none, width: 0),
                      //       ),
                      //       hintStyle: Theme.of(context)
                      //           .textTheme
                      //           .displayMedium!
                      //           .copyWith(
                      //             fontSize: Dimensions.fontSizeDefault,
                      //             color: Theme.of(context).disabledColor,
                      //           ),
                      //       filled: true,
                      //       fillColor: Theme.of(context).cardColor,
                      //     ),
                      //     style: Theme.of(context)
                      //         .textTheme
                      //         .displayMedium!
                      //         .copyWith(
                      //           color: Theme.of(context)
                      //               .textTheme
                      //               .bodyLarge!
                      //               .color,
                      //           fontSize: Dimensions.fontSizeLarge,
                      //         ),
                      //   ),
                      //   suggestionsCallback: (pattern) async {
                      //     return await Get.find<LocationController>()
                      //         .searchLocation(context, pattern);
                      //   },
                      //   itemBuilder: (context, PredictionModel suggestion) {
                      //
                      //     final List<String> parts =
                      //         suggestion.description?.split(',') ?? <String>[];
                      //     final String city = parts.isNotEmpty ? parts.first.trim() : '';
                      //     final String rest = parts.length > 1
                      //         ? parts.sublist(1).join(',').trim()
                      //         : '';
                      //
                      //     return Container(
                      //       decoration: BoxDecoration(borderRadius: BorderRadius.circular(18),
                      //       ),
                      //       child: Padding(
                      //         padding: const EdgeInsets.all(
                      //             Dimensions.paddingSizeSmall),
                      //         child: Column(
                      //           children: [
                      //             Row(children: [
                      //               Container(
                      //                 decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),color: Colors.green.withAlpha(15)),
                      //                 padding: const EdgeInsets.all(4.0),
                      //                 child: const Icon(Icons.location_on_outlined,color: Colors.green,),
                      //               ),
                      //               const SizedBox(width: 10,),
                      //               Expanded(
                      //                 child: Column(
                      //                   mainAxisAlignment: MainAxisAlignment.start,
                      //                   crossAxisAlignment: CrossAxisAlignment.start,
                      //                   children: [
                      //                     Text(city,
                      //                         maxLines: 1,
                      //                         overflow: TextOverflow.ellipsis,
                      //                         style: Theme.of(context)
                      //                             .textTheme
                      //                             .displayMedium!
                      //                             .copyWith(
                      //                           color: Theme.of(context)
                      //                               .textTheme
                      //                               .bodyLarge!
                      //                               .color,
                      //                           fontSize: Dimensions.fontSizeLarge,
                      //                         )),
                      //                     const SizedBox(height: 5,),
                      //                     Text(rest,
                      //                         maxLines: 1,
                      //                         overflow: TextOverflow.ellipsis,
                      //                         style: Theme.of(context)
                      //                             .textTheme
                      //                             .displayMedium!
                      //                             .copyWith(
                      //                               color:Colors.grey.shade400,
                      //                               fontSize: Dimensions.fontSizeDefault,
                      //                             )),
                      //                   ],
                      //                 ),
                      //               ),
                      //               const SizedBox(width: 10,),
                      //               Icon(CupertinoIcons.arrow_up_left,color: Colors.grey.shade500,size: 18,)
                      //             ]),
                      //             Divider(color: Colors.grey.shade200,)
                      //           ],
                      //         ),
                      //       ),
                      //     );
                      //   },
                      //   suggestionsBoxDecoration: SuggestionsBoxDecoration(
                      //     borderRadius: BorderRadius.circular(18),
                      //     elevation: 4,
                      //     color: Theme.of(context).cardColor,
                      //   ),
                      //   onSuggestionSelected: (PredictionModel suggestion) {
                      //     if (isPickedUp == null) {
                      //       Get.find<LocationController>().setLocation(
                      //           suggestion.placeId,
                      //           suggestion.description,
                      //           mapController);
                      //     } else {
                      //       Get.find<ParcelController>().setLocationFromPlace(
                      //           suggestion.placeId,
                      //           suggestion.description,
                      //           isPickedUp);
                      //     }
                      //     Get.back();
                      //   },
                      // ),
                      Divider(
                        color: Colors.grey.shade500,
                      ),
                      InkWell(
                        onTap: () {
                          final stopwatch = Stopwatch()..start();
                            debugPrint("dkmkmkd");
                            Get.back();
                            Get.find<LocationController>().checkPermission(() {
                              Get.find<LocationController>().getCurrentLocation(
                                false,
                                mapController: mapController,
                              );
                            stopwatch.stop();
                            debugPrint("Execution Time: ${stopwatch.elapsedMilliseconds} ms");
                          });

                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        color: Colors.green
                                            .withValues(alpha: 0.1)),
                                    padding: const EdgeInsets.all(8.0),
                                    child: const Icon(Icons.my_location,
                                        size: 15, color: Colors.green),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Use current location",
                                        style: robotoRegular.copyWith(
                                            color: Colors.grey.shade700),
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      Text(
                                        "Using GPS",
                                        style: robotoRegular.copyWith(
                                            color: Colors.grey.shade300),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Icon(Icons.arrow_forward_ios_rounded,
                                  size: 20, color: Colors.grey.shade400),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                )),
          ),
        ],
      ),
    );
  }
}
