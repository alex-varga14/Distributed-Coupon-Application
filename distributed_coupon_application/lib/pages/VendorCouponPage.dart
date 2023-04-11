import 'package:distributed_coupon_application/model/coupon.dart';
import 'package:distributed_coupon_application/model/vendor.dart';
import 'package:distributed_coupon_application/pages/CreateCouponPage.dart';
import 'package:distributed_coupon_application/ui/widgets/CouponWidget.dart';
import 'package:distributed_coupon_application/vm/couponfeedpage_vm.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:distributed_coupon_application/globals.dart' as globals;

import '../util/pair.dart';
import 'QrSystem/ScanQrCodePage.dart';

class VendorCouponPage extends StatefulWidget {
  const VendorCouponPage({Key? key}) : super(key: key);

  @override
  State<VendorCouponPage> createState() => _VendorCouponPageState();
}

class _VendorCouponPageState extends State<VendorCouponPage> {
  CouponFeedPageVM vm = CouponFeedPageVM();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome, vendor!'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.qr_code_scanner,
              color: Colors.white,
            ),
            onPressed: () async {
              PermissionStatus status = await _getCameraPermission();
              if (status.isGranted) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ScanQrCodePage()));
              }
            },
          ),
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
              }),
        ],
      ),
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: FutureBuilder<List<Pair<Coupon, Vendor>>>(
          future: vm.getCouponsByVendorId(globals.vendorID),
          builder: (BuildContext context,
              AsyncSnapshot<List<Pair<Coupon, Vendor>>> snapshot) {
            if (snapshot.data != null) {
              return ListView(
                  padding: const EdgeInsets.all(12),
                  children: (snapshot.data ?? [])
                      .map((elem) => [
                            Row(children: [
                              const Icon(Icons.business,
                                  color: Colors.black, size: 20),
                              const SizedBox(width: 10),
                              Text(
                                elem.second.vendorName,
                                style: GoogleFonts.roboto(
                                    fontWeight: FontWeight.bold, fontSize: 20),
                              ),
                            ]),
                            CouponWidget(
                                coupon: elem.first, couponVendor: elem.second),
                            const SizedBox(height: 20)
                          ])
                      .expand((element) => element)
                      .toList());
            } else {
              return const LoadingIndicator(
                indicatorType: Indicator.ballSpinFadeLoader,
              );
            }
          },
        ),
      ),
    );
  }

  Future<PermissionStatus> _getCameraPermission() async {
    var status = await Permission.camera.status;
    if (!status.isGranted) {
      final result = await Permission.camera.request();
      return result;
    } else {
      return status;
    }
  }
}
