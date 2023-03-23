import 'package:distributed_coupon_application/pages/LoginPage.dart';
import 'package:distributed_coupon_application/pages/CouponFeedPage.dart';
import 'package:distributed_coupon_application/ui/widgets/CouponWidget.dart';
import 'package:distributed_coupon_application/vm/couponfeedpage_vm.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../util/pair.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 239, 237, 237),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Center(
              child: Column(
            //mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: 80),
              Text(
                'Distributed Coupon Application',
                textAlign: TextAlign.center,
                style: GoogleFonts.roboto(
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                ),
              ),
              const Icon(
                Icons.card_giftcard_rounded,
                color: Color.fromARGB(255, 102, 194, 212),
                size: 120,
              ),
              SizedBox(height: 10),
              Text(
                'Find great discounts!',
                style: GoogleFonts.roboto(
                  letterSpacing: 0.5,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              SizedBox(height: 16),

              //Spacer(flex: 1),
              SizedBox(
                width: 160,
                height: 40,
                child: TextButton(
                  style: TextButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 93, 175, 191),
                      foregroundColor: Colors.white),
                  onPressed: () async {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const CouponFeedPage()));
                  },
                  child: Text('Customer',
                      style: GoogleFonts.roboto(
                        fontWeight: FontWeight.normal,
                        fontSize: 24,
                      )),
                ),
              ),
              SizedBox(height: 16),
              //Spacer(flex: 1),
              SizedBox(
                width: 160,
                height: 40,
                child: TextButton(
                  style: TextButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 93, 175, 191),
                      foregroundColor: Colors.white),
                  onPressed: () async {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginPage()));
                  },
                  child: Text(
                    'Vendor',
                    style: GoogleFonts.roboto(
                      fontWeight: FontWeight.normal,
                      fontSize: 24,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              //Spacer(flex: 10),
            ],
          )),
        ),
      ),
    );
  }
}
