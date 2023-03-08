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

  // GET Methods

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

  // Get Coupon List by VendorID
  Future<Result<List<Coupon>, RequestError>>getCouponsByVendorID(int vendorID) async {
    return (await api.getCouponsByVendorID(vendorID)).mapError(mapApiError);
  }

  // Get Coupon List by Expiry Date
  Future<Result<List<Coupon>, RequestError>>getCouponsByExpiryDate(DateTime expiryDate) async {
    return (await api.getCouponsByExpiryDate(expiryDate)).mapError(mapApiError);
  }

  // Get Coupon List by Title
  Future<Result<List<Coupon>, RequestError>>getCouponsByTitle(String title) async {
    return (await api.getCouponsByTitle(title)).mapError(mapApiError);
  }

  // Get Coupon List by Multi-Use availability
  Future<Result<List<Coupon>, RequestError>>getCouponsByMultiUse(bool isMultiuse) async {
    return (await api.getCouponsByMultiUse(isMultiuse)).mapError(mapApiError);
  }

  // Get Coupon List by VendorID and ExpiryDate
  Future<Result<List<Vendor>, RequestError>>getCouponsByVendorIDExpriryDate(int vendorID, DateTime expiryDate) async {
    return (await api.getCouponsByVendorIDExpriryDate(vendorID, expiryDate)).mapError(mapApiError);
  }

  // Get Coupon List by VendorID and Coupon Title
  Future<Result<List<Vendor>, RequestError>>getCouponsByVendorIDTitle(int vendorID, String title) async {
    return (await api.getCouponsByVendorIDTitle(vendorID, title)).mapError(mapApiError);
  }

  // Get Coupon List by VendorID and Multi-Use ability
  Future<Result<List<Vendor>, RequestError>>getCouponsByVendorIDMultiUse(int vendorID, bool isMultiuse) async {
    return (await api.getCouponsByVendorIDMultiUse(vendorID, isMultiuse)).mapError(mapApiError);
  }

  // Get Coupon List by Coupon Title and Multi-Use ability
  Future<Result<List<Vendor>, RequestError>>getCouponsByTitleMultiUse(String title, bool isMultiuse) async {
    return (await api.getCouponsByTitleMultiUse(title, isMultiuse)).mapError(mapApiError);
  }

  // Get Coupon List by VendorID, Coupon Title, and Multi Use
  Future<Result<List<Vendor>, RequestError>>getCouponsByVendorIDTitleMultiuse(int vendorID, String title, bool isMultiuse) async {
    return (await api.getCouponsByVendorIDTitleMultiuse(vendorID, title, isMultiuse)).mapError(mapApiError);
  }
 
  // POST methods --- IMCOMPLETE

  Future<Result<bool, RequestError>> createCoupon(Coupon coupon) async {
    var result = await api.postCoupon(coupon);
    print(result);
    return (await api.postCoupon(coupon)).mapError(mapApiError);
  }

}