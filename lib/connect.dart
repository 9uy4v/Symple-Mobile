import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:symple_mobile/qr_scanner_overlay.dart';

class ConnectScreen extends StatefulWidget {
  const ConnectScreen({super.key});

  @override
  State<ConnectScreen> createState() => _ConnectScreenState();
}

class _ConnectScreenState extends State<ConnectScreen> {
  bool isScanComplete = false;

  @override
  Widget build(context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.sizeOf(context).height / 25,
            ),
            const Text(
              'Connect to your PC',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 28,
                letterSpacing: 1,
              ),
            ),
            Expanded(
              flex: 4,
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: MobileScanner(
                      onDetect: (barcodes) {
                        if (!isScanComplete) {
                          String scannedBarcode = barcodes.barcodes.last.rawValue ?? '---';
                          isScanComplete = true;
                          print('got a code! : $scannedBarcode');
                          // TO DO : handle qr code
                          // TO DO : splash screen while getting ip and establishing connection with pc
                        }
                      },
                    ),
                  ),
                  QRScannerOverlay(overlayColour: Theme.of(context).scaffoldBackgroundColor),
                  GestureDetector(
                    onTap: () => isScanComplete = false,
                  ),
                ],
              ),
            ),
            const Expanded(
              flex: 2,
              child: Text(
                'align the qr code on your computer screen with the box',
                textAlign: TextAlign.center,
                style: TextStyle(letterSpacing: 1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
