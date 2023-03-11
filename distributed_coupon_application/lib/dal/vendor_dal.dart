import 'package:distributed_coupon_application/api/vendor_api.dart';
import 'package:distributed_coupon_application/model/api_error.dart';
import 'package:distributed_coupon_application/model/RequestError.dart';
import 'package:distributed_coupon_application/model/vendor.dart';
import 'package:result_type/result_type.dart';

class VendorDAL {
  VendorAPI api = VendorAPI();

  RequestError mapApiError(APIError error) {
    if (error is APIHTTPError) {
      if (error.code == 404) {
        return RequestError.DoesNotExist();
      } else if (error.code == 501) {
        return RequestError.NotYetImplemented();
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

  Future<Result<List<Vendor>, RequestError>> getAllVendors() async {
    // mock data
    // return Future.value(Success([
    //   Vendor.create(id: 1, country: "Canada", city: "Calgary", vendorName: "MountainSoapsCO"),
    //   Vendor.create(id: 2, country: "Canada", city: "Calgary", vendorName: "AmericanTire")
    // ]));

    return (await api.getVendors()).mapError(mapApiError);
  }

  Future<Result<List<Vendor>, RequestError>> getVendorsByCountry(
      String country) async {
    return (await api.getVendorsByCountry(country)).mapError(mapApiError);
  }

  Future<Result<List<Vendor>, RequestError>> getVendorsByCountryCity(
      String country, String city) async {
    return (await api.getVendorsByCountryCity(country, city))
        .mapError(mapApiError);
  }

  Future<Result<bool, RequestError>> createVendor(Vendor vendor) async {
    //var result = await api.postVendor(vendor);
    //print(result);
    return (await api.postVendor(vendor)).mapError(mapApiError);
  }
}
