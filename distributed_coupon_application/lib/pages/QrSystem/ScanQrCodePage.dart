import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'QrCodeFoundPage.dart';

class ScanQrCodePage extends StatefulWidget {
  const ScanQrCodePage({Key? key}) : super(key: key);

  @override
  State<ScanQrCodePage> createState() => _ScanQrCodePageState();
}

class _ScanQrCodePageState extends State<ScanQrCodePage> {
  MobileScannerController cameraController = MobileScannerController();
  bool _screenOpened = false;

  @override
  Widget build(BuildContext context) {
    final scanWindow = Rect.fromCenter(
      center: MediaQuery.of(context).size.center(Offset.fromDirection(33, -38)),
      width: MediaQuery.of(context).size.width * 0.8,
      height: MediaQuery.of(context).size.height * 0.5,
    );

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Scan coupon QR code"),
      ),
      body: Builder(builder: (context) {
        return Stack(
          fit: StackFit.expand,
          children: [
            MobileScanner(
              controller: cameraController,
              onDetect: _foundQrCode,
              scanWindow: scanWindow,
            ),
            CustomPaint(
              painter: ScannerOverlay(scanWindow),
            ),
            SizedBox(
              height: 200,
              width: 200,
              child: CustomPaint(
                painter: MyCustomPainter(frameSFactor: .1, padding: 30),
              ),
            ),
          ],
        );
      }),
    );
  }

  void _foundQrCode(BarcodeCapture barcodeCapture) {
    // open screen
    if (!_screenOpened) {
      final String code = barcodeCapture.barcodes[0].rawValue ?? "-1";
      _screenOpened = true;

      //TODO handle invalid qr code like one that doesnt result in int
     
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              QrCodeFoundPage(couponId: int.parse(code)),
        ),
      );
    }
  }
}

//Class used to draw overlay with cut-out window
class ScannerOverlay extends CustomPainter {
  ScannerOverlay(this.scanWindow);

  final Rect scanWindow;

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPath = Path()..addRect(Rect.largest);
    final cutoutPath = Path()..addRect(scanWindow);

    final backgroundPaint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill
      ..blendMode = BlendMode.dstOut;

    final backgroundWithCutout = Path.combine(
      PathOperation.difference,
      backgroundPath,
      cutoutPath,
    );
    canvas.drawPath(backgroundWithCutout, backgroundPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

//Class used to draw 4 blue border corners
class MyCustomPainter extends CustomPainter {
  final double padding;
  final double frameSFactor;

  MyCustomPainter({
    required this.padding,
    required this.frameSFactor,
  });
  @override
  void paint(Canvas canvas, Size size) {
    final frameHWidth = size.width * frameSFactor;

    Paint paint = Paint()
      ..color = Colors.blue
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.fill
      ..strokeWidth = 4;

    /// top left
    canvas.drawLine(
        Offset(0 + padding, padding * 4),
        Offset(
          padding + frameHWidth,
          padding * 4,
        ),
        paint..color);

    canvas.drawLine(
        Offset(0 + padding, padding * 4),
        Offset(
          padding,
          padding * 4 + frameHWidth,
        ),
        paint..color);

    /// top Right
    canvas.drawLine(Offset(size.width - padding, padding * 4),
        Offset(size.width - padding - frameHWidth, padding * 4), paint..color);
    canvas.drawLine(Offset(size.width - padding, padding * 4),
        Offset(size.width - padding, padding * 4 + frameHWidth), paint..color);

    /// Bottom Right
    canvas.drawLine(
        Offset(size.width - padding, size.height - padding * 4),
        Offset(size.width - padding - frameHWidth, size.height - padding * 4),
        paint..color);
    canvas.drawLine(
        Offset(size.width - padding, size.height - padding * 4),
        Offset(size.width - padding, size.height - padding * 4 - frameHWidth),
        paint..color);

    /// Bottom Left
    canvas.drawLine(
        Offset(0 + padding, size.height - padding * 4),
        Offset(0 + padding + frameHWidth, size.height - padding * 4),
        paint..color);
    canvas.drawLine(
        Offset(0 + padding, size.height - padding * 4),
        Offset(0 + padding, size.height - padding * 4 - frameHWidth),
        paint..color);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
