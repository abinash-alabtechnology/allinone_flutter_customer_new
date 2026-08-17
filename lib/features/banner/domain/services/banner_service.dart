import 'package:handy_allinone/common/enums/data_source_enum.dart';
import 'package:handy_allinone/features/banner/domain/models/banner_model.dart';
import 'package:handy_allinone/features/banner/domain/models/others_banner_model.dart';
import 'package:handy_allinone/features/banner/domain/models/promotional_banner_model.dart';
import 'package:handy_allinone/features/banner/domain/repositories/banner_repository_interface.dart';
import 'package:handy_allinone/features/banner/domain/services/banner_service_interface.dart';
import 'package:handy_allinone/features/location/domain/models/zone_response_model.dart';
import 'package:handy_allinone/helper/address_helper.dart';

class BannerService implements BannerServiceInterface {
  final BannerRepositoryInterface bannerRepositoryInterface;
  BannerService({required this.bannerRepositoryInterface});

  @override
  Future<BannerModel?> getBannerList({required DataSourceEnum source}) async {
    return await bannerRepositoryInterface.getList(isBanner: true, source: source);
  }

  @override
  Future<BannerModel?> getTaxiBannerList() async {
    return await bannerRepositoryInterface.getList(isTaxiBanner: true);
  }

  @override
  Future<BannerModel?> getFeaturedBannerList({required DataSourceEnum source}) async {
    return await bannerRepositoryInterface.getList(isFeaturedBanner: true, source: source);
  }

  @override
  Future<ParcelOtherBannerModel?> getParcelOtherBannerList({required DataSourceEnum source}) async {
    return await bannerRepositoryInterface.getList(isParcelOtherBanner: true, source: source);
  }

  @override
  Future<PromotionalBanner?> getPromotionalBannerList() async {
    return await bannerRepositoryInterface.getList(isPromotionalBanner: true);
  }

  @override
  Future<BannerModel?> getSpotlightBannerList({required DataSourceEnum source}) async {
    return await bannerRepositoryInterface.getList(isSpotlightBanner: true, source: source);
  }

  @override
  List<int?> moduleIdList() {
    List<int?> moduleIdList = [];
    for (ZoneData zone in AddressHelper.getUserAddressFromSharedPref()!.zoneData!) {
      for (Modules module in zone.modules ?? []) {
        moduleIdList.add(module.id);
      }
    }
    return moduleIdList;
  }

}