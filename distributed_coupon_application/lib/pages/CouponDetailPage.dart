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
      body: Column(
        children: [
          CouponDetailWidget(
              coupon: widget.coupon, couponVendor: widget.couponVendor),
          TextButton(
            child: Text(
              'Redeem',
              style: GoogleFonts.roboto(
                fontWeight: FontWeight.normal,
                fontSize: 25,
              ),
            ),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => RedeemCouponPage(
                          coupon: widget.coupon,
                          couponVendor: widget.couponVendor)));
            },
          ),
        ],
      ),
    );
  }
}
