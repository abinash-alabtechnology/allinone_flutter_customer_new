import 'package:flutter/cupertino.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:handy_allinone/common/widgets/custom_asset_image_widget.dart';
import 'package:handy_allinone/common/widgets/custom_ink_well.dart';
import 'package:handy_allinone/features/banner/controllers/banner_controller.dart';
import 'package:handy_allinone/features/splash/controllers/splash_controller.dart';
import 'package:handy_allinone/features/store/controllers/store_controller.dart';
import 'package:handy_allinone/helper/auth_helper.dart';
import 'package:handy_allinone/util/app_constants.dart';
import 'package:handy_allinone/util/dimensions.dart';
import 'package:handy_allinone/common/widgets/custom_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:handy_allinone/features/home/widgets/banner_view.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../common/models/module_model.dart';
import '../../../common/widgets/custom_snackbar.dart';
import '../../../helper/address_helper.dart';
import 'package:handy_allinone/features/menu/screens/menu_screen.dart';
import '../../../helper/responsive_helper.dart';
import '../../../helper/route_helper.dart';
import '../../../util/images.dart';
import '../../../util/styles.dart';
import '../../favourite/controllers/favourite_controller.dart';
import '../../language/controllers/language_controller.dart';
import '../../location/controllers/location_controller.dart';
import '../../menu/screens/menu_screen.dart';
import '../../notification/controllers/notification_controller.dart';
import '../../profile/controllers/profile_controller.dart';
import 'package:handy_allinone/features/home/widgets/request_based_delivery_widget.dart';
import '../../store/screens/store_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:handy_allinone/Taxi/Taxi_home.dart';
import 'package:handy_allinone/Taxi/ridesummary.dart';
import 'package:handy_allinone/Taxi/sharedservice.dart';
import 'package:handy_allinone/features/handyman/services/screens/handyman_services_screen.dart';

class ModuleView extends StatelessWidget {
  final ScrollController scrollController;
  final SplashController splashController;

