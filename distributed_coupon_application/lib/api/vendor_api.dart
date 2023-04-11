import 'dart:ffi';

import 'package:distributed_coupon_application/model/api_error.dart';
import 'package:distributed_coupon_application/model/vendor.dart';
import 'package:distributed_coupon_application/service/http_service.dart';
import 'package:result_type/result_type.dart';

extension on Result<List<Vendor>, APIError> {
  Result<Vendor, APIError> tryFirst() {
    if (isSuccess) {
      if (success.isEmpty) {
        return Failure(APIError.HTTPError(404));
      }

      return Success(success.first);
    }

    return Failure(failure);
  }
}

class VendorAPI extends HttpService {
  @override
  Future<String> baseUrl() async{
    
    String url1 = "https://mlpmkjtqxj.execute-api.us-west-2.amazonaws.com/dev/vendors"; //main AWS Gateway
    String url2 = "https://0xz9o83x9e.execute-api.us-east-2.amazonaws.com/dev/vendors"; //replica AWS Gateway

    //Assume at least 1 of the urls will be alive always
    var isUrl1Alive = await isUrlAlive(url1);

    return isUrl1Alive ? url1 : url2;
  }
  
  @override
  T? deserialize<T>(dynamic data) {
    if (T == Vendor) {
      Map<String, dynamic> map = data as Map<String, dynamic>;

      Vendor v = Vendor();
      v.id = map["id"];
      v.country = map["country"];
      v.city = map["city"];
      v.vendorName = map["vendorName"];

      return v as T;

    } else if (T == List<Vendor>) {
      // each element in the list is a Map<dyanmic, dynamic>
      return (data as List).map((map) {
        Vendor v = Vendor();
        v.id = map["id"];
        v.country = map["country"];
        v.city = map["city"];
        v.vendorName = map["vendorName"];

        return v;
      }).toList(growable: false) as T;
    } else if (T == bool) {
      // at this point, it's assumed to be working (HTTP code = 2xx)
      return true as T;
    }

    return null;
  }

  Future<Result<List<Vendor>, APIError>> getVendors() {
    return get<List<Vendor>>("/");
  }

  Future<Result<Vendor, APIError>> getVendorById(int id) async {
    Result<List<Vendor>, APIError> result = await get<List<Vendor>>("/", {"id": id});

    return result.tryFirst();
  }

  Future<Result<List<Vendor>, APIError>> getVendorsByCountry(String country) {
    return get<List<Vendor>>("/", {"country": country});
  }

  Future<Result<List<Vendor>, APIError>> getVendorsByCountryCity(String country, String city) {
    return get<List<Vendor>>("/", {"country": country, "city": city});
  }

  Future<Result<List<Vendor>, APIError>> getVendorsByCountryCityName(String country, String city, String name) {
    return get<List<Vendor>>("/", {"country": country, "city": city, "name": name});
  }

  Future<Result<bool, APIError>> postVendor(Vendor vendor) {
    return postJson<bool>(
      "/",
      {
        "country": vendor.country,
        "city": vendor.city,
        "name": vendor.vendorName
      }
      );
  }
}