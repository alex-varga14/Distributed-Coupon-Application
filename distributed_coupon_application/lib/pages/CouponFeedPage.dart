import 'package:distributed_coupon_application/model/coupon.dart';
import 'package:distributed_coupon_application/model/vendor.dart';
import 'package:distributed_coupon_application/pages/CreateCouponPage.dart';
import 'package:distributed_coupon_application/ui/widgets/CouponWidget.dart';
import 'package:flutter/material.dart';

class CouponFeedPage extends StatefulWidget {
  const CouponFeedPage({Key? key}) : super(key: key);

  @override
  State<CouponFeedPage> createState() => _CouponFeedPageState();
}

class _CouponFeedPageState extends State<CouponFeedPage> {
  Coupon coupon = Coupon.create(
      id: 1,
      expiryDate: DateTime(2023, 5, 5),
      vendorID: 1,
      title: '10% of all items!',
      description:
          'Lorem ipsum dolor sit amet. Qui enim molestias est veritatis enim est soluta consequatur est rerum accusantium. Et autem distinctio sed fuga placeat in facere illo quo porro voluptatem sed consequatur galisum. Sit possimus doloremque non itaque doloremque qui dolor galisum quo dolor itaque qui voluptatem impedit. Eum velit quos et animi eveniet est tempore Quis?',
      isMultiuse: true);

  Vendor vendor = Vendor.create(
      id: 1, country: 'Canada', city: 'Calgary', vendorName: 'MountainSoapsCO');

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
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            //TODO - populate with real coupons from database
            CouponWidget(coupon: coupon, couponVendor: vendor),
            const SizedBox(
              height: 10,
            ),
            CouponWidget(coupon: coupon, couponVendor: vendor),
            const SizedBox(
              height: 10,
            ),
            CouponWidget(coupon: coupon, couponVendor: vendor),
            const SizedBox(
              height: 10,
            ),
            CouponWidget(coupon: coupon, couponVendor: vendor),
            const SizedBox(
              height: 10,
            ),
            CouponWidget(coupon: coupon, couponVendor: vendor),
            const SizedBox(
              height: 10,
            ),
            CouponWidget(coupon: coupon, couponVendor: vendor),
          ],
        ),
      ),
    );
  }
}
