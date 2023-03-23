import 'package:distributed_coupon_application/model/coupon.dart';
import 'package:distributed_coupon_application/model/vendor.dart';
import 'package:distributed_coupon_application/pages/CreateCouponPage.dart';
import 'package:distributed_coupon_application/ui/widgets/CouponWidget.dart';
import 'package:distributed_coupon_application/vm/couponfeedpage_vm.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../util/pair.dart';

class CouponFeedPage extends StatefulWidget {
  const CouponFeedPage({Key? key}) : super(key: key);

  @override
  State<CouponFeedPage> createState() => _CouponFeedPageState();
}

class _CouponFeedPageState extends State<CouponFeedPage> {
  CouponFeedPageVM vm = CouponFeedPageVM();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 234, 229, 229),
      appBar: AppBar(
        title: const Text('Welcome, savers!'),
        backgroundColor: const Color.fromARGB(255, 93, 175, 191),
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.sort,
              color: Colors.white,
            ),
            onPressed: () {
              //TODO
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
                return ListView(
                    padding: const EdgeInsets.all(12),
                    children: (snapshot.data ?? [])
                        .map((elem) => [
                              Row(children: [
                                const Icon(Icons.business,
                                    color: Colors.black, size: 20),
                                SizedBox(width: 10),
                                Text(
                                  elem.second.vendorName,
                                  style: GoogleFonts.roboto(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20),
                                ),
                              ]),
                              CouponWidget(
                                  coupon: elem.first,
                                  couponVendor: elem.second),
                              const SizedBox(height: 20)
                            ])
                        .expand((element) => element)
                        .toList());
              })),
    );
  }
}
