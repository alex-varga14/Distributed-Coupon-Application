import 'package:distributed_coupon_application/dal/vendor_dal.dart';
import 'package:result_type/result_type.dart';

import '../model/RequestError.dart';
import '../model/vendor.dart';

class VendorRegisterPageVM {
  VendorDAL dal = VendorDAL();

  Future<Result<bool, String>> createVendor(Vendor vendor) async {
    Result<bool, RequestError> result = await dal.createVendor(vendor);

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
