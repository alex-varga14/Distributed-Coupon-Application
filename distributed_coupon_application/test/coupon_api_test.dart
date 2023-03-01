// ignore_for_file: non_constant_identifier_names

import 'package:distributed_coupon_application/api/coupon_api.dart';
import 'package:distributed_coupon_application/model/api_error.dart';
import 'package:distributed_coupon_application/model/coupon.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:result_type/result_type.dart';

class CouponAPITest {
  CouponAPI api = CouponAPI();

  void main() async {
    test("Given a valid coupon id, when a coupon request is performed, then the coupon object is returned", () async {
      const couponId = 1;

      Result<Coupon, APIError> coupon = await api.getCoupon(couponId);

      expect(coupon.isSuccess, true);
      expect(coupon.success.runtimeType, Coupon);
    });

    test("Given an invalid coupon id, when a coupon request is performed, then a 404 is returned", () async {
      const couponId = -1;

      Result<Coupon, APIError> coupon = await api.getCoupon(couponId);

      expect(coupon.isFailure, true);
      expect((coupon.failure as APIHTTPError).code, 404);
    });

    test("Given an empty state, when an API to retrieve all coupons is performed, then the list is returned", () async {
      Result<List<Coupon>, APIError> coupons = await api.getAllCoupons();
      
      expect(coupons.isSuccess, true);
      expect(coupons.success.runtimeType, List<Coupon>);
    });

  }
}