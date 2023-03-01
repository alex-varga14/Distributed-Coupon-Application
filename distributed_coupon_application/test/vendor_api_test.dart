// ignore_for_file: non_constant_identifier_names

import 'package:distributed_coupon_application/api/vendor_api.dart';
import 'package:distributed_coupon_application/model/vendor.dart';
import 'package:test/test.dart';
import 'package:distributed_coupon_application/model/api_error.dart';
import 'package:distributed_coupon_application/model/coupon.dart';
import 'package:result_type/result_type.dart';

VendorAPI api = VendorAPI();

void main() async {
  // test("Given a valid coupon id, when a coupon request is performed, then the coupon object is returned", () async {
  //   const couponId = 1;

  //   Result<Coupon, APIError> coupon = await api.getCoupon(couponId);

  //   expect(coupon.isSuccess, true);
  //   expect(coupon.success.runtimeType, Coupon);
  // });

  // test("Given an invalid coupon id, when a coupon request is performed, then a 404 is returned", () async {
  //   const couponId = -1;

  //   Result<Coupon, APIError> coupon = await api.getCoupon(couponId);

  //   expect(coupon.isFailure, true);
  //   expect((coupon.failure as APIHTTPError).code, 404);
  // });

  test("Given an empty state, when an API call to list vendors is performed, then the list is returned", () async {
    Result<List<Vendor>, APIError> vendors = await api.getVendors();
    
    expect(vendors.isSuccess, true);
    expect(vendors.success.runtimeType, List<Vendor>);
  });

  test("Given a valid vendor ID, when an API call to retrieve the vendor is performed, then the list is returned", () async {
    Result<Vendor, APIError> vendors = await api.getVendorById(1);
    
    expect(vendors.isSuccess, true);
    var v = vendors.success;

    expect(v.id, 1);
    expect(v.country, "Canada");
    expect(v.city, "Red Deer");
    expect(v.vendorName, "SunshineRecords");
  });

  test("Given an invalid vendor ID, when an API call to retrieve the vendor is performed, then a 404 is returned", () async {
    Result<Vendor, APIError> vendors = await api.getVendorById(-1);
    
    expect(vendors.isSuccess, false);
  });

}