import 'package:distributed_coupon_application/dal/coupon_dal.dart';
import 'package:distributed_coupon_application/dal/vendor_dal.dart';
import 'package:distributed_coupon_application/model/api_error.dart';
import 'package:distributed_coupon_application/model/coupon.dart';
import 'package:distributed_coupon_application/model/RequestError.dart';
import 'package:result_type/result_type.dart';

import '../model/vendor.dart';
import '../util/pair.dart';

class QrCodeFoundPageVM {
  CouponDAL couponDAL = CouponDAL();
  VendorDAL vendorDAL = VendorDAL();

  Future<Pair<Coupon, Vendor>?> getCouponVendorPair(int couponId) async {
    Result<List<Coupon>, RequestError> couponsResult =
        await couponDAL.getAllCoupons();
    Result<List<Vendor>, RequestError> vendorsResult =
        await vendorDAL.getAllVendors();

    if (couponsResult.isFailure || vendorsResult.isFailure) {
      print("vm get fail");
      // TODO: handle error
      return null;
    }

    List<Coupon> coupons = couponsResult.success;
    List<Vendor> vendors = vendorsResult.success;

    Coupon? coupon;
    Vendor? vendor;

    var couponsListFiltered = coupons.where((e) => e.id == couponId);

    if (couponsListFiltered.isNotEmpty) {
      coupon = couponsListFiltered.first;
    } else {
      return null;
    }

    var vendorsListFiltered = vendors.where((e) => e.id == coupon?.vendorID);
    if (vendorsListFiltered.isNotEmpty) {
      vendor = vendorsListFiltered.first;
    } else {
      return null;
    }

    return Pair(coupon, vendor);
  }

  Future<bool> redeemCoupon(int couponId) async
  {
    Result<bool,RequestError> redeemCouponResult = await couponDAL.redeemCoupon(couponId);

    if (redeemCouponResult.isFailure) {
      print("vm redeem coupon fail");
      return false;
    }

    return redeemCouponResult.success;
  }

  Future<bool> releaseCoupon(int couponId) async
  {
    Result<bool,RequestError> releaseCouponResult = await couponDAL.releaseCoupon(couponId);

    if (releaseCouponResult.isFailure) {
      print("vm release coupon fail");
      return false;
    }

    return releaseCouponResult.success;
  }

}
