import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:symple_mobile/main.dart';
import 'package:symple_mobile/providers/settings_provider.dart';
import 'package:symple_mobile/screens/files_upload_screen.dart';
import 'package:symple_mobile/widgets/qr_scanner_overlay.dart';
import 'package:symple_mobile/providers/socket_provider.dart';

class ConnectScreen extends StatefulWidget {
  const ConnectScreen({super.key});

  @override
  State<ConnectScreen> createState() => _ConnectScreenState();
}

class _ConnectScreenState extends State<ConnectScreen> {
  bool isScanComplete = false;

  @override
  Widget build(context) {
    publicContext = context;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            // TODO : change ThemeData - Light <-> Dark
            Provider.of<SettingsProvider>(context, listen: false).switchTheme();
          },
          icon: const Icon(Icons.settings),
        ),
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
                          String scannedBarcode =
                              barcodes.barcodes.last.rawValue ?? '---';
                          scannedBarcode != '---'
                              ? isScanComplete = true
                              : debugPrint(
                                  'null code received'); // TODO : delete when validator added
                          // TODO : splash screen while getting ip and establishing connection with pc
                          // TODO : validate barcode
                          print('got a code! : $scannedBarcode');
                          Provider.of<SocketProvider>(context, listen: false)
                              .handleCode(scannedBarcode)
                              .then(
                            (value) {
                              // TODO : exit splash screen
                              if (value) {
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const UploadScreen(),
                                    ));
                              } else {
                                isScanComplete = false;
                                print('can\'t connect to PC');
                                // TODO : show error message
                              }
                            },
                          );
                        }
                      },
                    ),
                  ),
                  QRScannerOverlay(
                      overlayColour: Theme.of(context).scaffoldBackgroundColor),
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
