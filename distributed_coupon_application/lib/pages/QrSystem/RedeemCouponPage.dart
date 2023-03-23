import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../model/coupon.dart';
import '../../model/vendor.dart';

class RedeemCouponPage extends StatefulWidget {
  final Coupon coupon;
  final Vendor couponVendor;

  const RedeemCouponPage({
    super.key,
    required this.coupon,
    required this.couponVendor,
  });

  @override
  State<RedeemCouponPage> createState() => _RedeemCouponPageState();
}

class _RedeemCouponPageState extends State<RedeemCouponPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Redeem coupon'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          children: [
            QrImage(
              data: widget.coupon.id.toString(),
            ),
            const SizedBox(
              height: 20,
            ),
            Text(
              "Show code to cashier to redeem",
              style: GoogleFonts.roboto(
                fontWeight: FontWeight.normal,
                fontSize: 18,
              ),
            )
          ],
        ),
      ),
    );
  }
}
