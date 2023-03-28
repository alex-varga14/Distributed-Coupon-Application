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
  String query = "";
  List<Pair<Coupon, Vendor>> filteredCoupons = List.empty(growable: true);

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
          decoration: InputDecoration(
            hintText: "Type vendor name or coupon title...",
            //filled: true,
            //fillColor: Color.fromARGB(255, 241, 237, 237),
            //border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.close,
              color: Colors.white,
            ),
            onPressed: () {
              clearSearchBar();
            },
          ),
        ],
      ),
      resizeToAvoidBottomInset: false,
      body: SafeArea(
          child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: ListView.builder(
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
                  }))),
    );
  }

  void filterData(String query) async {
    setState(() {
      filteredCoupons =
          Filter.filterCouponByVendorNameAndTitle(query, widget.coupons);
    });
  }

  void clearSearchBar() {
    setState(() {
      query = "";
    });
  }
}
