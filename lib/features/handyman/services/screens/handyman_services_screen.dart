import 'package:flutter/material.dart';
import 'package:handy_allinone/util/styles.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:handy_allinone/features/cart/controllers/cart_controller.dart';
import 'package:handy_allinone/features/handyman/services/controllers/handyman_home_controller.dart';
import 'package:handy_allinone/features/handyman/services/models/handyman_service_model.dart';
import 'package:handy_allinone/features/handyman/services/widgets/most_booked_services_widget.dart';
import 'package:handy_allinone/features/handyman/services/widgets/category_services_widget.dart';
import 'package:handy_allinone/features/handyman/services/widgets/service_options_bottom_sheet.dart';
import 'package:handy_allinone/features/handyman/services/widgets/category_promo_banner.dart';
import 'package:handy_allinone/features/location/controllers/location_controller.dart';
import 'package:handy_allinone/helper/address_helper.dart';
import 'dart:async';
import 'package:handy_allinone/helper/route_helper.dart';
import 'package:handy_allinone/util/images.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:handy_allinone/features/dashboard/screens/dashboard_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:handy_allinone/features/dashboard/widgets/bottom_nav_item_widget.dart';
import 'package:handy_allinone/features/handyman/services/screens/handyman_bookings_screen.dart';
import 'package:handy_allinone/features/handyman/services/screens/handyman_checkout_screen.dart';
import 'package:handy_allinone/features/banner/controllers/banner_controller.dart';
import 'package:handy_allinone/features/favourite/controllers/favourite_controller.dart';
import 'package:handy_allinone/features/category/controllers/category_controller.dart';
import 'package:handy_allinone/common/widgets/custom_image.dart';
import 'package:shimmer/shimmer.dart';


class HandymanServicesScreen extends StatefulWidget {
  final int initialPageIndex;
  const HandymanServicesScreen({super.key, this.initialPageIndex = 0});

  @override
  State<HandymanServicesScreen> createState() => _HandymanServicesScreenState();
}

class _HandymanServicesScreenState extends State<HandymanServicesScreen> {
  int _pageIndex = 0;

