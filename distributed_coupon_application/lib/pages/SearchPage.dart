import 'package:distributed_coupon_application/model/coupon.dart';
import 'package:distributed_coupon_application/model/vendor.dart';
import 'package:distributed_coupon_application/util/filter.dart';
import 'package:distributed_coupon_application/ui/widgets/CouponWidget.dart';
import 'package:distributed_coupon_application/vm/couponfeedpage_vm.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_indicator/loading_indicator.dart';

import '../util/pair.dart';

class SearchPage extends StatefulWidget {
  final List<Pair<Coupon, Vendor>> coupons;

  const SearchPage({Key? key, required this.coupons}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<Pair<Coupon, Vendor>> filteredCoupons = List.empty(growable: true);
  String query = "";
  var searchBarFieldText = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredCoupons = widget.coupons;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: TextField(
            onChanged: (value) => {query = value, filterData(query)},
            controller: searchBarFieldText,
            decoration: InputDecoration(
                hintText: "Type vendor name or coupon title...",
                hintStyle: TextStyle(fontSize: 18, color: Colors.white)),
          ),
          actions: <Widget>[
            IconButton(
              icon: const Icon(
                Icons.close,
                color: Colors.white,
              ),
              onPressed: () {
                clearSearchBar();
                Navigator.pop(context);
              },
            ),
          ],
          automaticallyImplyLeading: false,
        ),
        resizeToAvoidBottomInset: false,
        body: SafeArea(
            child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: filteredCoupons.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      Row(children: [
                        const Icon(Icons.business,
                            color: Colors.black, size: 20),
                        const SizedBox(width: 10),
                        Text(
                          filteredCoupons[index].second.vendorName,
                          style: GoogleFonts.roboto(
                              fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                      ]),
                      CouponWidget(
                          coupon: filteredCoupons[index].first,
                          couponVendor: filteredCoupons[index].second),
                      const SizedBox(height: 20)
                    ],
                  );
                })));
  }

  void filterData(String query) async {
    setState(() {
      filteredCoupons =
          Filter.filterCouponByVendorNameAndTitle(query, widget.coupons);
    });
  }

  void clearSearchBar() {
    searchBarFieldText.clear();
    setState(() {
      filteredCoupons = widget.coupons;
    });
  }
}
