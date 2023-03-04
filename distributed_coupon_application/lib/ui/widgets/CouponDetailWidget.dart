import 'package:distributed_coupon_application/model/coupon.dart';
import 'package:distributed_coupon_application/model/vendor.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CouponDetailWidget extends StatefulWidget {
  final Coupon coupon;
  final Vendor couponVendor;

  const CouponDetailWidget({
    super.key,
    required this.coupon,
    required this.couponVendor,
  });

  @override
  State<CouponDetailWidget> createState() => _CouponDetailWidgetState();
}

class _CouponDetailWidgetState extends State<CouponDetailWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Coupon detail'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              Text(
                widget.couponVendor.vendorName,
                style: GoogleFonts.roboto(
                  fontWeight: FontWeight.normal,
                  fontSize: 25,
                ),
              ),
              Text(
                widget.coupon.title,
                style: GoogleFonts.roboto(
                  fontWeight: FontWeight.normal,
                  fontSize: 20,
                ),
              ),
              Text(
                "Expiry Date: ${widget.coupon.expiryDate.toString().split(".")[0]}",
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
                widget.coupon.description,
                style: GoogleFonts.roboto(
                  fontWeight: FontWeight.normal,
                  fontSize: 18,
                ),
              ),
              TextButton(
                onPressed: () => {
                  //TODO - implement redeem button
                },
                child: Text(
                  'Redeem',
                  style: GoogleFonts.roboto(
                    fontWeight: FontWeight.normal,
                    fontSize: 25,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
