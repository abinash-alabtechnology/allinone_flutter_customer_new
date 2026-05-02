import 'package:handy_allinone/features/coupon/domain/models/coupon_model.dart';

abstract class CouponServiceInterface{
  Future<List<CouponModel>?> getCouponList();
  Future<List<CouponModel>?> getTaxiCouponList();
  Future<CouponModel?> applyCoupon(String couponCode, int? storeID);
  Future<List<CouponModel>?> getCouponRestList(int? id);
  Future<CouponModel?> applyTaxiCoupon(String couponCode, int? providerId);
}