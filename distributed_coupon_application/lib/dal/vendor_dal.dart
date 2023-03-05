import 'package:distributed_coupon_application/api/vendor_api.dart';
import 'package:distributed_coupon_application/model/api_error.dart';
import 'package:distributed_coupon_application/model/coupon_error.dart';
import 'package:distributed_coupon_application/model/vendor.dart';
import 'package:result_type/result_type.dart';

class VendorDAL {
  VendorAPI api = VendorAPI();

  RequestError mapApiError(APIError error) {
    if (error is APIHTTPError) {
      if (error.code == 404) {
        return RequestError.DoesNotExist();
      }
      return RequestError.InvalidRequest();
    } else {
      print("Unhandled");
      return RequestError.InvalidRequest();
    }
  }

  Future<Result<Vendor, RequestError>> getVendor(int id) async {
    return (await api.getVendorById(id)).mapError(mapApiError);
  }

  Future<Result<List<Vendor>, RequestError>>getAllVendors() async {
    // return (await api.getVendors()).mapError(mapApiError);

    // mock data
    return Future.value(Success([
      Vendor.create(id: 1, country: "Canada", city: "Calgary", vendorName: "MountainSoapsCO"),
      Vendor.create(id: 2, country: "Canada", city: "Calgary", vendorName: "AmericanTire")
    ]));
  }

  Future<Result<List<Vendor>, RequestError>>getVendorsByCountry(String country) async {
    return (await api.getVendorsByCountry(country)).mapError(mapApiError);
  }

  Future<Result<List<Vendor>, RequestError>>getVendorsByCountryCity(String country, String city) async {
    return (await api.getVendorsByCountryCity(country, city)).mapError(mapApiError);
  }

}