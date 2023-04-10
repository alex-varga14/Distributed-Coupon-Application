import 'package:distributed_coupon_application/dal/coupon_dal.dart';
import 'package:distributed_coupon_application/dal/location_dal.dart';
import 'package:distributed_coupon_application/dal/vendor_dal.dart';
import 'package:distributed_coupon_application/model/coupon.dart';
import 'package:distributed_coupon_application/model/RequestError.dart';
import 'package:distributed_coupon_application/model/vendor.dart';
import 'package:geolocator/geolocator.dart';
import 'package:result_type/result_type.dart';

import '../util/pair.dart';

class CouponFeedPageVM {
  int activeMode = 0;
  List<int> rangeMode = [0, 1, 2, 3, 4, 5];
  List<String> rangeString = ['1 km', '5 km', '10 km', '25 km', '50 km', '100 km'];

  CouponDAL couponDAL = CouponDAL();
  VendorDAL vendorDAL = VendorDAL();
  LocationDAL locationDAL = LocationDAL();

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
    Position? pos = locationDAL.tryGetLocation();
    Pair<double, double>? posPair;
    if (pos != null) {
      posPair = Pair(pos.latitude, pos.longitude);
    }

    Result<List<Coupon>, RequestError> couponsResult = await couponDAL.getAllCoupons(posPair);
    Result<List<Vendor>, RequestError> vendorsResult = await vendorDAL.getAllVendors();

    if (couponsResult.isFailure || vendorsResult.isFailure) {
      print("vm get fail");
      // TODO: handle error
      return Future.delayed(const Duration(seconds: 0), () => []);
    }

    List<Coupon> coupons = couponsResult.success;
    List<Vendor> vendors = vendorsResult.success;

    print("Coupons: $coupons");
    print("Vendors: $vendors");

    List<Pair<Coupon, Vendor>> data = coupons.map((c) => Pair(c, vendors.firstWhere((v) => c.vendorID == v.id))).toList();
    print("Mapped: $data");

    // left join on coupons
    return data;
  }
}