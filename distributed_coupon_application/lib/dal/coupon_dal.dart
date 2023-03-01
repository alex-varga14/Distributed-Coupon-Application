import 'package:distributed_coupon_application/api/coupon_api.dart';
import 'package:distributed_coupon_application/model/api_error.dart';
import 'package:distributed_coupon_application/model/coupon.dart';
import 'package:distributed_coupon_application/model/coupon_error.dart';
import 'package:result_type/result_type.dart';

// DAL layer so we can possibly return cached results instead of always performing API calls
class CouponDAL {
  CouponAPI api = CouponAPI();

  CouponError mapApiError(APIError error) {
    if (error is APIHTTPError) {
      return CouponError.InvalidRequest();
    } else {
      print("Unhandled");
      return CouponError.InvalidRequest();
    }
  }

  Future<Result<Coupon, CouponError>> getCoupon(int id) async {
    return (await api.getCoupon(id)).mapError(mapApiError);
  }

  Future<Result<Coupon, CouponError>>getAllCoupons() async {
    return (await api.getAllCoupons()).mapError(mapApiError);
  }

}