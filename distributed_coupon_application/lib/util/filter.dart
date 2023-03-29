import 'pair.dart';
import 'package:distributed_coupon_application/model/coupon.dart';
import 'package:distributed_coupon_application/model/vendor.dart';
import '../util/pair.dart';

class Filter {
  static List<Pair<Coupon, Vendor>> filterCouponByVendorNameAndTitle(
      String query, List<Pair<Coupon, Vendor>> data) {
    List<Pair<Coupon, Vendor>> filterResult = List.empty(growable: true);

    query = query.toLowerCase();
    for (var item in data) {
      if (item.second.vendorName.toLowerCase().contains(query) ||
          item.first.title.toLowerCase().contains(query)) {
        filterResult.add(item);
      }
    }
    return filterResult;
  }
}
