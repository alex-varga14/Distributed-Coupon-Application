import 'package:distributed_coupon_application/pages/VendorRegisterPage.dart';
import 'package:distributed_coupon_application/vm/createcouponpage_vm.dart';
import 'package:flutter/material.dart';
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
        backgroundColor: const Color.fromARGB(255, 93, 175, 191),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(32, 8, 32, 8),
          child: SingleChildScrollView(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Center(
                child: Text(
                  'Create a coupon',
                  style: GoogleFonts.roboto(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
              ),
              const Center(
                child: Icon(
                  Icons.card_giftcard_rounded,
                  color: Color.fromARGB(255, 102, 194, 212),
                  size: 50,
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
                child: TextFormField(
                  onChanged: (value) {
                    vendor.id = int.parse(value);
                    coupon.vendorID = int.parse(value);
                  },
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.all(8),
                    border: OutlineInputBorder(),
                    hintText: 'Vendor ID',
                  ),
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
                child: TextFormField(
                  onChanged: (value) => coupon.description = value,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.all(8),
                    border: OutlineInputBorder(),
                    hintText: 'Coupon Quantity',
                  ),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('Is Multiuse?',
                      style: GoogleFonts.roboto(
                        fontSize: 16,
                      )),
                  Checkbox(
                    checkColor: Colors.white,
                    value: coupon.isMultiuse,
                    onChanged: (bool? value) {
                      setState(() {
                        coupon.isMultiuse = value!;
                      });
                    },
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
                    //TODO post coupon to database and display some confirmation window
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
          Text(vendor.toString()),
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
        onConfirm: (date) {
      DatePicker.showTimePicker(context, showTitleActions: true,
          onConfirm: (date) {
        setState(() {
          coupon.expiryDate = DateTime(
              coupon.expiryDate.year,
              coupon.expiryDate.month,
              coupon.expiryDate.day,
              date.hour,
              date.minute);
        });
      }, currentTime: DateTime.now(), locale: LocaleType.en);
      setState(() {
        coupon.expiryDate = date;
      });
    }, currentTime: DateTime.now(), locale: LocaleType.en);
  }

  void _openCouponFeedPage() {
    Navigator.pop(context);
  }
}
