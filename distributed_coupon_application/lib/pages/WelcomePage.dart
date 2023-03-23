import 'package:distributed_coupon_application/pages/LoginPage.dart';
import 'package:distributed_coupon_application/pages/CouponFeedPage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Center(
              child: Column(
            children: [
              const SizedBox(height: 80),
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
              const SizedBox(height: 10),
              Text(
                'Find great discounts!',
                style: GoogleFonts.roboto(
                  letterSpacing: 0.5,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: 160,
                height: 40,
                child: TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.blueGrey,
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    shadowColor: Colors.grey.withOpacity(0.5),
                  ),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const CouponFeedPage()));
                  },
                  child: Text('Customer',
                      style: GoogleFonts.roboto(
                          fontWeight: FontWeight.normal,
                          fontSize: 18,
                          color: Colors.white)),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: 160,
                height: 40,
                child: TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.blueGrey,
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    shadowColor: Colors.grey.withOpacity(0.5),
                  ),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginPage()));
                  },
                  child: Text(
                    'Vendor',
                    style: GoogleFonts.roboto(
                      fontSize: 18,
                      fontWeight: FontWeight.normal,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          )),
        ),
      ),
    );
  }
}
