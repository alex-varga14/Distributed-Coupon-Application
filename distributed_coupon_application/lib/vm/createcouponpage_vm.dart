import 'package:distributed_coupon_application/dal/coupon_dal.dart';
import 'package:result_type/result_type.dart';

import '../model/coupon.dart';
import '../model/RequestError.dart';

class CreateCouponPageVM {
  CouponDAL dal = CouponDAL();

  Future<Result<bool, String>> createCoupon(Coupon coupon) async {
    if (coupon.quantity > 1) {
      coupon.isMultiuse = true;
    } else {
      coupon.isMultiuse = false;
    }

    Result<bool, RequestError> result = await dal.createCoupon(coupon);

    return result.mapError((error) {
      if (error is RequestErrorInvalidRequest) {
        return "Unable to send a request to the server. This is an internal error.";
      } else if (error is RequestErrorNotYetImplemented) {
        return "This has not yet been implemented on the server.";
      }
      return "Unknown error. Please inform the developers of the issue.";
    });
  }
}