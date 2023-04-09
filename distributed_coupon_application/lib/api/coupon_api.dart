import 'dart:ffi';

import 'package:distributed_coupon_application/model/api_error.dart';
import 'package:distributed_coupon_application/model/coupon.dart';
import 'package:distributed_coupon_application/service/http_service.dart';
import 'package:distributed_coupon_application/util/pair.dart';
import 'package:result_type/result_type.dart';

class CouponAPI extends HttpService {
  @override
  Future<String> baseUrl() async {
    String url1 = "https://mlpmkjtqxj.execute-api.us-west-2.amazonaws.com/dev/coupons/"; //main AWS Gateway
    String url2 = "https://0xz9o83x9e.execute-api.us-east-2.amazonaws.com/dev/coupons/"; //replica AWS Gateway

    //Assume at least 1 of the urls will be alive always
    var isUrl1Alive = await isUrlAlive(url1);

    return isUrl1Alive ? url1 : url2; 
  }
  
  @override
  T? deserialize<T>(dynamic data) {
    if (T == Coupon) {
      Map<String, dynamic> map = data.first as Map<String, dynamic>;

      Coupon c = Coupon();
      c.id = map["id"];
      c.vendorID = map["vendorID"];
      c.expiryDate = DateTime.parse(map["expiryDate"]);
      c.title = map["title"];
      c.description = map["description"];
      c.isMultiuse = (map["isMultiuse"] == 0) ? false : true;
      c.quantity = (map["quantity"]);

      return c as T;

    } else if (T == List<Coupon>) {
      // each element in the list is a Map<dyanmic, dynamic>
      return (data as List).map((map) {
        Coupon c = Coupon();
        c.id = map["id"];
        c.vendorID = map["vendorID"];
        c.expiryDate = DateTime.parse(map["expiryDate"]);
        c.title = map["title"];
        c.description = map["description"];
        c.isMultiuse = (map["isMultiuse"] == 0) ? false : true;
        c.quantity = (map["quantity"]);

        return c;
      }).toList(growable: false) as T;
    } else if (T == bool) {
      // at this point, it's assumed to be working (HTTP code = 2xx)
      return true as T;
    }

    return null;
  }

  Future<Result<Coupon, APIError>> getCoupon(int id) {
    return get<Coupon>("/", {"id": id});
  }

  Future<Result<List<Coupon>, APIError>> getAllCoupons([Pair<double, double>? pos]) {
    if (pos != null) {
      return get<List<Coupon>>("/?lat=${pos.first}&long=${pos.second}");
    }
    return get<List<Coupon>>("/");
  }

  Future<Result<List<Coupon>, APIError>> getCouponsCountry(String country) {
    return get<List<Coupon>>("/", {"country": country});
  }

  Future<Result<List<Coupon>, APIError>> getCouponsCountryCity(String country, String city) {
    return get<List<Coupon>>("/", {"country": country, "city": city});
  }

  Future<Result<bool, APIError>> postCoupon(Coupon coupon) {
    return postJson<bool>(
      "/",
      {
        "vendorID": coupon.vendorID,
        "expiryDate": coupon.expiryDate.toString(),
        "title": coupon.title,
        "description": coupon.description,
        "name": "what is the name?", // TODO
        "isMultiuse": coupon.isMultiuse,
        "quantity" : coupon.quantity
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