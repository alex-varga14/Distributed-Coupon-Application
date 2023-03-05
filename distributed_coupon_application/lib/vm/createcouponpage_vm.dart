import 'package:distributed_coupon_application/dal/coupon_dal.dart';
import 'package:result_type/result_type.dart';

import '../model/coupon.dart';
import '../model/coupon_error.dart';

class CreateCouponPageVM {
  CouponDAL dal = CouponDAL();

  Future<bool> createCoupon(Coupon coupon) async {
    Result<bool, RequestError> result = await dal.createCoupon(coupon);

    if (result.isSuccess) {
      return result.success;
    }

    // TODO: handle error
    return false;
  }
}