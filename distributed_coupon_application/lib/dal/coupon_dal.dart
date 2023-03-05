import 'package:distributed_coupon_application/api/coupon_api.dart';
import 'package:distributed_coupon_application/model/api_error.dart';
import 'package:distributed_coupon_application/model/coupon.dart';
import 'package:distributed_coupon_application/model/coupon_error.dart';
import 'package:result_type/result_type.dart';

// DAL layer so we can possibly return cached results instead of always performing API calls
class CouponDAL {
  CouponAPI api = CouponAPI();

  RequestError mapApiError(APIError error) {
    if (error is APIHTTPError) {
      return RequestError.InvalidRequest();
    } else {
      print("Unhandled");
      return RequestError.InvalidRequest();
    }
  }

  Future<Result<Coupon, RequestError>> getCoupon(int id) async {
    return (await api.getCoupon(id)).mapError(mapApiError);
  }

  Future<Result<List<Coupon>, RequestError>>getAllCoupons() async {
    // mock data
    return Future.value(Success([
      Coupon.create(id: 1, vendorID: 1, expiryDate: DateTime(2023, 12, 23), title: "50% off everything", description: "Customers can get 50% off everything storewide. Excludes clearance items.", isMultiuse: false),
      Coupon.create(id: 2, vendorID: 2, expiryDate: DateTime(2023, 11, 30), title: "Buy one get one free!", description: "Buy one item, get the next item free! The free item will be applied to one of the lesser value.", isMultiuse: false),
      Coupon.create(id: 3, vendorID: 2, expiryDate: DateTime(2023, 6, 5), title: "Spend \$25, get \$5", description: "Spending \$25 before tax, and get \$5 to redeem on your next purchase.", isMultiuse: false),
    ]));
    
    // return (await api.getAllCoupons()).mapError(mapApiError);
  }

}