  const ModuleView({
    super.key,
    required this.splashController,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Premium Header Section
        Container(
          padding: EdgeInsets.fromLTRB(16, 10 + MediaQuery.of(context).padding.top, 16, 12),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting Row
              GetBuilder<ProfileController>(builder: (profileController) {
                String name = profileController.userInfoModel?.fName ?? 'User';
                return Row(
                  children: [
                    InkWell(
                      onTap: () => Get.to(() => const MenuScreen()),
                      child: Image.asset('assets/image/profile_emoji.png', height: 40, width: 40),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Hello, $name 👋',
                      style: GoogleFonts.inter(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                  ],
                );
              }),
              const SizedBox(height: 12),
              
              // Location and Search Row
              Row(
                children: [
                  const Icon(Icons.location_on, color: Color(0xFF16A34A), size: 24),
                  const SizedBox(width: 8),
                  Expanded(
                    child: InkWell(
                      onTap: () => Get.find<LocationController>().navigateToLocationScreen('home'),
                      child: Text(
                        AddressHelper.getUserAddressFromSharedPref()?.address ?? 'Select Location',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF4B5563),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () => Get.toNamed(RouteHelper.getSearchRoute()),
                    child: const Icon(Icons.search, color: Color(0xFF4B5563), size: 24),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Banner Section
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: const BannerViewModule(isFeatured: true),
          ),
        ),

        const SizedBox(height: 16),

        // Explore Section
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Explore Handy',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1F2937),
            ),
          ),
        ),

        const SizedBox(height: 12),

        Skeletonizer(
          enabled: splashController.moduleList == null,
          child: (splashController.moduleList != null && splashController.moduleList!.isNotEmpty)
              ? (() {
                  bool isHandymanActive = splashController.moduleList!.any((m) {
                    String title = m.moduleName?.toLowerCase() ?? '';
                    String mType = m.moduleType?.toLowerCase() ?? '';
                    return title.contains('handyman') || mType.contains('handyman');
                  });

                  final List<Map<String, dynamic>> extraModules = [
                    {
                      'title': 'Ride',
                      'subtitle': 'Cars, bikes & commercial...',
                      'imageAsset': Images.rentalIcon,
                      'color': const Color(0xFF3B82F6), // Blue 500
                      'iconColor': const Color(0xFF2563EB),
                      'isComingSoon': false,
                    },
                    if (isHandymanActive)
                      {
                        'title': 'Handyman',
                        'subtitle': 'Instant gratification, delivered to your door.',
                        'imageAsset': Images.handymanIcon,
                        'color': const Color(0xFF10B981), // Emerald 500
                        'iconColor': const Color(0xFF059669),
                        'isComingSoon': false,
                      },
                    {
                      'title': 'Utility',
                      'subtitle': 'Coming soon...',
                      'imageAsset': Images.utilityIcon,
                      'color': const Color(0xFF6366F1), // Indigo 500
                      'iconColor': const Color(0xFF4F46E5),
                      'isComingSoon': true,
                    },
                  ];

                  final displayModules = splashController.moduleList!.where((m) {
                    String title = m.moduleName?.toLowerCase() ?? '';
                    String mType = m.moduleType?.toLowerCase() ?? '';
                    bool isTaxi = title.contains('taxi') ||
                        title.contains('ride') ||
                        title.contains('cab') ||
                        title.contains('auto') ||
                        mType == 'taxi' ||
                        mType == AppConstants.taxi;
                    bool isHandyman = title.contains('handyman') || mType.contains('handyman');
                    return !isTaxi && !isHandyman;
                  }).toList();

                  return GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      mainAxisExtent: 85,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: displayModules.length + extraModules.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      if (index < displayModules.length) {
                        final module = displayModules[index];
                        String title = module.moduleName ?? '';
                        String subtitle = '';
                        Color bgColor = Colors.white;
                        Color iconColor = Colors.green;
                        IconData iconData = Icons.shopping_basket;
                        String? localAsset;

                        String mType = module.moduleType ?? '';

                        if (title.toLowerCase().contains('grocery') || mType == 'grocery') {
                          subtitle = 'Essentials & Daily Needs';
                          bgColor = const Color(0xFF1E7F35); // Dark Green
                          iconColor = const Color(0xFF00E676); // Vibrant Green
                          iconData = Icons.shopping_cart_outlined;
                          localAsset = 'assets/image/groceryicon.png';
                        } else if (title.toLowerCase().contains('meat') || title.toLowerCase().contains('fish') || mType == 'meat') {
                          subtitle = 'Premium Fresh Cuts & Seafood';
                          bgColor = const Color(0xFFEF4444);
                          iconColor = const Color(0xFFB91C1C);
                          iconData = Icons.kebab_dining;
                          localAsset = Images.meatModule;
                        } else if (title.toLowerCase().contains('food') || mType == 'food') {
                          subtitle = 'Restaurants & Meals';
                          bgColor = const Color(0xFFF97316); // Orange 500
                          iconColor = const Color(0xFFEA580C);
                          iconData = Icons.restaurant_outlined;
                          localAsset = 'assets/image/foodicon.png';
                        } else if (title.toLowerCase().contains('parcel') || mType == 'parcel') {
                          subtitle = 'Send & Track';
                          bgColor = const Color(0xFFEF4444); // Red 500
                          iconColor = const Color(0xFFDC2626);
                          iconData = Icons.inventory_2_outlined;
                          localAsset = 'assets/image/parcelicon.png';
                        } else if (title.toLowerCase().contains('pharmacy') || mType == 'pharmacy') {
                          subtitle = 'Medicines & Health';
                          bgColor = const Color(0xFF0EA5E9); // Sky 500
                          iconColor = const Color(0xFF0284C7);
                          iconData = Icons.medical_services_outlined;
                          localAsset = 'assets/image/pharmacyicon.png';
                        } else if (title.toLowerCase().contains('shop') || title.toLowerCase().contains('ecommerce') || title.toLowerCase().contains('market') || mType == 'ecommerce') {
                          subtitle = 'Shop Your Favorites';
                          bgColor = const Color(0xFF8B5CF6); // Violet 500
                          iconColor = const Color(0xFF7C3AED);
                          iconData = Icons.shopping_bag_outlined;
                        } else {
                          subtitle = module.description ?? 'Quality Services';
                          bgColor = Colors.blueGrey;
                          iconColor = Colors.grey;
                        }

                        return _buildModuleCard(
                          context,
                          title: title,
                          subtitle: subtitle,
                          imageUrl: module.iconFullUrl,
                          iconAsset: localAsset,
                          icon: iconData,
                          color: bgColor,
                          iconColor: iconColor,
                          onTap: () async {
                            splashController.showBottomNavBar();
                            scrollController.animateTo(0, duration: const Duration(milliseconds: 400), curve: Curves.easeIn);
                            
                            int originalIndex = splashController.moduleList!.indexOf(module);
                            if (originalIndex != -1) {
                              splashController.switchModule(originalIndex, true);
                            }
                          },
                        );
                      } else {
                        // Extra Modules Logic
                        int extraIndex = index - displayModules.length;
                        final extra = extraModules[extraIndex];

                        return _buildModuleCard(
                          context,
                          title: extra['title'],
                          subtitle: extra['subtitle'],
                          iconAsset: extra['imageAsset'],
                          color: extra['color'],
                          iconColor: extra['iconColor'],
                          onTap: extra['title'] == 'Handyman'
                              ? () => Get.to(() => const HandymanServicesScreen())
                              : extra['isComingSoon'] == true
                                  ? () {}
                                  : () async {
                            // Find the taxi/ride module index from the actual list
                            int taxiIndex = splashController.moduleList!.indexWhere((m) =>
                                (m.moduleName?.toLowerCase().contains('taxi') ?? false) ||
                                (m.moduleName?.toLowerCase().contains('ride') ?? false) ||
                                m.moduleType == 'taxi' ||
                                m.moduleType == AppConstants.taxi);

                            if (taxiIndex != -1) {
                              splashController.showBottomNavBar();
                              scrollController.animateTo(0, duration: const Duration(milliseconds: 400), curve: Curves.easeIn);
                              // Manually set the module to avoid switchModule's navigation to index 0
                              splashController.setModule(splashController.moduleList![taxiIndex]);
                            }
                            
                            // Replicate the exact Ride tab flow from DashboardScreen
                            var ongoingBooking = await SharedService.getOngoingBooking();
                            // Fallback to basic booking info if ongoing (with driver) is null
                            ongoingBooking ??= await SharedService.getBookingIdFromPrefs();

                            if (ongoingBooking != null) {
                              int bookingId = ongoingBooking['bookingId'];
                              int? driverId = ongoingBooking['driverId']; // Can be null for pending
                              int userId = ongoingBooking['userId'];
                              String otp = ongoingBooking['otp'];

                              final ref = FirebaseDatabase.instanceFor(
                                app: Firebase.app(),
                                databaseURL: AppConstants.firebaseDBURL,
                                ).ref('bookings/$bookingId');
                              
                              final snapshot = await ref.get();
                              if (snapshot.exists && snapshot.value is Map) {
                                final bookingData = snapshot.value as Map;
                                String status = bookingData['ride_status']?.toString() ?? '';
                                if (['accepted', 'arrived', 'in_progress', 'dropped'].contains(status)) {
                                  int resolvedDriverId = 0;
                                  final driverIdsMap = bookingData['driver_ids'];
                                  if (driverIdsMap is Map && driverIdsMap.isNotEmpty) {
                                    final rawDriverKey = driverIdsMap.keys.first;
                                    resolvedDriverId = int.tryParse(
                                      rawDriverKey.replaceAll(RegExp(r'[^0-9]'), ''),
                                    ) ?? 0;
                                  }
                                  if (resolvedDriverId != 0) {
                                    await SharedService.saveOngoingBooking(
                                      bookingId,
                                      resolvedDriverId,
                                      userId,
                                      otp,
                                    );
                                  }
                                  Get.to(() => RideConfirmedScreen(
                                    Bookingid: bookingId,
                                    driverid: resolvedDriverId != 0 ? resolvedDriverId : (driverId ?? 0),
                                    userId: userId,
                                    otp: otp,
                                  ));
                                  return;
                                } else if (status == 'pending') {
                                  Get.to(() => Taxihome(
                                    showBottomSheet: true,
                                    bookingId: bookingId,
                                    userId: userId,
                                    otp: otp,
                                  ));
                                  return;
                                }
                              }
                            }
                            
                            // If no ongoing ride, go to the default Ride tab
                            Get.offAllNamed(RouteHelper.getMainRoute('cart')); // 'cart' maps to index 2 in RouteHelper
                          },
                        );
                      }
                    },
                  );
                })()
              : notInYourAreaWidget(),
        ),

        GetBuilder<StoreController>(
          builder: (storeController) {
            final storeList = storeController.featuredStoreList;
            return Skeletonizer(
              enabled: storeList == null,
              child: (storeList != null && storeList.isNotEmpty)
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 24),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'featured_stores'.tr,
                                    style: GoogleFonts.inter(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF1F2937),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Discover top rated stores",
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      color: const Color(0xFF6B7280),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              TextButton(
                                onPressed: () => Get.toNamed(RouteHelper.getAllStoreRoute('featured')),
                                style: TextButton.styleFrom(
                                  foregroundColor: const Color(0xFF16A34A),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  backgroundColor: const Color(0xFFF0FDF4),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                child: Text('See all', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 280,
                          child: ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.only(left: 16),
                            itemCount: storeList.length > 10 ? 10 : storeList.length,
                            itemBuilder: (context, index) {
                              final store = storeList[index];
                              return Padding(
                                padding: const EdgeInsets.only(right: 16, bottom: 8),
                                child: Container(
                                  width: 280,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: CustomInkWell(
                                    onTap: !storeController.isOpenNow(store)
                                        ? () => showCustomSnackBar("store_is_closed".tr, isError: true)
                                        : () {
                                            if (Get.find<SplashController>().moduleList != null) {
                                              for (ModuleModel module in Get.find<SplashController>().moduleList!) {
                                                if (module.id == store.moduleId) {
                                                  Get.find<SplashController>().setModule(module);
                                                  break;
                                                }
                                              }
                                            }
                                            Get.toNamed(RouteHelper.getStoreRoute(id: store.id, page: 'module'),
                                                arguments: StoreScreen(store: store, fromModule: true));
                                          },
                                    radius: 16,
                                    child: Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(16),
                                          child: ColorFiltered(
                                            colorFilter: storeController.isOpenNow(store)
                                                ? const ColorFilter.mode(Colors.transparent, BlendMode.dst)
                                                : const ColorFilter.mode(Colors.grey, BlendMode.saturation),
                                            child: CustomImage(
                                              image: store.coverPhotoFullUrl ?? "",
                                              height: 280,
                                              width: 280,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        Positioned.fill(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(16),
                                              gradient: LinearGradient(
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                                colors: [Colors.transparent, Colors.black.withValues(alpha: 0.8)],
                                              ),
                                            ),
                                          ),
                                        ),
                                        if (!storeController.isOpenNow(store))
                                          Positioned.fill(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.black.withValues(alpha: 0.35),
                                                borderRadius: BorderRadius.circular(16),
                                              ),
                                            ),
                                          ),
                                        Positioned(
                                          top: 12,
                                          left: 12,
                                          child: GetBuilder<FavouriteController>(builder: (fc) {
                                            final isWished = fc.wishStoreIdList.contains(store.id);
                                            return InkWell(
                                              onTap: () {
                                                if (AuthHelper.isLoggedIn()) {
                                                  isWished ? fc.removeFromFavouriteList(store.id, true) : fc.addToFavouriteList(null, store.id, true);
                                                } else {
                                                  showCustomSnackBar('you_are_not_logged_in'.tr);
                                                }
                                              },
                                              child: Container(
                                                padding: const EdgeInsets.all(6),
                                                decoration: const BoxDecoration(color: Colors.black45, shape: BoxShape.circle),
                                                child: Icon(isWished ? Icons.favorite : Icons.favorite_border, size: 20, color: Colors.white),
                                              ),
                                            );
                                          }),
                                        ),
                                        Positioned(
                                          bottom: 12,
                                          left: 12,
                                          right: 12,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(store.name ?? "", style: GoogleFonts.inter(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  const Icon(Icons.star, color: Colors.amber, size: 14),
                                                  const SizedBox(width: 4),
                                                  Text(store.avgRating?.toStringAsFixed(1) ?? "0.0", style: GoogleFonts.inter(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                                                  const SizedBox(width: 8),
                                                  Container(width: 4, height: 4, decoration: const BoxDecoration(color: Colors.white54, shape: BoxShape.circle)),
                                                  const SizedBox(width: 8),
                                                  const Icon(Icons.access_time, color: Colors.white70, size: 14),
                                                  const SizedBox(width: 4),
                                                  Text(store.deliveryTime ?? "", style: GoogleFonts.inter(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (!storeController.isOpenNow(store))
                                          const Positioned(top: 10, right: 10, child: PendulumImage(asset: Images.closed, angle: 20, size: 80)),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    )
                  : const SizedBox.shrink(),
            );
          },
        ),

        const RequestBasedDeliveryWidget(),
        const SizedBox(height: 24),
        
        // Footer section
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Live\nit up!",
                style: GoogleFonts.inter(
                  fontSize: 70,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFFE5E7EB),
                  height: 0.9,
                ),
              ),
              const SizedBox(height: 12),
              RichText(
                text: TextSpan(
                  style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF6B7280)),
                  children: [
                    const TextSpan(text: 'Crafted with '),
                    WidgetSpan(child: Icon(Icons.favorite, color: Colors.red.shade400, size: 16)),
                    const TextSpan(text: ' in Tamilnadu, India'),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildModuleCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    String? imageUrl,
    String? iconAsset,
    IconData? icon,
    required Color color,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2), width: 1),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.05),
              blurRadius: 10,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: iconAsset != null
                      ? Image.asset(iconAsset, height: 36, width: 36)
                      : imageUrl != null
                          ? CustomImage(image: imageUrl, height: 32, width: 32, color: iconColor)
                          : Icon(icon, color: iconColor, size: 28),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        title,
                        maxLines: 1,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1F2937),
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF6B7280),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PendulumImage extends StatefulWidget {
  final String asset;
  final double angle; // in degrees
  final Duration duration;
  final double size;

  const PendulumImage({
    super.key,
    required this.asset,
    this.angle = 18, // recommended swing angle
    this.duration = const Duration(seconds: 2),
    this.size = 150,
  });

  @override
  State<PendulumImage> createState() => _PendulumImageState();
}

class _PendulumImageState extends State<PendulumImage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat(reverse: true);

    _animation = Tween<double>(
      begin: -widget.angle,
      end: widget.angle,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      child: Image.asset(widget.asset, width: widget.size, height: widget.size),
      builder: (context, child) {
        return Transform.rotate(
          angle: _animation.value * 3.14159 / 180,
          alignment: Alignment.topCenter,
          child: child,
        );
      },
    );
  }
}

class PromoBanner extends StatelessWidget {
  const PromoBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.grey.shade100],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Local Business,",
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.w400,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 4),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: "Hyperlocal ",
                  style: GoogleFonts.inter(
                    fontSize: 28,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey.shade600,
                  ),
                ),
                TextSpan(
                  text: "Speed!",
                  style: GoogleFonts.inter(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xffE91E63), // Pink accent
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Made in",
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    "Tamilnadu",
                    style: GoogleFonts.notoSansArabic(
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xffE91E63), // bright pink
                    ),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: CustomAssetImageWidget(
                  Images.startup,
                  height: 100,
                  width: 220,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Widget notInYourAreaWidget() {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      gradient: const LinearGradient(
        colors: [Color(0xFFF8F8F8), Color(0xFFFFFFFF)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text("😢", style: TextStyle(fontSize: 60)),
        const SizedBox(height: 16),
        const Text(
          "Not in Your Area Yet",
          style: TextStyle(
            fontSize: 22,
            color: Color(0xFFE21E63),
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          "We're expanding fast.\n${AppConstants.appName} will reach you soon!",
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 15, color: Colors.black54, height: 1.4),
        ),
        const SizedBox(height: 35),
        const CustomAssetImageWidget(
          Images.logo,
          height: 100,
        ),
      ],
    ),
  );
}
