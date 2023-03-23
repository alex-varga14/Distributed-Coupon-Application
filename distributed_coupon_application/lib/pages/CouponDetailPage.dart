import 'package:distributed_coupon_application/model/coupon.dart';
import 'package:distributed_coupon_application/model/vendor.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../ui/widgets/CouponDetailWidget.dart';
import 'QrSystem/RedeemCouponPage.dart';

class CouponDetailPage extends StatefulWidget {
  final Coupon coupon;
  final Vendor couponVendor;

  const CouponDetailPage({
    super.key,
    required this.coupon,
    required this.couponVendor,
  });

  @override
  State<CouponDetailPage> createState() => _CouponDetailPageState();
}

class _CouponDetailPageState extends State<CouponDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Coupon detail'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            CouponDetailWidget(
                coupon: widget.coupon, couponVendor: widget.couponVendor),
            const SizedBox(height: 10),
            SizedBox(
              width: 160,
              height: 40,
              child: TextButton(
                style: TextButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 93, 175, 191),
                    foregroundColor: Colors.white),
                onPressed: () => {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => RedeemCouponPage(
                              coupon: widget.coupon,
                              couponVendor: widget.couponVendor)))
                },
                child: Text(
                  'Redeem',
                  style: GoogleFonts.roboto(
                    fontWeight: FontWeight.normal,
                    fontSize: 24,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
