import 'package:flutter/material.dart';
import 'package:handy_allinone/util/styles.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:handy_allinone/common/widgets/cart_widget.dart';
import 'package:handy_allinone/features/cart/controllers/cart_controller.dart';
import 'package:handy_allinone/features/handyman/services/controllers/handyman_home_controller.dart';
import 'package:handy_allinone/features/handyman/services/widgets/most_booked_services_widget.dart';
import 'package:handy_allinone/features/handyman/services/widgets/category_services_widget.dart';
import 'package:handy_allinone/features/location/controllers/location_controller.dart';
import 'package:handy_allinone/helper/address_helper.dart';
import 'dart:async';
import 'package:handy_allinone/helper/route_helper.dart';
import 'package:handy_allinone/util/images.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:handy_allinone/features/dashboard/screens/dashboard_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:handy_allinone/features/dashboard/widgets/bottom_nav_item_widget.dart';

class HandymanServicesScreen extends StatefulWidget {
  const HandymanServicesScreen({super.key});

  @override
  State<HandymanServicesScreen> createState() => _HandymanServicesScreenState();
}

class _HandymanServicesScreenState extends State<HandymanServicesScreen> {
  int _pageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      const HandymanHomeScreenBody(),
      HandymanWishlistScreen(onBackToHome: () => setState(() => _pageIndex = 0)),
      HandymanCartScreen(onBackToHome: () => setState(() => _pageIndex = 0)),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: IndexedStack(
        index: _pageIndex,
        children: screens,
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(left: 18.w, right: 18.w, bottom: 18.w),
        child: Card(
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Container(
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                BottomNavItemWidget(
                  title: 'Gograb',
                  selectedIcon: Images.logotransparent,
                  unSelectedIcon: Images.logotransparent,
                  isSelected: false,
                  activeColor: Theme.of(context).primaryColor,
                  onTap: () {
                    Get.offAll(() => const DashboardScreen(pageIndex: 0, fromSplash: false));
                  },
                ),
                BottomNavItemWidget(
                  title: 'Home',
                  selectedIcon: Images.homeSelect,
                  unSelectedIcon: Images.homeUnselect,
                  isSelected: _pageIndex == 0,
                  activeColor: Theme.of(context).primaryColor,
                  onTap: () {
                    setState(() {
                      _pageIndex = 0;
                    });
                  },
                ),
                BottomNavItemWidget(
                  title: 'Wishlist',
                  selectedIcon: Images.favouriteSelect,
                  unSelectedIcon: Images.favouriteUnselect,
                  isSelected: _pageIndex == 1,
                  activeColor: Theme.of(context).primaryColor,
                  onTap: () {
                    setState(() {
                      _pageIndex = 1;
                    });
                  },
                ),
                BottomNavItemWidget(
                  title: 'Booking',
                  selectedIcon: Images.orderSelect,
                  unSelectedIcon: Images.orderUnselect,
                  isSelected: _pageIndex == 2,
                  activeColor: Theme.of(context).primaryColor,
                  onTap: () {
                    setState(() {
                      _pageIndex = 2;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ----------------------------------------------------
// TAB 0: HOME SCREEN BODY (Original Categories List)
// ----------------------------------------------------
class HandymanHomeScreenBody extends StatefulWidget {
  const HandymanHomeScreenBody({super.key});

  @override
  State<HandymanHomeScreenBody> createState() => _HandymanHomeScreenBodyState();
}

class _HandymanHomeScreenBodyState extends State<HandymanHomeScreenBody> {
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;
  int _currentBannerIndex = 0;
  Timer? _bannerTimer;

  final List<Map<String, String>> _promoBanners = [
    {
      'title': '20% off on your\nfirst AC servicing',
      'subtitle': 'Up to \u20B9100 off',
      'image': 'assets/image/Ac_mechanic.png',
    },
    {
      'title': '20% off on your\nfirst Electrician service',
      'subtitle': 'Up to \u20B9100 off',
      'image': Images.handymanElectricianBanner,
    },
    {
      'title': '20% off on your\nfirst Painting service',
      'subtitle': 'Up to \u20B9100 off',
      'image': Images.handymanPainterBanner,
    },
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Register HandymanHomeController if not already registered
    if (!Get.isRegistered<HandymanHomeController>()) {
      Get.put(HandymanHomeController(), permanent: false);
    }
    _bannerTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        setState(() {
          _currentBannerIndex = (_currentBannerIndex + 1) % _promoBanners.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.offset > 50) {
      if (!_isScrolled) {
        setState(() {
          _isScrolled = true;
        });
      }
    } else {
      if (_isScrolled) {
        setState(() {
          _isScrolled = false;
        });
      }
    }
  }

  Widget _buildCartButton({required bool isScrolled}) {
    return InkWell(
      onTap: () => Get.toNamed(RouteHelper.getCartRoute()),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: isScrolled ? Border.all(color: Colors.grey.shade200, width: 1.5) : null,
          boxShadow: isScrolled
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Obx(() {
          final handymanController = Get.find<HandymanHomeController>();
          final int handymanQty = handymanController.totalCartItems;
          int normalQty = 0;
          if (Get.isRegistered<CartController>()) {
            normalQty = Get.find<CartController>().cartList.length;
          }
          final int totalQty = handymanQty + normalQty;
          
          return Stack(
            clipBehavior: Clip.none,
            children: [
              Image.asset(
                Images.shoppingCart,
                height: 24,
                width: 24,
                color: Colors.black87,
              ),
              if (totalQty > 0)
                Positioned(
                  top: -5,
                  right: -5,
                  child: Container(
                    height: 14,
                    width: 14,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).colorScheme.error,
                      border: Border.all(width: 1, color: Colors.white),
                    ),
                    child: Text(
                      totalQty.toString(),
                      style: robotoRegular.copyWith(
                        fontSize: 9,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildSearchBar({required bool isScrolled}) {
    return InkWell(
      onTap: () => Get.toNamed(RouteHelper.getSearchRoute()),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 46,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: isScrolled ? Border.all(color: Colors.grey.shade200, width: 1.5) : null,
          boxShadow: isScrolled
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          children: [
            const Icon(
              Icons.search,
              color: Colors.grey,
              size: 22,
            ),
            const Gap(10),
            Text(
              "Search for ",
              style: robotoRegular.copyWith(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            Expanded(
              child: AnimatedTextKit(
                repeatForever: true,
                pause: const Duration(milliseconds: 1000),
                animatedTexts: [
                  TypewriterAnimatedText(
                    "'AC service'",
                    speed: const Duration(milliseconds: 80),
                    cursor: '',
                    textStyle: GoogleFonts.robotoMono(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  TypewriterAnimatedText(
                    "'Painting'",
                    speed: const Duration(milliseconds: 80),
                    cursor: '',
                    textStyle: GoogleFonts.robotoMono(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  TypewriterAnimatedText(
                    "'Cleaning'",
                    speed: const Duration(milliseconds: 80),
                    cursor: '',
                    textStyle: GoogleFonts.robotoMono(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  TypewriterAnimatedText(
                    "'Salon & Spa'",
                    speed: const Duration(milliseconds: 80),
                    cursor: '',
                    textStyle: GoogleFonts.robotoMono(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  TypewriterAnimatedText(
                    "'Electrician'",
                    speed: const Duration(milliseconds: 80),
                    cursor: '',
                    textStyle: GoogleFonts.robotoMono(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  TypewriterAnimatedText(
                    "'InstaHelp'",
                    speed: const Duration(milliseconds: 80),
                    cursor: '',
                    textStyle: GoogleFonts.robotoMono(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double maxHeaderHeight = MediaQuery.of(context).padding.top + 240;
    final double minHeaderHeight = MediaQuery.of(context).padding.top + 70;

    final List<Map<String, dynamic>> handymanServices = [
      {
        'title': 'InstaHelp',
        'image': Images.handymanInstaHelp,
        'badge': null,
      },
      {
        'title': "Women's\nSalon & Spa",
        'image': Images.handymanWomenSalon,
        'badge': null,
      },
      {
        'title': "Men's Salon\n& Massage",
        'image': Images.handymanMenSalon,
        'badge': null,
      },
      {
        'title': 'Cleaning &\nPest Control',
        'image': Images.handymanCleaning,
        'badge': null,
      },
      {
        'title': 'Painting\n& Water - \nproofing',
        'image': Images.handymanPainting,
        'badge': null,
      },
      {
        'title': 'AC &\nAppliance\nRepair',
        'image': Images.handymanAcRepair,
        'badge': null,
      },
      {
        'title': 'Electrician,\nPlumber &\nCarpenter',
        'image': Images.handymanTools,
        'badge': null,
      },
      {
        'title': 'CCTV &\nSmart Home',
        'image': Images.handymanCctv,
        'badge': null,
      },

      {
        'title': 'Gardening &\nLawn Care',
        'image': Images.handymanGardening,
        'badge': null,
      },
      {
        'title': 'Home\nRenovation',
        'image': Images.handymanRenovation,
        'badge': null,
      },
      {
        'title': 'TV Mount\n& Setup',
        'image': Images.handymanTvmount,
        'badge': null,
      },
      {
        'title': 'Locksmith &\nKey Maker',
        'image': Images.handymanLocksmith,
        'badge': null,
      },
    ];

    return Stack(
      children: [
        // Main Service Scrollable Body
        Positioned.fill(
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: maxHeaderHeight),

                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Categories Title
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                        child: Text(
                          'Categories',
                          style: robotoRegular.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1F2937),
                          ),
                        ),
                      ),

                      // Horizontal 3-row grid
                      SizedBox(
                  height: 380,
                  child: GridView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: handymanServices.length,
                    physics: const BouncingScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      mainAxisExtent: 105,
                    ),
                    itemBuilder: (context, index) {
                      final service = handymanServices[index];
                      final String title = service['title'];
                      final String? imagePath = service['image'];
                      final String? badgeText = service['badge'];

                      return InkWell(
                        onTap: () {
                          Get.toNamed(
                            RouteHelper.getHandymanProcessRoute(),
                            arguments: {'serviceTitle': title.replaceAll('\n', ' ')},
                          );
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9FAFB),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFF3F4F6),
                              width: 1,
                            ),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Center(
                                      child: imagePath != null
                                          ? Image.asset(
                                              imagePath,
                                              height: 52,
                                              width: 52,
                                              fit: BoxFit.contain,
                                            )
                                          : const Icon(
                                              Icons.construction,
                                              size: 28,
                                              color: Colors.grey,
                                            ),
                                    ),
                                  ),
                                  const Gap(4),

                                  // Title Text
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                    child: Text(
                                      title,
                                      textAlign: TextAlign.center,
                                      maxLines: 3,
                                      style: robotoRegular.copyWith(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF374151),
                                        height: 1.2,
                                      ),
                                    ),
                                  ),
                                  const Gap(8),
                                ],
                              ),

                              if (badgeText != null)
                                Positioned(
                                  bottom: 22,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: const Color(0xFF16A34A),
                                        width: 0.8,
                                      ),
                                    ),
                                    child: Text(
                                      badgeText,
                                      style: robotoRegular.copyWith(
                                        fontSize: 7.5,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF16A34A),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

                const Gap(12),

                // Promotional Banner
                Container(
                  color: Colors.white,
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      Images.handymanPromoBanner,
                      width: double.infinity,
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                ),

                const Gap(12),
                // Most Booked Services Section
                const MostBookedServicesWidget(),

                const Gap(12),

                // Dynamic Category Services Sections
                Obx(() {
                  final controller = Get.find<HandymanHomeController>();
                  return Column(
                    children: controller.categorySections
                        .map((section) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: CategoryServicesWidget(section: section),
                            ))
                        .toList(),
                  );
                }),

                // Premium Promo / Information Banner
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0091FF), Color(0xFF0052D4)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0091FF).withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'SPECIAL OFFER',
                                style: robotoRegular.copyWith(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.verified_user_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ],
                        ),
                        const Gap(12),
                        Text(
                          'Up to 50% Off First Booking',
                          style: robotoRegular.copyWith(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const Gap(4),
                        Text(
                          'Get certified, expert handymen at your doorstep with transparent pricing.',
                          style: robotoRegular.copyWith(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const Gap(16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Promo Code',
                                  style: robotoRegular.copyWith(
                                    color: Colors.white70,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  'HANDY50',
                                  style: robotoRegular.copyWith(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ],
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Get.snackbar(
                                  'Promo Applied',
                                  'Code HANDY50 copied to clipboard!',
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: Colors.white,
                                  colorText: const Color(0xFF0091FF),
                                  duration: const Duration(seconds: 2),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFF0091FF),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                elevation: 0,
                              ),
                              child: Text(
                                'Apply Code',
                                style: robotoRegular.copyWith(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Highlights Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Why Choose Us?',
                        style: robotoRegular.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1F2937),
                        ),
                      ),
                      const Gap(12),
                      _buildHighlightRow(Icons.verified, '100% Verified Professionals', 'Background checked and highly skilled expert handymen.'),
                      const Gap(12),
                      _buildHighlightRow(Icons.attach_money, 'Transparent Pricing', 'No hidden costs. Pay only for the actual service hours.'),
                      const Gap(12),
                      _buildHighlightRow(Icons.security, 'Insurance Covered', 'Your home is safe. Any damage during service is fully insured.'),
                      const Gap(16),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Collapsing Header
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: _isScrolled ? minHeaderHeight : maxHeaderHeight,
            width: double.infinity,
            clipBehavior: Clip.hardEdge,
            padding: EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top + 8, 16, 0),
            decoration: BoxDecoration(
              color: _isScrolled ? Colors.white : const Color(0xFF0091FF),
              boxShadow: _isScrolled
                  ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : [],
            ),
            child: Stack(
              children: [
                // Expanded Header (Location row + Search bar)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: maxHeaderHeight - MediaQuery.of(context).padding.top - 8,
                  child: AnimatedOpacity(
                    opacity: _isScrolled ? 0.0 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    child: IgnorePointer(
                      ignoring: _isScrolled,
                    child: SizedBox(
                      height: maxHeaderHeight - MediaQuery.of(context).padding.top - 8,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                        // Top Row (Location & Cart)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.location_on,
                              color: Colors.white,
                              size: 28,
                            ),
                            const Gap(8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'In 48 minutes',
                                    style: robotoRegular.copyWith(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const Gap(2),
                                  InkWell(
                                    onTap: () => Get.find<LocationController>().navigateToLocationScreen('home'),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Flexible(
                                          child: GetBuilder<LocationController>(
                                            builder: (locationController) {
                                              final address = AddressHelper.getUserAddressFromSharedPref()?.address ?? 'Select Location';
                                              return Text(
                                                address,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: robotoRegular.copyWith(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.white.withOpacity(0.9),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                        const Icon(
                                          Icons.keyboard_arrow_down,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Gap(12),
                            _buildCartButton(isScrolled: false),
                          ],
                        ),
                        const Gap(10),

                        // Search Controller Row
                        _buildSearchBar(isScrolled: false),
                        const Gap(10),

                        // AC Mechanic Promo Banner
                        Expanded(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 800),
                            child: Row(
                              key: ValueKey(_currentBannerIndex),
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          _promoBanners[_currentBannerIndex]['title']!,
                                          style: robotoRegular.copyWith(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.white,
                                            height: 1.2,
                                          ),
                                        ),
                                        const Gap(4),
                                        Text(
                                          _promoBanners[_currentBannerIndex]['subtitle']!,
                                          style: robotoRegular.copyWith(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.white.withOpacity(0.85),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Image.asset(
                                  _promoBanners[_currentBannerIndex]['image']!,
                                  height: 105,
                                  fit: BoxFit.contain,
                                  alignment: Alignment.bottomCenter,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              ),
                // Collapsed Header (Search Bar & Cart button side-by-side)
                AnimatedOpacity(
                  opacity: _isScrolled ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: IgnorePointer(
                    ignoring: !_isScrolled,
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Expanded(child: _buildSearchBar(isScrolled: true)),
                            const Gap(12),
                            _buildCartButton(isScrolled: true),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHighlightRow(IconData icon, String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF0091FF).withOpacity(0.08),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: const Color(0xFF0091FF),
            size: 20,
          ),
        ),
        const Gap(12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: robotoRegular.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1F2937),
                ),
              ),
              const Gap(2),
              Text(
                subtitle,
                style: robotoRegular.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey.shade600,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ----------------------------------------------------
// TAB 1: WISHLIST SCREEN
// ----------------------------------------------------
class HandymanWishlistScreen extends StatefulWidget {
  final VoidCallback onBackToHome;
  const HandymanWishlistScreen({super.key, required this.onBackToHome});

  @override
  State<HandymanWishlistScreen> createState() => _HandymanWishlistScreenState();
}

class _HandymanWishlistScreenState extends State<HandymanWishlistScreen> {
  // Pre-populated mock wishlist items
  final List<Map<String, dynamic>> _wishlistItems = [
    {
      'title': 'AC & Appliance Repair',
      'image': Images.handymanAcRepair,
      'desc': 'Expert ac repair, gas refilling & cleaning services.',
    },
    {
      'title': 'Cleaning & Pest Control',
      'image': Images.handymanCleaning,
      'desc': 'Deep home cleaning, sanitation & pesticide spray.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0091FF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: widget.onBackToHome,
        ),
        title: Text(
          'My Wishlist',
          style: robotoRegular.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: _wishlistItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 80, color: Colors.grey.shade300),
                  const Gap(16),
                  Text(
                    'Your Wishlist is Empty',
                    style: robotoRegular.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const Gap(8),
                  Text(
                    'Bookmark your favorite services to book quickly.',
                    style: robotoRegular.copyWith(
                      fontSize: 13,
                      color: Colors.grey.shade400,
                    ),
                  ),
                  const Gap(24),
                  ElevatedButton(
                    onPressed: widget.onBackToHome,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0091FF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: Text(
                      'Explore Services',
                      style: robotoRegular.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _wishlistItems.length,
              itemBuilder: (context, index) {
                final item = _wishlistItems[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            color: const Color(0xFFF9FAFB),
                            padding: const EdgeInsets.all(8),
                            child: Image.asset(
                              item['image'],
                              height: 54,
                              width: 54,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        const Gap(12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['title'],
                                style: robotoRegular.copyWith(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF1F2937),
                                ),
                              ),
                              const Gap(4),
                              Text(
                                item['desc'],
                                style: robotoRegular.copyWith(
                                  fontSize: 11,
                                  color: Colors.grey.shade500,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const Gap(8),
                        Column(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.favorite, color: Colors.redAccent),
                              onPressed: () {
                                setState(() {
                                  _wishlistItems.removeAt(index);
                                });
                                Get.snackbar(
                                  'Removed',
                                  'Removed from Wishlist!',
                                  snackPosition: SnackPosition.BOTTOM,
                                  duration: const Duration(seconds: 1),
                                );
                              },
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Get.toNamed(
                                  RouteHelper.getHandymanProcessRoute(),
                                  arguments: {'serviceTitle': item['title']},
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0091FF),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                'Book',
                                style: robotoRegular.copyWith(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

// ----------------------------------------------------
// TAB 2: CART / BOOKINGS SCREEN
// ----------------------------------------------------
class HandymanCartScreen extends StatefulWidget {
  final VoidCallback onBackToHome;
  const HandymanCartScreen({super.key, required this.onBackToHome});

  @override
  State<HandymanCartScreen> createState() => _HandymanCartScreenState();
}

class _HandymanCartScreenState extends State<HandymanCartScreen> {
  // Pre-populated mock active booking
  bool _hasActiveBooking = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0091FF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: widget.onBackToHome,
        ),
        title: Text(
          'My Bookings',
          style: robotoRegular.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: !_hasActiveBooking
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.grey.shade300),
                  const Gap(16),
                  Text(
                    'No Active Bookings',
                    style: robotoRegular.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const Gap(8),
                  Text(
                    'Book expert services and track details here.',
                    style: robotoRegular.copyWith(
                      fontSize: 13,
                      color: Colors.grey.shade400,
                    ),
                  ),
                  const Gap(24),
                  ElevatedButton(
                    onPressed: widget.onBackToHome,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0091FF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: Text(
                      'Book a Service',
                      style: robotoRegular.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section Title
                  Text(
                    'Active Booking',
                    style: robotoRegular.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                  const Gap(12),

                  // Active Booking Detail Card
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  color: const Color(0xFF0091FF).withOpacity(0.08),
                                  padding: const EdgeInsets.all(10),
                                  child: Image.asset(
                                    Images.handymanAcRepair,
                                    height: 48,
                                    width: 48,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                              const Gap(12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: Colors.green.shade50,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        'CONFIRMED',
                                        style: robotoRegular.copyWith(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.green.shade700,
                                        ),
                                      ),
                                    ),
                                    const Gap(4),
                                    Text(
                                      'AC Filter Cleaning & Gas Refill',
                                      style: robotoRegular.copyWith(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF1F2937),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          
                          // Schedule details row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'SCHEDULED FOR',
                                    style: robotoRegular.copyWith(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold),
                                  ),
                                  const Gap(2),
                                  Text(
                                    'Tomorrow, 10:00 AM',
                                    style: robotoRegular.copyWith(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'ESTIMATED COST',
                                    style: robotoRegular.copyWith(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold),
                                  ),
                                  const Gap(2),
                                  Text(
                                    '\$50.00',
                                    style: robotoRegular.copyWith(fontSize: 14, fontWeight: FontWeight.w800, color: const Color(0xFF0091FF)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const Divider(height: 24),

                          // Actions
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                        title: Text('Cancel Booking', style: robotoRegular.copyWith(fontWeight: FontWeight.bold)),
                                        content: Text('Are you sure you want to cancel this handyman booking?', style: robotoRegular.copyWith(fontSize: 13)),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context),
                                            child: Text('Dismiss', style: robotoRegular.copyWith(color: Colors.grey)),
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                              setState(() {
                                                _hasActiveBooking = false;
                                              });
                                              Get.snackbar(
                                                'Cancelled',
                                                'Your booking has been cancelled successfully.',
                                                snackPosition: SnackPosition.BOTTOM,
                                                backgroundColor: Colors.white,
                                                colorText: Colors.red,
                                              );
                                            },
                                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                            child: Text('Cancel Booking', style: robotoRegular.copyWith(color: Colors.white)),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: Colors.redAccent),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                  ),
                                  child: Text(
                                    'Cancel',
                                    style: robotoRegular.copyWith(color: Colors.redAccent, fontSize: 13, fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ),
                              const Gap(12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    Get.snackbar(
                                      'Modify Schedule',
                                      'Rescheduling request sent to technician!',
                                      snackPosition: SnackPosition.BOTTOM,
                                      backgroundColor: const Color(0xFF0091FF),
                                      colorText: Colors.white,
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF0091FF),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    elevation: 0,
                                  ),
                                  child: Text(
                                    'Modify Time',
                                    style: robotoRegular.copyWith(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Gap(28),

                  // Trust indicators
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade100),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.shield_outlined, color: Colors.blueAccent, size: 28),
                        const Gap(12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Satisfaction Guarantee',
                                style: robotoRegular.copyWith(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.black87),
                              ),
                              const Gap(2),
                              Text(
                                'Certified handymen inspect and guarantee a clean job after task completion.',
                                style: robotoRegular.copyWith(fontSize: 10, color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
