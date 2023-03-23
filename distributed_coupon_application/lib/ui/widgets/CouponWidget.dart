import 'package:distributed_coupon_application/model/coupon.dart';
import 'package:distributed_coupon_application/model/vendor.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../pages/CouponDetailPage.dart';

class CouponWidget extends StatefulWidget {
  final Coupon coupon;
  final Vendor couponVendor;

  const CouponWidget(
      {super.key, required this.coupon, required this.couponVendor});

  @override
  State<CouponWidget> createState() => _CouponWidgetState();
}

class _CouponWidgetState extends State<CouponWidget> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CouponDetailPage(
                coupon: widget.coupon, couponVendor: widget.couponVendor),
          ),
        ),
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blue[100],
          border: Border.all(color: Colors.black),
        ),
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.couponVendor.vendorName,
                  style: GoogleFonts.roboto(
                    fontWeight: FontWeight.normal,
                    fontSize: 20,
                  ),
                ),
                Text(
                  widget.coupon.title,
                  style: GoogleFonts.roboto(
                    fontWeight: FontWeight.normal,
                    fontSize: 18,
                  ),
                ),
                Text(
                  "Expiry Date: ${widget.coupon.expiryDate.toString().split(' ')[0]}",
                  style: GoogleFonts.roboto(
                    fontWeight: FontWeight.normal,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 20),
            const Image(
              width: 170,
              image: NetworkImage(
                  'https://media.istockphoto.com/id/1254508881/photo/woman-holding-sale-shopping-bags-consumerism-shopping-lifestyle-concept.jpg?s=612x612&w=0&k=20&c=wuS3z6nPQkMM3_wIoO67qQXP-hfXkxlBc2sedwh-hxc='),
            )
          ],
        ),
      ),
    );
  }
}
