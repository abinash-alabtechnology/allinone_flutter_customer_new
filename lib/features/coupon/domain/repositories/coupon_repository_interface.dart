import 'package:handy_allinone/interfaces/repository_interface.dart';


abstract class CouponRepositoryInterface extends RepositoryInterface{
  @override
  @override
  Future getList(
      {int? offset,
        bool couponList = false,
        bool taxiCouponList = false,
        bool couponRestList = false,
        int? restid});
  Future<dynamic> applyCoupon(String couponCode, int? storeID);
  Future<dynamic> applyTaxiCoupon(String couponCode, int? providerId);

}