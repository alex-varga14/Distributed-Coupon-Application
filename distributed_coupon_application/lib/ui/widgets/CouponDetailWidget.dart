import 'package:distributed_coupon_application/model/coupon.dart';
import 'package:distributed_coupon_application/model/vendor.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CouponDetailWidget extends StatelessWidget {
  final Coupon coupon;
  final Vendor couponVendor;

  const CouponDetailWidget({
    Key? key,
    required this.coupon,
    required this.couponVendor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          couponVendor.vendorName,
          style: GoogleFonts.roboto(
            fontWeight: FontWeight.normal,
            fontSize: 20,
          ),
        ),
        Text(
          coupon.title,
          style: GoogleFonts.roboto(
            fontWeight: FontWeight.normal,
            fontSize: 28,
          ),
        ),
        Text(
          "Expiry Date: ${coupon.expiryDate.toString().split(".")[0]}",
          style: GoogleFonts.roboto(
            fontWeight: FontWeight.normal,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 10),
        const Image(
          width: 400,
          image: NetworkImage(
              'https://media.istockphoto.com/id/1254508881/photo/woman-holding-sale-shopping-bags-consumerism-shopping-lifestyle-concept.jpg?s=612x612&w=0&k=20&c=wuS3z6nPQkMM3_wIoO67qQXP-hfXkxlBc2sedwh-hxc='),
        ),
        const SizedBox(height: 10),
        Text(
          coupon.description,
          style: GoogleFonts.roboto(
            fontWeight: FontWeight.normal,
            fontSize: 20,
          ),
        ),
      ],
    );
  }
}
