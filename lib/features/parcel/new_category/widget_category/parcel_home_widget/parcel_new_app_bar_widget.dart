import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:handy_allinone/features/location/controllers/location_controller.dart';
import 'package:handy_allinone/features/notification/controllers/notification_controller.dart';
import 'package:handy_allinone/features/parcel/new_category/widget_category/parcel_home_widget/parcel_icon_holder_widget.dart';
import 'package:handy_allinone/features/splash/controllers/splash_controller.dart';
import 'package:handy_allinone/helper/address_helper.dart';
import 'package:handy_allinone/helper/route_helper.dart';
import 'package:handy_allinone/util/app_constants.dart';
import 'package:handy_allinone/util/dimensions.dart';
import 'package:handy_allinone/util/styles.dart';

class ParcelNewAppBarWidget extends StatelessWidget
    implements PreferredSizeWidget {
  const ParcelNewAppBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF2C2C2C),
      bottomOpacity: 0,
      surfaceTintColor: const Color(0xFF2C2C2C),
      title: GetBuilder<SplashController>(
        builder: (splashController) {
          return Row(
            children: [
              const ParcelIconHolderWidget(icon: Icons.location_on),
              Expanded(
                child: InkWell(
                  onTap: () => Get.find<LocationController>()
                      .navigateToLocationScreen('home'),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: Dimensions.paddingSizeSmall,
                      horizontal: Dimensions.paddingSizeSmall,
                    ),
                    child: GetBuilder<LocationController>(
                      builder: (locationController) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AddressHelper.getUserAddressFromSharedPref()!
                                  .addressType!
                                  .tr,
                              style: robotoBold.copyWith(
                                color: Colors.white,
                                fontSize: Dimensions.fontSizeLarge,
                                fontWeight: FontWeight.w900
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    AddressHelper
                                            .getUserAddressFromSharedPref()!
                                        .address!,
                                    style: robotoRegular.copyWith(
                                      color: Colors.white70,
                                      fontSize: Dimensions.fontSizeSmall,

                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const Icon(
                                  Icons.expand_more_rounded,
                                  color: Colors.white,
                                  size: 22,
                                  weight: 2,
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
              GetBuilder<NotificationController>(
                builder: (notificationController) {
                  return Stack(
                    children: [
                      ParcelIconHolderWidget(
                        icon: CupertinoIcons.bell,
                        onTap: () =>
                            Get.toNamed(RouteHelper.getNotificationRoute()),
                      ),
                      notificationController.hasNotification
                          ? Positioned(
                              top: 0,
                              right: 0,
                              child: Container(
                                height: 10,
                                width: 10,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      width: 1,
                                      color: Theme.of(context).cardColor),
                                ),
                              ))
                          : const SizedBox(),
                    ],
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60);
}
