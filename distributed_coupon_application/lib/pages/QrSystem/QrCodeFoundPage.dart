import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../model/coupon.dart';
import '../../model/vendor.dart';
import '../../ui/widgets/CouponDetailWidget.dart';
import '../../util/pair.dart';
import '../../vm/qrcodefoundpage_vm.dart';

import 'package:loading_indicator/loading_indicator.dart';

class QrCodeFoundPage extends StatefulWidget {
  final int couponId;

  const QrCodeFoundPage({
    Key? key,
    required this.couponId,
  }) : super(key: key);

  @override
  State<QrCodeFoundPage> createState() => _QrCodeFoundPageState();
}

class _QrCodeFoundPageState extends State<QrCodeFoundPage> {
  QrCodeFoundPageVM vm = QrCodeFoundPageVM();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Redeem coupon"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Text(
                "Coupon with ID ${widget.couponId} to redeem:",
                style: GoogleFonts.roboto(
                  fontWeight: FontWeight.normal,
                  fontSize: 18,
                ),
              ),
              FutureBuilder<Pair<Coupon, Vendor>?>(
                future: vm.getCouponVendorPair(widget.couponId),
                builder: (BuildContext context,
                    AsyncSnapshot<Pair<Coupon, Vendor>?> snapshot) {
                  Pair<Coupon, Vendor>? pair = snapshot.data;
                  if (pair != null) {
                    return Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        children: [
                          CouponDetailWidget(
                              coupon: pair.first, couponVendor: pair.second),
                          TextButton(
                            child: Text(
                              'Confirm',
                              style: GoogleFonts.roboto(
                                fontWeight: FontWeight.normal,
                                fontSize: 25,
                                color: Theme.of(context).primaryColor
                              ),
                            ),
                            onPressed: () {
                              //TODO implement redeem logic backend
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Not implemented yet'),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  } else {
                    return const LoadingIndicator(
                      indicatorType: Indicator.ballSpinFadeLoader,
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
