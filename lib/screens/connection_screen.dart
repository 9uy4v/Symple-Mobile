import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as reg_prov;
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:symple_mobile/screens/files_upload_screen.dart';
import 'package:symple_mobile/widgets/qr_scanner_overlay.dart';
import 'package:symple_mobile/providers/socket_provider.dart';

// ignore: must_be_immutable
class ConnectScreen extends ConsumerWidget {
  ConnectScreen({super.key});

  bool isScanComplete = false;

  @override
  Widget build(context, WidgetRef ref) {
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
                          scannedBarcode != '---' ? isScanComplete = true : debugPrint('null code received'); // TO DO : delete when validator added
                          // TO DO : splash screen while getting ip and establishing connection with pc
                          // TO DO : validate barcode
                          print('got a code! : $scannedBarcode');
                          reg_prov.Provider.of<SocketProvider>(context, listen: false).handleCode(scannedBarcode, ref).then(
                            (value) {
                              // TO DO : exit splash screen
                              if (value) {
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const UploadScreen(),
                                    ));
                              } else {
                                isScanComplete = false;
                                print('can\'t connect to PC');
                                // TO DO : show error message
                              }
                            },
                          );
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
