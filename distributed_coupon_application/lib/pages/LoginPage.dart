import 'package:distributed_coupon_application/pages/VendorRegisterPage.dart';
import 'package:distributed_coupon_application/pages/VendorCouponPage.dart';
import 'package:distributed_coupon_application/vm/loginpage_vm.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:distributed_coupon_application/globals.dart' as globals;

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  LoginPageVM vm = new LoginPageVM();
  final controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Vendor sign-in"),
      ),
      resizeToAvoidBottomInset: false,
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              //Open text
              const Icon(
                Icons.card_giftcard_rounded,
                color: Color.fromARGB(255, 102, 194, 212),
                size: 120,
              ),
              SizedBox(height: 10),
              Text(
                'Welcome back.',
                style: GoogleFonts.roboto(
                  fontWeight: FontWeight.normal,
                  fontSize: 18,
                ),
              ),

              SizedBox(height: 10),
              //Email input
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 35),
                child: Container(
                  constraints: BoxConstraints(minWidth: 150, maxWidth: 250),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],

                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 4,
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      )
                    ],
                    // borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: TextField(
                        controller: controller,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Vendor ID',
                        ),
                        style: TextStyle(fontSize: 20)),
                  ),
                ),
              ),
              SizedBox(height: 25),
              //Sign in
              Container(
                constraints: const BoxConstraints(minWidth: 150, maxWidth: 250),
                child: TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.blueGrey,
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    shadowColor: Colors.grey.withOpacity(0.5),
                  ),
                  onPressed: () async {
                    updateId();
                    bool result =
                        await vm.checkForValidVendorId(globals.vendorID);
                    if (result) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const VendorCouponPage()));
                    }
                  },
                  child: Text(
                    'ENTER PORTAL',
                    style: GoogleFonts.roboto(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 25),

              //Sign up
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Not a registered vendor?',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  TextButton(
                    style:
                        TextButton.styleFrom(foregroundColor: Colors.lightBlue),
                    onPressed: () async {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const VendorRegisterPage()));
                    },
                    child: Text(
                      'Sign up!',
                      style: GoogleFonts.roboto(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Theme.of(context).primaryColor),
                    ),
                  ),
                ],
              )
            ]),
          ),
        ),
      ),
    );
  }

  void updateId() {
    if (int.tryParse(controller.text) != null) {
      globals.vendorID = int.parse(controller.text);
    }
  }
}
