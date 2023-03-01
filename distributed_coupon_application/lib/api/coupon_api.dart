import 'dart:ffi';

import 'package:distributed_coupon_application/model/api_error.dart';
import 'package:distributed_coupon_application/model/coupon.dart';
import 'package:distributed_coupon_application/service/http_service.dart';
import 'package:result_type/result_type.dart';

class CouponAPI extends HttpService {
  @override
  String baseUrl() {
    return "https://0xz9o83x9e.execute-api.us-east-2.amazonaws.com/dev";
  }
  
  @override
  T? deserialize<T>(dynamic data) {
    if (T.runtimeType == Coupon) {
      Map<String, dynamic> map = data as Map<String, dynamic>;

      Coupon c = Coupon();
      c.id = map["id"];
      c.vendorID = map["vendorID"];
      c.expiryDate = DateTime.parse(map["expiryDate"]);
      c.title = map["title"];
      c.description = map["description"];
      c.isMultiuse = map["isMultiuse"];

      return c as T;

    } else if (T.runtimeType == List<Coupon>) {
      // each element in the list is a Map<dyanmic, dynamic>
      return (data as List).map((map) {
        Coupon c = Coupon();
        c.vendorID = map["vendorID"];
        c.expiryDate = DateTime.parse(map["expiryDate"]);
        c.title = map["title"];
        c.description = map["description"];
        c.isMultiuse = map["isMultiuse"];

        return c;
      }) as T;
    } else if (T.runtimeType == bool) {
      // at this point, it's assumed to be working (HTTP code = 2xx)
      return true as T;
    }

    return null;
  }

  Future<Result<Coupon, APIError>> getCoupon(int id) {
    return get<Coupon>("/coupons", {"id": id});
  }

  Future<Result<List<Coupon>, APIError>> getAllCoupons() {
    return get<List<Coupon>>("/coupons");
  }

  Future<Result<List<Coupon>, APIError>> getCouponsCountry(String country) {
    return get<List<Coupon>>("/coupons", {"country": country});
  }

  Future<Result<List<Coupon>, APIError>> getCouponsCountryCity(String country, String city) {
    return get<List<Coupon>>("/coupons", {"country": country, "city": city});
  }

  Future<Result<Bool, APIError>> postCoupon(Coupon coupon) {
    return post<Bool>(
      "/coupons",
      {
        "vendorID": coupon.vendorID,
        "expiryDate": coupon.expiryDate,
        "title": coupon.title,
        "description": coupon.description,
        "name": "what is the name?", // TODO
        "isMultiuse": coupon.isMultiuse
      }
      );
  }

  Future<Result<bool, APIError>> verifyCoupon(Coupon coupon) async {
    Result<Coupon, APIError> result = await getCoupon(coupon.id);
    return result.map((success) => true);
  }
  

  // Future<Result<bool, APIError>> deleteCoupon(Coupon coupon) {
    
  // }

  // bool redeemCoupon(Coupon coupon) {

  // }

}