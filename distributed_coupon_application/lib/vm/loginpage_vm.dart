import 'dart:ffi';

import 'package:distributed_coupon_application/dal/coupon_dal.dart';
import 'package:distributed_coupon_application/dal/vendor_dal.dart';
import 'package:distributed_coupon_application/model/coupon.dart';
import 'package:distributed_coupon_application/model/RequestError.dart';
import 'package:distributed_coupon_application/model/vendor.dart';
import 'package:result_type/result_type.dart';

class LoginPageVM {
  Future<bool> checkForValidVendorId(int id) async {
    VendorDAL vendorDAL = new VendorDAL();

    Result<List<Vendor>, RequestError> vendorsResult =
        await vendorDAL.getAllVendors();

    if (vendorsResult.isFailure) {
      print("vm get fail");
      // TODO: handle error
      return false;
    }
    List<Vendor> vendors = vendorsResult.success;

    for (int i = 0; i < vendors.length; i++) {
      if (vendors[i].id == id) {
        print("login successful");
        return true;
      }
    }

    print("login failed");
    return false;
  }
}
