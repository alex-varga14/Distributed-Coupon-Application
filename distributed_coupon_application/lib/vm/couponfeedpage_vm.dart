import 'package:distributed_coupon_application/dal/coupon_dal.dart';
import 'package:distributed_coupon_application/dal/vendor_dal.dart';
import 'package:distributed_coupon_application/model/coupon.dart';
import 'package:distributed_coupon_application/model/RequestError.dart';
import 'package:distributed_coupon_application/model/vendor.dart';
import 'package:result_type/result_type.dart';

import '../util/pair.dart';

class CouponFeedPageVM {
  CouponDAL couponDAL = CouponDAL();
  VendorDAL vendorDAL = VendorDAL();

  Future<int> getCouponCount() async {
    return (await couponDAL.getAllCoupons()).success.length;
  }

  Future<List<Coupon>> getCoupons() async {
    return (await couponDAL.getAllCoupons()).success;
  }

  Future<List<Vendor>> getVendors() async {
    return (await vendorDAL.getAllVendors()).success;
  }

  Future<List<Pair<Coupon, Vendor>>> getData() async {
    Result<List<Coupon>, RequestError> couponsResult =
        await couponDAL.getAllCoupons();
    Result<List<Vendor>, RequestError> vendorsResult =
        await vendorDAL.getAllVendors();

    if (couponsResult.isFailure || vendorsResult.isFailure) {
      print("vm get fail");
      // TODO: handle error
      return Future.delayed(const Duration(seconds: 0), () => []);
    }

    List<Coupon> coupons = couponsResult.success;
    List<Vendor> vendors = vendorsResult.success;

    print("Coupons: $coupons");
    print("Vendors: $vendors");

    List<Pair<Coupon, Vendor>> data = coupons
        .map((c) => Pair(c, vendors.firstWhere((v) => c.vendorID == v.id)))
        .toList();
    print("Mapped: $data");

    // left join on coupons
    return data;
  }

  Future<List<Pair<Coupon, Vendor>>> getCouponsByVendorId(int id) async {
    Result<List<Coupon>, RequestError> couponsResult =
        await couponDAL.getAllCoupons();
    Result<List<Vendor>, RequestError> vendorsResult =
        await vendorDAL.getAllVendors();

    if (couponsResult.isFailure || vendorsResult.isFailure) {
      print("vm get fail");
      // TODO: handle error
      return Future.delayed(const Duration(seconds: 0), () => []);
    }

    List<Coupon> coupons =
        couponsResult.success.where((x) => x.vendorID == id).toList();
    Vendor vendor = vendorsResult.success.firstWhere((x) => x.id == id);

    print("Coupons: $coupons");
    print("Vendors: $vendor");

    List<Pair<Coupon, Vendor>> data =
        coupons.map((c) => Pair(c, vendor)).toList();
    print("Mapped: $data");

    // left join on coupons
    return data;
  }
}
