import 'package:distributed_coupon_application/vm/createcouponpage_vm.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:result_type/result_type.dart';

import '../model/coupon.dart';
import '../model/vendor.dart';

class CreateCouponPage extends StatefulWidget {
  const CreateCouponPage({Key? key}) : super(key: key);

  @override
  State<CreateCouponPage> createState() => _CreateCouponPageState();
}

class _CreateCouponPageState extends State<CreateCouponPage> {
  Vendor vendor = Vendor();
  Coupon coupon = Coupon();

  CreateCouponPageVM vm = CreateCouponPageVM();

  static const double spacing = 10;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create a coupon"),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(32, 8, 32, 8),
          child: SingleChildScrollView(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Center(
                child: Icon(
                  Icons.card_giftcard_rounded,
                  color: Color.fromARGB(255, 102, 194, 212),
                  size: 100,
                ),
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
                child: TextField(
                  onChanged: (value) {
                    vendor.id = int.parse(value);
                    coupon.vendorID = int.parse(value);
                  },
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.all(8),
                    border: OutlineInputBorder(),
                    hintText: 'Vendor ID',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                ),
              ),
              const SizedBox(height: spacing),
              Text(
                'Coupon Information',
                style: GoogleFonts.roboto(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: spacing),
              SizedBox(
                height: 40,
                child: TextFormField(
                  onChanged: (value) => coupon.title = value,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.all(8),
                    border: OutlineInputBorder(),
                    hintText: 'Coupon Title',
                  ),
                ),
              ),
              const SizedBox(height: spacing),
              SizedBox(
                height: 40,
                child: TextFormField(
                  onChanged: (value) => coupon.description = value,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.all(8),
                    border: OutlineInputBorder(),
                    hintText: 'Coupon Description',
                  ),
                ),
              ),
              const SizedBox(height: spacing),
              SizedBox(
                height: 40,
                child: TextField(
                  onChanged: (value) => coupon.quantity = int.parse(value),
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.all(8),
                    border: OutlineInputBorder(),
                    hintText: 'Coupon Quantity',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Expiry Date:'),
                  TextButton(
                    onPressed: () {
                      _showDateTimePicker();
                    },
                    child: Text(coupon.expiryDate.toString().split('.')[0]),
                  ),
                ],
              ),
              Center(
                child: TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.blueGrey,
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    shadowColor: Colors.grey.withOpacity(0.5),
                  ),
                  onPressed: () async {
                    Result<bool, String> result = await vm.createCoupon(coupon);

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
              ),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessPopupDialog(BuildContext context) {
    return AlertDialog(
      title: const Text('Coupon created'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(coupon.toString()),
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

  void _showDateTimePicker() {
    DatePicker.showDateTimePicker(context,
        showTitleActions: true,
        minTime: DateTime.now(),
        maxTime: DateTime.now().add(const Duration(days: 365)),
        currentTime: DateTime.now(),
        locale: LocaleType.en, onConfirm: (date) {
      setState(() {
        coupon.expiryDate =
            DateTime(date.year, date.month, date.day, date.hour, date.minute);
      });
    });
  }

  void _openCouponFeedPage() {
    Navigator.pop(context);
  }
}
