import 'package:distributed_coupon_application/model/coupon.dart';
import 'package:distributed_coupon_application/model/vendor.dart';
import 'package:distributed_coupon_application/pages/SearchPage.dart';
import 'package:distributed_coupon_application/ui/widgets/CouponWidget.dart';
import 'package:distributed_coupon_application/vm/couponfeedpage_vm.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:collection/collection.dart';
import '../util/pair.dart';

class CouponFeedPage extends StatefulWidget {
  const CouponFeedPage({Key? key}) : super(key: key);

  @override
  State<CouponFeedPage> createState() => _CouponFeedPageState();
}

class _CouponFeedPageState extends State<CouponFeedPage> {
  CouponFeedPageVM vm = CouponFeedPageVM();
  List<Pair<Coupon, Vendor>>? couponsList;
  bool allowSearch = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 234, 229, 229),
      appBar: AppBar(
        title: const Text('Welcome, savers!'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.search,
              color: Colors.white,
            ),
            onPressed: () async {
              if (couponsList != null) {
                List<Pair<Coupon, Vendor>> coupons = List.empty(growable: true);
                for (var coupon in couponsList ?? []) {
                  coupons.add(coupon);
                }
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SearchPage(
                              coupons: coupons,
                            )));
              }
            },
          ),
        ],
      ),
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: FutureBuilder<List<Pair<Coupon, Vendor>>>(
          future: vm.getData(),
          builder: (BuildContext context,
              AsyncSnapshot<List<Pair<Coupon, Vendor>>> snapshot) {
            couponsList = snapshot.data;
            if (couponsList != null) {
              allowSearch = true;
              return ListView(
                  padding: const EdgeInsets.all(12),
                  children: (snapshot.data ?? [])
                      .map((elem) => [
                            Row(children: [
                              const Icon(Icons.business,
                                  color: Colors.black, size: 20),
                              const SizedBox(width: 10),
                              Text(
                                elem.second.vendorName,
                                style: GoogleFonts.roboto(
                                    fontWeight: FontWeight.bold, fontSize: 20),
                              ),
                            ]),
                            CouponWidget(
                                coupon: elem.first, couponVendor: elem.second),
                            const SizedBox(height: 20)
                          ])
                      .expand((element) => element)
                      .toList());
            } else {
              return const LoadingIndicator(
                indicatorType: Indicator.ballSpinFadeLoader,
              );
            }
          },
        ),
      ),
    );
  }
}