  @override
  void initState() {
    super.initState();
    if (Get.arguments is Map && Get.arguments['tab'] != null) {
      _pageIndex = Get.arguments['tab'];
    } else if (Get.arguments is int) {
      _pageIndex = Get.arguments;
    } else {
      _pageIndex = widget.initialPageIndex;
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      HandymanHomeScreenBody(onCartTap: () {
        Get.to(() => HandymanCartScreen(onBackToHome: () => Get.back()));
      }),
      HandymanWishlistScreen(onBackToHome: () => setState(() => _pageIndex = 0)),
      const HandymanBookingsScreen(),
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
                  title: 'Main',
                  selectedIcon: '',
                  unSelectedIcon: '',
                  icon: Icons.arrow_back,
                  isSelected: false,
                  activeColor: Theme.of(context).primaryColor,
                  onTap: () {
                    Get.offAll(() => const DashboardScreen(pageIndex: 0, fromSplash: false));
                  },
                ),
                BottomNavItemWidget(
                  title: 'Handy',
                  selectedIcon: Images.logotransparent,
                  unSelectedIcon: Images.logotransparent,
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
                  title: 'Bookings',
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

class HandymanHomeScreenBody extends StatefulWidget {
  final VoidCallback? onCartTap;
  const HandymanHomeScreenBody({super.key, this.onCartTap});

  @override
  State<HandymanHomeScreenBody> createState() => _HandymanHomeScreenBodyState();
}

class _HandymanHomeScreenBodyState extends State<HandymanHomeScreenBody> {
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;
  double _scrollOffset = 0.0;
  int _currentBannerIndex = 0;
  Timer? _bannerTimer;
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Register HandymanHomeController if not already registered
    if (!Get.isRegistered<HandymanHomeController>()) {
      Get.put(HandymanHomeController(), permanent: false);
    }
    Get.find<BannerController>().getBannerList(true);
    Get.find<CategoryController>().getCategoryList(true);
    _bannerTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        final bannerController = Get.find<BannerController>();
        final bannerCount = bannerController.bannerList?.length ?? 0;
        if (bannerCount > 0) {
          setState(() {
            _currentBannerIndex = (_currentBannerIndex + 1) % bannerCount;
          });
        }
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
    if (!mounted) return;
    final double offset = _scrollController.offset;
    final double maxHeaderHeight = MediaQuery.of(context).padding.top + 240;
    final double minHeaderHeight = MediaQuery.of(context).padding.top + 70;
    final double threshold = maxHeaderHeight - minHeaderHeight;

    setState(() {
      _scrollOffset = offset;
      _isScrolled = offset > threshold;
    });
  }

  Widget _buildCartButton({required bool isScrolled}) {
    return InkWell(
      onTap: widget.onCartTap ?? () => Get.toNamed(RouteHelper.getCartRoute()),
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
    return GestureDetector(
      onTap: () => Get.toNamed(RouteHelper.getHandymanSearchRoute()),
      behavior: HitTestBehavior.opaque,
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
        child: IgnorePointer(
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
              child: GetBuilder<CategoryController>(
                builder: (categoryController) {
                  List<String> searchWords = [];
                  if (categoryController.categoryList != null && categoryController.categoryList!.isNotEmpty) {
                    searchWords = categoryController.categoryList!
                        .map((c) => (c.name != null && c.name!.trim().isNotEmpty) ? "'${c.name!.trim()}'" : "")
                        .where((name) => name.isNotEmpty)
                        .toList();
                  }

                  if (searchWords.isEmpty) {
                    return Text(
                      "services...",
                      style: GoogleFonts.robotoMono(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    );
                  }

                  return AnimatedTextKit(
                    key: ValueKey(searchWords.join(',')),
                    repeatForever: true,
                    pause: const Duration(milliseconds: 1000),
                    animatedTexts: searchWords.map((word) {
                      return TypewriterAnimatedText(
                        word,
                        speed: const Duration(milliseconds: 80),
                        cursor: '',
                        textStyle: GoogleFonts.robotoMono(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ),
  );
  }

  @override
  Widget build(BuildContext context) {
    final double maxHeaderHeight = MediaQuery.of(context).padding.top + 240;
    final double minHeaderHeight = MediaQuery.of(context).padding.top + 70;

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
                      // Dynamic API Categories Grid
                      GetBuilder<CategoryController>(
                        builder: (categoryController) {
                          if (categoryController.categoryList == null || categoryController.isLoadingCategories) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                                  child: Text(
                                    'categories'.tr,
                                    style: robotoRegular.copyWith(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF1F2937),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: GridView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: 8,
                                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 4,
                                      crossAxisSpacing: 10,
                                      mainAxisSpacing: 10,
                                      childAspectRatio: 0.85,
                                    ),
                                    itemBuilder: (context, index) {
                                      return Shimmer.fromColors(
                                        baseColor: Colors.grey[300]!,
                                        highlightColor: Colors.grey[100]!,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            );
                          }

                          if (categoryController.categoryList!.isEmpty) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                                  child: Text(
                                    'categories'.tr,
                                    style: robotoRegular.copyWith(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF1F2937),
                                    ),
                                  ),
                                ),
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(24.0),
                                    child: Text(
                                      'no_category_found'.tr,
                                      style: robotoRegular.copyWith(color: Theme.of(context).disabledColor),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }

                          final categories = categoryController.categoryList!;
                          final int displayCount = categories.length > 12 ? 12 : categories.length;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'categories'.tr,
                                      style: robotoRegular.copyWith(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF1F2937),
                                      ),
                                    ),
                                    if (categories.length > 12)
                                      InkWell(
                                        onTap: () => Get.toNamed(RouteHelper.getCategoryRoute()),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                          child: Text(
                                            'view_all'.tr,
                                            style: robotoMedium.copyWith(
                                              fontSize: 14,
                                              color: Theme.of(context).primaryColor,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  final double screenW = constraints.maxWidth;
                                  final int cols = screenW >= 800
                                      ? 8
                                      : screenW >= 520
                                          ? 6
                                          : 4;
                                  const double hPad = 16.0;
                                  const double spacing = 10.0;
                                  final double cellW = (screenW - hPad * 2 - spacing * (cols - 1)) / cols;
                                  final double cellH = cellW * 1.15;
                                  final double imgSz = (cellW * 0.46).clamp(28.0, 56.0);
                                  final double fs = (cellW * 0.10).clamp(8.5, 11.5);
                                  final double radius = (cellW * 0.10).clamp(8.0, 14.0);

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: hPad),
                                    child: GridView.builder(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemCount: displayCount,
                                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: cols,
                                        crossAxisSpacing: spacing,
                                        mainAxisSpacing: spacing,
                                        childAspectRatio: cellW / cellH,
                                      ),
                                  itemBuilder: (context, index) {
                                    final category = categories[index];
                                    final String title = category.name ?? '';
                                    final String? imageUrl = category.imageFullUrl;

                                    return InkWell(
                                      onTap: () {
                                        Get.toNamed(
                                          RouteHelper.getHandymanAvailableServicesRoute(),
                                          arguments: {
                                            'category': title,
                                            'categoryId': category.id,
                                          },
                                        );
                                      },
                                      borderRadius: BorderRadius.circular(radius),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF9FAFB),
                                          borderRadius: BorderRadius.circular(radius),
                                          border: Border.all(
                                            color: const Color(0xFFF3F4F6),
                                            width: 1,
                                          ),
                                        ),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            imageUrl != null && imageUrl.isNotEmpty
                                                ? CustomImage(
                                                    image: imageUrl,
                                                    height: imgSz,
                                                    width: imgSz,
                                                    fit: BoxFit.contain,
                                                  )
                                                : Icon(
                                                    Icons.construction,
                                                    size: imgSz * 0.6,
                                                    color: Colors.grey,
                                                  ),
                                            SizedBox(height: cellW * 0.05),
                                            Padding(
                                              padding: EdgeInsets.symmetric(horizontal: cellW * 0.06),
                                              child: Text(
                                                title,
                                                textAlign: TextAlign.center,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: robotoRegular.copyWith(
                                                  fontSize: fs,
                                                  fontWeight: FontWeight.w600,
                                                  color: const Color(0xFF374151),
                                                  height: 1.2,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),

                const Gap(12),

                // Promotional Banner
                // const BannerView(isFeatured: false),

                const Gap(12),
                // Most Booked Services Section
                const MostBookedServicesWidget(),

                const Gap(12),

                // Dynamic Category Services Sections (100% API Data)
                GetBuilder<CategoryController>(
                  builder: (categoryController) {
                    final widgets = <Widget>[];

                    if (categoryController.categoryList != null && categoryController.categoryList!.isNotEmpty) {
                      for (final category in categoryController.categoryList!) {
                        final catIdStr = category.id.toString();
                        final apiItems = categoryController.itemsByCategory[catIdStr];

                        if (apiItems == null && category.id != null) {
                          categoryController.fetchItemsForCategory(catIdStr, 1, 'all', false);
                        }

                        if (apiItems == null || apiItems.isEmpty) {
                          continue; // Strictly skip categories without API items
                        }

                        final categoryServices = apiItems.map((item) => HandymanServiceModel.fromItem(item)).toList();

                        final section = CategorySectionModel(
                          categoryId: category.id,
                          title: category.name ?? '',
                          subtitle: 'Professional services at your doorstep',
                          services: categoryServices,
                        );

                        widgets.add(Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: CategoryServicesWidget(section: section),
                        ));

                        // Add category-specific promo banners dynamically if category matches
                        final titleLower = (category.name ?? '').toLowerCase();
                        if (titleLower.contains('salon') || titleLower.contains('women')) {
                          widgets.add(CategoryPromoBanner(
                            tag: 'LUXURY SPA & SALON',
                            title: 'Up to 30% Off Home Salon',
                            subtitle: 'Threadings, Facials & Hair Services',
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF7E9D), Color(0xFF9B51E0)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            imageAsset: Images.handymanWomenSalonNoBg,
                            onTap: () {
                              Get.toNamed(
                                RouteHelper.getHandymanAvailableServicesRoute(),
                                arguments: {'category': category.name, 'categoryId': category.id},
                              );
                            },
                          ));
                          widgets.add(const Gap(12));
                        } else if (titleLower.contains('ac') || titleLower.contains('appliance')) {
                          widgets.add(CategoryPromoBanner(
                            tag: 'SUMMER SPECIALS',
                            title: 'Flat ₹150 Off AC Repairs',
                            subtitle: 'Certified expert repair & maintenance',
                            gradient: const LinearGradient(
                              colors: [Color(0xFF2193B0), Color(0xFF6DD5ED)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            imageAsset: Images.handymanAcMechanicNoBg,
                            onTap: () {
                              Get.toNamed(
                                RouteHelper.getHandymanAvailableServicesRoute(),
                                arguments: {'category': category.name, 'categoryId': category.id},
                              );
                            },
                          ));
                          widgets.add(const Gap(12));
                        }
                      }
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: widgets,
                    );
                  },
                ),

                // Premium Promo / Information Banner
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6C63FF), Color(0xFF4F46E5)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6C63FF).withOpacity(0.2),
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
                                  snackPosition: SnackPosition.TOP,
                                  backgroundColor: Colors.white,
                                   colorText: const Color(0xFF6C63FF),
                                  duration: const Duration(seconds: 2),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFF6C63FF),
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
          child: Container(
            height: (maxHeaderHeight - _scrollOffset).clamp(minHeaderHeight, maxHeaderHeight),
            width: double.infinity,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              clipBehavior: Clip.hardEdge,
              padding: EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top + 8, 16, 0),
              decoration: BoxDecoration(
                color: _isScrolled ? Colors.white : const Color(0xFF6C63FF),
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

                          // Dynamic API Promo Banner Header
                          Expanded(
                            child: GetBuilder<BannerController>(
                              builder: (bannerController) {
                                final banners = bannerController.bannerList;
                                if (banners == null || banners.isEmpty) {
                                  return const SizedBox.shrink();
                                }

                                final int safeIndex = _currentBannerIndex % banners.length;
                                final banner = banners[safeIndex];
                                final String title = banner.title ?? '';
                                final String? imageUrl = banner.imageFullUrl;

                                return AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 800),
                                  child: Row(
                                    key: ValueKey('api_banner_$safeIndex'),
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.only(bottom: 8),
                                          child: Text(
                                            title,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: robotoRegular.copyWith(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w800,
                                              color: Colors.white,
                                              height: 1.2,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const Gap(10),
                                      if (imageUrl != null && imageUrl.isNotEmpty)
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(10),
                                          child: CustomImage(
                                            image: imageUrl,
                                            height: 95,
                                            width: 130,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                    ],
                                  ),
                                );
                              },
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
            color: const Color(0xFF6C63FF).withOpacity(0.08),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: const Color(0xFF6C63FF),
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
  HandymanHomeController get _controller => Get.find<HandymanHomeController>();

  @override
  void initState() {
    super.initState();
    _onRefresh();
  }

  Future<void> _onRefresh() async {
    if (Get.isRegistered<FavouriteController>()) {
      await Get.find<FavouriteController>().getFavouriteList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF6C63FF),
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
      body: RefreshIndicator(
        color: const Color(0xFF6C63FF),
        onRefresh: _onRefresh,
        child: GetBuilder<FavouriteController>(
          builder: (favouriteController) {
            final List<HandymanServiceModel> wishlistedServices = _controller.wishlistedServices;

            return wishlistedServices.isEmpty
              ? SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.75,
                    alignment: Alignment.center,
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
                            backgroundColor: const Color(0xFF6C63FF),
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
                  ),
                )
              : LayoutBuilder(
                  builder: (context, constraints) {
                    final screenW = constraints.maxWidth;
                    final int cols = screenW >= 900
                        ? 4
                        : screenW >= 600
                            ? 3
                            : 2;
                    final double spacing = 16.0;
                    final double padding = 16.0;
                    final double cardW =
                        (screenW - padding * 2 - spacing * (cols - 1)) / cols;
                    final double imgH = cardW;
                    final double cardH = imgH + cardW * 0.84;

                    return GridView.builder(
                      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                      padding: EdgeInsets.all(padding),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: cols,
                        crossAxisSpacing: spacing,
                        mainAxisSpacing: spacing,
                        childAspectRatio: cardW / cardH,
                      ),
                      itemCount: wishlistedServices.length,
                      itemBuilder: (context, index) {
                        final service = wishlistedServices[index];
                        return _WishlistServiceCard(
                          service: service,
                          controller: _controller,
                          cardWidth: cardW,
                        );
                      },
                    );
                  },
                );
          },
        ),
      ),
    );
  }
}


// ─── Wishlist Service Card (same UI as _CategoryServiceCard) ──────────────────

class _WishlistServiceCard extends StatelessWidget {
  final HandymanServiceModel service;
  final HandymanHomeController controller;
  /// Actual card pixel width — computed by LayoutBuilder in the parent grid.
  final double cardWidth;

  const _WishlistServiceCard({
    required this.service,
    required this.controller,
    required this.cardWidth,
  });

  @override
  Widget build(BuildContext context) {
    final double imgH     = cardWidth;
    final double iconSize = (cardWidth * 0.065).clamp(11.0, 16.0);
    final double nameFs   = (cardWidth * 0.10).clamp(11.0, 15.0);
    final double ratingFs = (cardWidth * 0.085).clamp(9.0, 12.0);
    final double labelFs  = (cardWidth * 0.075).clamp(9.0, 11.0);
    final double priceFs  = (cardWidth * 0.11).clamp(12.0, 16.0);
    final double btnW     = (cardWidth * 0.50).clamp(56.0, 80.0);
    final double btnH     = (cardWidth * 0.24).clamp(28.0, 36.0);
    final double heartSz  = (cardWidth * 0.12).clamp(22.0, 30.0);
    final double heartIco = (cardWidth * 0.065).clamp(12.0, 18.0);
    final double radius   = (cardWidth * 0.08).clamp(8.0, 14.0);
    final double gap1     = (cardWidth * 0.07).clamp(6.0, 12.0);
    final double gap2     = (cardWidth * 0.07).clamp(6.0, 12.0);
    final double starSz   = (cardWidth * 0.065).clamp(10.0, 15.0);

    return GestureDetector(
      onTap: () {
        ServiceOptionsBottomSheet.show(context, service);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Image with heart overlay ─────────────────────────────────
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(radius),
                child: service.imageUrl != null && service.imageUrl!.isNotEmpty
                    ? CustomImage(
                        image: service.imageUrl!,
                        width: double.infinity,
                        height: imgH,
                        fit: BoxFit.cover,
                      )
                    : Image.asset(
                        service.imageAsset,
                        width: double.infinity,
                        height: imgH,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: double.infinity,
                          height: imgH,
                          color: const Color(0xFFEFF6FF),
                          child: Icon(
                            Icons.build_rounded,
                            color: const Color(0xFF6C63FF),
                            size: imgH * 0.28,
                          ),
                        ),
                      ),
              ),
              // Favourite heart icon
              Positioned(
                top: 6,
                right: 6,
                child: Obx(() {
                  controller.allServices.length;
                  final wishlisted = controller.isServiceWishlisted(service.id);
                  return GestureDetector(
                    onTap: () => controller.toggleWishlist(service.id),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Container(
                        key: ValueKey(wishlisted),
                        width: heartSz,
                        height: heartSz,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.92),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.12),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          wishlisted
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color: wishlisted
                              ? const Color(0xFFEF4444)
                              : const Color(0xFF9CA3AF),
                          size: heartIco,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
          SizedBox(height: gap1),
          // ── Service Name ─────────────────────────────────────────────
          Text(
            service.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: robotoRegular.copyWith(
              fontSize: nameFs,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1F2937),
            ),
          ),
          SizedBox(height: gap2 * 0.4),
          // ── Rating ───────────────────────────────────────────────────
          Row(
            children: [
              Icon(Icons.star, color: const Color(0xFFFFC107), size: starSz),
              SizedBox(width: gap2 * 0.35),
              Flexible(
                child: Text(
                  '${service.rating} (${service.reviewCount})',
                  overflow: TextOverflow.ellipsis,
                  style: robotoRegular.copyWith(
                    fontSize: ratingFs,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: gap2),
          // ── Price & Add Button ────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Starts at',
                      style: robotoRegular.copyWith(
                        fontSize: labelFs,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF9CA3AF),
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      '₹${service.startingPrice}',
                      overflow: TextOverflow.ellipsis,
                      style: robotoRegular.copyWith(
                        fontSize: priceFs,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF111827),
                      ),
                    ),
                  ],
                ),
              ),
              Obx(() {
                int qty = controller.mostBookedServices
                        .firstWhereOrNull((s) => s.id == service.id)
                        ?.cartQuantity ??
                    0;
                if (qty == 0) {
                  for (final sec in controller.categorySections) {
                    final match = sec.services
                        .firstWhereOrNull((s) => s.id == service.id);
                    if (match != null) {
                      qty = match.cartQuantity;
                      break;
                    }
                  }
                }
                return qty == 0
                    ? _WishlistAddButton(
                        optionsCount: service.optionsCount,
                        btnWidth: btnW,
                        btnHeight: btnH,
                        labelFs: iconSize,
                        optionFs: ratingFs * 0.82,
                        onTap: () {
                          if (service.optionsCount == 0) {
                            controller.addToCart(service.id);
                            Get.snackbar(
                              'Added',
                              '${service.name} added to cart',
                              snackPosition: SnackPosition.TOP,
                              backgroundColor: Colors.black87,
                              colorText: Colors.white,
                              margin: const EdgeInsets.all(16),
                              duration: const Duration(seconds: 2),
                            );
                          } else {
                            Get.bottomSheet(
                              ServiceOptionsBottomSheet(
                                service: service,
                                onOptionAdd: (optionId) {
                                  controller.addToCart(service.id);
                                },
                              ),
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                            );
                          }
                        },
                      )
                    : _WishlistQuantityButton(
                        quantity: qty,
                        btnWidth: btnW,
                        btnHeight: btnH,
                        countFs: ratingFs,
                        onAdd: () => controller.addToCart(service.id),
                        onRemove: () => controller.removeFromCart(service.id),
                      );
              }),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Add Button (Wishlist) ────────────────────────────────────────────────────

class _WishlistAddButton extends StatelessWidget {
  final int optionsCount;
  final VoidCallback onTap;
  final double btnWidth;
  final double btnHeight;
  final double labelFs;
  final double optionFs;

  const _WishlistAddButton({
    required this.optionsCount,
    required this.onTap,
    required this.btnWidth,
    required this.btnHeight,
    required this.labelFs,
    required this.optionFs,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            width: btnWidth,
            height: btnHeight,
            margin: EdgeInsets.only(bottom: optionsCount > 0 ? 7 : 0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              'Add',
              style: robotoRegular.copyWith(
                fontSize: (labelFs * 1.3).clamp(11.0, 15.0),
                fontWeight: FontWeight.w700,
                color: const Color(0xFF6C63FF),
              ),
            ),
          ),
          if (optionsCount > 0)
            Positioned(
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                color: Colors.white,
                child: Text(
                  '$optionsCount options',
                  style: robotoRegular.copyWith(
                    fontSize: optionFs.clamp(8.0, 10.5),
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF9CA3AF),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Quantity Stepper (Wishlist) ──────────────────────────────────────────────

class _WishlistQuantityButton extends StatelessWidget {
  final int quantity;
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  final double btnWidth;
  final double btnHeight;
  final double countFs;

  const _WishlistQuantityButton({
    required this.quantity,
    required this.onAdd,
    required this.onRemove,
    required this.btnWidth,
    required this.btnHeight,
    required this.countFs,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: btnWidth,
      height: btnHeight,
      decoration: BoxDecoration(
        color: const Color(0xFF6C63FF),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          GestureDetector(
            onTap: onRemove,
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              width: btnWidth * 0.33,
              height: btnHeight,
              child: Icon(Icons.remove_rounded,
                  color: Colors.white, size: countFs.clamp(12.0, 17.0)),
            ),
          ),
          Text(
            '$quantity',
            style: robotoRegular.copyWith(
              fontSize: countFs.clamp(11.0, 14.0),
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          GestureDetector(
            onTap: onAdd,
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              width: btnWidth * 0.33,
              height: btnHeight,
              child: Icon(Icons.add_rounded,
                  color: Colors.white, size: countFs.clamp(12.0, 17.0)),
            ),
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------
// TAB 2: CART SCREEN
// ----------------------------------------------------

class HandymanCartScreen extends StatefulWidget {
  final VoidCallback onBackToHome;
  const HandymanCartScreen({super.key, required this.onBackToHome});

  @override
  State<HandymanCartScreen> createState() => _HandymanCartScreenState();
}

class _HandymanCartScreenState extends State<HandymanCartScreen> {
  HandymanHomeController get _controller =>
      Get.find<HandymanHomeController>();

  @override
  void initState() {
    super.initState();
    if (Get.isRegistered<CartController>()) {
      Get.find<CartController>().getCartDataOnline().then((_) {
        _controller.syncWithCartController();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6C63FF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: widget.onBackToHome,
        ),
        title: Text(
          'My Cart',
          style: robotoRegular.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          Obx(() {
            final count = _controller.cartServices.length;
            if (count == 0) return const SizedBox.shrink();
            return TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    title: Text('Clear Cart',
                        style: robotoRegular.copyWith(
                            fontWeight: FontWeight.bold)),
                    content: Text(
                        'Remove all $count service(s) from the cart?',
                        style: robotoRegular.copyWith(fontSize: 13)),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('Cancel',
                              style:
                                  robotoRegular.copyWith(color: Colors.grey))),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _controller.clearCart();
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent),
                        child: Text('Clear',
                            style:
                                robotoRegular.copyWith(color: Colors.white)),
                      ),
                    ],
                  ),
                );
              },
              child: Text(
                'Clear all',
                style: robotoRegular.copyWith(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }),
        ],
      ),
      body: GetBuilder<CartController>(builder: (cartController) {
        _controller.syncWithCartController(notify: false);
        final cartItems = _controller.cartServices;

        if (cartController.isLoading && cartItems.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF6C63FF)),
          );
        }

        if (cartItems.isEmpty) {
          return RefreshIndicator(
            onRefresh: () async {
              await cartController.getCartDataOnline();
              _controller.syncWithCartController();
            },
            color: const Color(0xFF6C63FF),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.7,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_cart_outlined,
                          size: 90, color: Colors.grey.shade300),
                      const Gap(16),
                      Text(
                        'Your Cart is Empty',
                        style: robotoRegular.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const Gap(8),
                      Text(
                        'Add services to get expert help at your doorstep.',
                        textAlign: TextAlign.center,
                        style: robotoRegular.copyWith(
                          fontSize: 13,
                          color: Colors.grey.shade400,
                        ),
                      ),
                      const Gap(28),
                      ElevatedButton.icon(
                        onPressed: widget.onBackToHome,
                        icon: const Icon(Icons.explore_outlined,
                            size: 18, color: Colors.white),
                        label: Text(
                          'Explore Services',
                          style: robotoRegular.copyWith(
                              fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6C63FF),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 28, vertical: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await cartController.getCartDataOnline();
            _controller.syncWithCartController();
          },
          color: const Color(0xFF6C63FF),
          child: Column(
            children: [
              // ── Cart item list ──────────────────────────────────────────
              Expanded(
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  itemCount: cartItems.length,
                  separatorBuilder: (_, __) => const Gap(12),
                  itemBuilder: (context, index) {
                  final service = cartItems[index];
                  return _CartItemCard(
                    service: service,
                    controller: _controller,
                  );
                },
              ),
            ),

            // ── Order Summary Footer ────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order Summary',
                    style: robotoRegular.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                  const Gap(12),
                  ...cartItems.map((s) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                '${s.name} × ${s.cartQuantity}',
                                overflow: TextOverflow.ellipsis,
                                style: robotoRegular.copyWith(
                                  fontSize: 12,
                                  color: const Color(0xFF6B7280),
                                ),
                              ),
                            ),
                            Text(
                              '₹${s.startingPrice * s.cartQuantity}',
                              style: robotoRegular.copyWith(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF1F2937),
                              ),
                            ),
                          ],
                        ),
                      )),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total',
                        style: robotoRegular.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1F2937),
                        ),
                      ),
                      Text(
                        '₹${_controller.cartTotalPrice}',
                        style: robotoRegular.copyWith(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF6C63FF),
                        ),
                      ),
                    ],
                  ),
                  const Gap(16),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        Get.to(() => const HandymanCheckoutScreen());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C63FF),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      child: Text(
                        'Proceed to Checkout',
                        style: robotoRegular.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }),
  );
}
}

// ─── Single Cart Item Card ────────────────────────────────────────────────────

class _CartItemCard extends StatelessWidget {
  final HandymanServiceModel service;
  final HandymanHomeController controller;

  const _CartItemCard({required this.service, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Service image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 70,
              height: 70,
              child: (service.imageUrl != null && service.imageUrl!.isNotEmpty)
                  ? CustomImage(
                      image: service.imageUrl!,
                      fit: BoxFit.cover,
                      width: 70,
                      height: 70,
                    )
                  : (service.imageAsset.isNotEmpty && !service.imageAsset.startsWith('http'))
                      ? Image.asset(
                          service.imageAsset,
                          fit: BoxFit.cover,
                          width: 70,
                          height: 70,
                          errorBuilder: (_, __, ___) => Container(
                            width: 70,
                            height: 70,
                            color: const Color(0xFFEFF6FF),
                            child: const Icon(Icons.build_rounded,
                                color: Color(0xFF6C63FF), size: 28),
                          ),
                        )
                      : Container(
                          width: 70,
                          height: 70,
                          color: const Color(0xFFEFF6FF),
                          child: const Icon(Icons.build_rounded,
                              color: Color(0xFF6C63FF), size: 28),
                        ),
            ),
          ),
          const Gap(14),

          // Name + category + price
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.name,
                  style: robotoRegular.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                const Gap(3),
                Text(
                  service.category,
                  style: robotoRegular.copyWith(
                    fontSize: 11,
                    color: const Color(0xFF6B7280),
                  ),
                ),
                const Gap(6),
                // Per-unit price + row total
                Row(
                  children: [
                    Text(
                      '₹${service.startingPrice}',
                      style: robotoRegular.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF374151),
                      ),
                    ),
                    if (service.cartQuantity > 1) ...[
                      Text(
                        ' × ${service.cartQuantity} = ',
                        style: robotoRegular.copyWith(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        '₹${service.startingPrice * service.cartQuantity}',
                        style: robotoRegular.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF6C63FF),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Quantity stepper
          Obx(() {
            final qty = controller
                    .mostBookedServices
                    .firstWhereOrNull((s) => s.id == service.id)
                    ?.cartQuantity ??
                (() {
                  for (final sec in controller.categorySections) {
                    final m = sec.services
                        .firstWhereOrNull((s) => s.id == service.id);
                    if (m != null) return m.cartQuantity;
                  }
                  return service.cartQuantity;
                })();

            return Container(
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFF6C63FF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () => controller.removeFromCart(service.id),
                    behavior: HitTestBehavior.opaque,
                    child: const SizedBox(
                      width: 34,
                      height: 36,
                      child: Icon(Icons.remove_rounded,
                          color: Colors.white, size: 16),
                    ),
                  ),
                  Text(
                    '$qty',
                    style: robotoRegular.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => controller.addToCart(service.id),
                    behavior: HitTestBehavior.opaque,
                    child: const SizedBox(
                      width: 34,
                      height: 36,
                      child: Icon(Icons.add_rounded,
                          color: Colors.white, size: 16),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

