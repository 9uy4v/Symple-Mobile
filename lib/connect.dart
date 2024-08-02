import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:symple_mobile/upload.dart';

class ConnectScreen extends StatefulWidget {
  const ConnectScreen({super.key});

  @override
  State<ConnectScreen> createState() => _ConnectScreenState();
}

class _ConnectScreenState extends State<ConnectScreen> {
  @override
  Widget build(context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
      ),
      body: Center(
        child: Column(
          children: [
            const Spacer(),
            const Text(
              'Connect to your PC',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 28,
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 128),
              child: Container(
                padding: const EdgeInsets.all(8),
                height: MediaQuery.sizeOf(context).height / 2,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: const Color.fromARGB(255, 195, 195, 195),
                ),
                child: ListView.builder(
                  itemCount: 2, // TO DO : get count from found pc's array in provider
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: const Color.fromARGB(255, 255, 255, 255),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(
                              width: 7.5,
                            ),
                            const Text('PC'), // TO DO : get pc details from array and place them here
                            const Spacer(),
                            Transform.rotate(
                              angle: 90 * math.pi / 180,
                              child: IconButton(
                                onPressed: () {
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const UploadScreen(),
                                      ));
                                  // TO DO : connect to said PC
                                },
                                icon: const Icon(Icons.link),
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
