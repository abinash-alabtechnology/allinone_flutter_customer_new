import 'package:handy_allinone/common/widgets/web_page_title_widget.dart';
import 'package:handy_allinone/features/splash/controllers/splash_controller.dart';
import 'package:handy_allinone/features/favourite/controllers/favourite_controller.dart';
import 'package:handy_allinone/helper/auth_helper.dart';
import 'package:handy_allinone/helper/responsive_helper.dart';
import 'package:handy_allinone/util/dimensions.dart';
import 'package:handy_allinone/util/styles.dart';
import 'package:handy_allinone/common/widgets/custom_app_bar.dart';
import 'package:handy_allinone/common/widgets/menu_drawer.dart';
import 'package:handy_allinone/common/widgets/not_logged_in_screen.dart';
import 'package:handy_allinone/features/favourite/widgets/fav_item_view_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FavouriteScreen extends StatefulWidget {
  const FavouriteScreen({super.key});

  @override
  FavouriteScreenState createState() => FavouriteScreenState();
}

class FavouriteScreenState extends State<FavouriteScreen> with SingleTickerProviderStateMixin {
  TabController? _tabController;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, initialIndex: 0, vsync: this);

    initCall();
  }

  void initCall(){
    if(AuthHelper.isLoggedIn()) {
      Get.find<FavouriteController>().getFavouriteList();
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isPharmacy = Get.find<SplashController>().module != null && Get.find<SplashController>().module!.moduleType.toString() == 'pharmacy';
    return Scaffold(
      appBar: CustomAppBar3(title: isPharmacy ? 'Health Corner' : 'favourite'.tr, backButton: false),
      endDrawer: const MenuDrawer(),endDrawerEnableOpenDragGesture: false,
      body: AuthHelper.isLoggedIn() ? SafeArea(child: Column(children: [

        WebScreenTitleWidget(title: isPharmacy ? 'Health Corner' : 'favourite'.tr),

        SizedBox(
          width: Dimensions.webMaxWidth,
          child: Container(
            width: Dimensions.webMaxWidth,
            color: Theme.of(context).cardColor,
            alignment: Alignment.bottomLeft,
            child: TabBar(
              tabAlignment: ResponsiveHelper.isDesktop(context) ? TabAlignment.start : null,
              isScrollable: ResponsiveHelper.isDesktop(context) ? true : false,
              controller: _tabController,
              indicatorColor: Theme.of(context).primaryColor,
              indicatorWeight: 6,
              labelColor: Theme.of(context).textTheme.titleLarge?.color,
              unselectedLabelColor: Colors.grey,
              unselectedLabelStyle: robotoRegular.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeLarge),
              labelStyle: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).textTheme.titleLarge?.color),
              tabs: [
                Tab(text: 'item'.tr),
                Tab(text: Get.find<SplashController>().configModel!.moduleConfig!.module!.showRestaurantText!
                    ? 'restaurants'.tr : 'stores'.tr),
              ],
            ),
          ),
        ),

        Expanded(child:
        TabBarView(
          controller: _tabController,
          physics: const NeverScrollableScrollPhysics(),
          children: const [
            FavItemViewWidget(isStore: false),
            FavItemViewWidget(isStore: true),
          ],
        )),

      ])) : NotLoggedInScreen(callBack: (value){
        initCall();
        setState(() {});
      }),
    );
  }
}
