import 'package:distributed_coupon_application/model/coupon.dart';
import 'package:distributed_coupon_application/model/vendor.dart';
import 'package:distributed_coupon_application/pages/CreateCouponPage.dart';
import 'package:distributed_coupon_application/ui/widgets/CouponWidget.dart';
import 'package:distributed_coupon_application/vm/couponfeedpage_vm.dart';
import 'package:flutter/material.dart';

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
      appBar: AppBar(
        title: const Text('Welcome, savers!'),
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
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const CreateCouponPage()));
            },
          ),
        ],
      ),
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: SafeArea(
        child: FutureBuilder<List<Pair<Coupon, Vendor>>>(
          future: vm.getData(),
          builder: (BuildContext context, AsyncSnapshot<List<Pair<Coupon, Vendor>>> snapshot) {
            return ListView(
              padding: const EdgeInsets.all(12),
              // children: [
              //   //TODO - populate with real coupons from database
              //   CouponWidget(coupon: coupon, couponVendor: vendor),
              //   const SizedBox(
              //     height: 10,
              //   ),
              // ],
              children: (snapshot.data ?? [])
                .map((elem) => [
                    CouponWidget(coupon: elem.first, couponVendor: elem.second),
                    const SizedBox(height: 10)
                  ])
                .expand((element) => element)
                .toList()
            );
          }
        )
      ),
    );
  }
}
