import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:result_type/result_type.dart';

import '../model/vendor.dart';
import '../vm/vendorregisterpage_vm.dart';

class VendorRegisterPage extends StatefulWidget {
  const VendorRegisterPage({Key? key}) : super(key: key);

  @override
  State<VendorRegisterPage> createState() => _VendorRegisterPageState();
}

class _VendorRegisterPageState extends State<VendorRegisterPage> {
  Vendor vendor = Vendor();

  VendorRegisterPageVM vm = VendorRegisterPageVM();

  static const double spacing = 10;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register as a Vendor'),
      ),
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(32, 18, 32, 18),
          child: SingleChildScrollView(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(
                Icons.app_registration_sharp,
                color: Color.fromARGB(255, 102, 194, 212),
                size: 60,
              ),
              const SizedBox(height: spacing),
              Text(
                'Vendor Information',
                style: GoogleFonts.roboto(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: spacing),
              SizedBox(
                height: 40,
                child: TextFormField(
                  onChanged: (value) => vendor.vendorName = value,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.all(8),
                    border: OutlineInputBorder(),
                    hintText: 'Vendor Name',
                  ),
                ),
              ),
              const SizedBox(height: spacing),
              //TODO implement location auto-fill box (if we want to store exact location of vendor in db)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 40,
                      child: TextFormField(
                        onChanged: (value) => vendor.country = value,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.all(8),
                          border: OutlineInputBorder(),
                          hintText: 'Vendor Country',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: SizedBox(
                      height: 40,
                      child: TextFormField(
                        onChanged: (value) => vendor.city = value,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.all(8),
                          border: OutlineInputBorder(),
                          hintText: 'Vendor City',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: spacing),
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.blueGrey,
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  shadowColor: Colors.grey.withOpacity(0.5),
                ),
                onPressed: () async {
                  //TODO post vendor to database and display some confirmation window
                  Result<bool, String> result = await vm.createVendor(vendor);

                  if (result.isSuccess && result.success) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) =>
                          _buildSuccessPopupDialog(context),
                    ).then(
                      (_) {
                        _openCouponFeedPage();
                      },
                    );
                  } else {
                    String message;
                    if (result.isSuccess) {
                      message = "Server rejected request";
                    } else {
                      message = result.failure;
                    }

                    showDialog(
                      context: context,
                      builder: (BuildContext context) =>
                          _buildErrorPopupDialog(context, message),
                    );
                  }
                },
                child: Text(
                  'CREATE',
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    color: Colors.white,
                  ),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessPopupDialog(BuildContext context) {
    return AlertDialog(
      title: const Text('Vendor created'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(vendor.toString()),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () async {
            Navigator.of(context).pop();
          },
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildErrorPopupDialog(BuildContext context, String message) {
    return AlertDialog(
      title: const Text('Error'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(message),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () async {
            Navigator.of(context).pop();
          },
          child: const Text('Close'),
        ),
      ],
    );
  }

  void _openCouponFeedPage() {
    Navigator.pop(context);
  }
}
