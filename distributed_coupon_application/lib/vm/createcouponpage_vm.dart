import 'package:distributed_coupon_application/dal/coupon_dal.dart';
import 'package:result_type/result_type.dart';

import '../model/coupon.dart';
import '../model/coupon_error.dart';

class CreateCouponPageVM {
  CouponDAL dal = CouponDAL();

  Future<Result<bool, String>> createCoupon(Coupon coupon) async {
    Result<bool, RequestError> result = await dal.createCoupon(coupon);

    return result.mapError((error) {
      if (error is RequestErrorInvalidRequest) {
        return "Unable to send a request to the server. This is an internal error.";
      }

      return "Unknown error. Please inform the developers of the issue.";
    });
  }
}