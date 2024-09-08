import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:symple_mobile/providers/files_provider.dart';
import 'package:symple_mobile/providers/socket_provider.dart';
import 'package:symple_mobile/screens/connection_screen.dart';

// TO DO : Make sure socket connection is closed correctly when pressing Exit button
// TO DO : Fix behaviour after file transfer failure. Test for bugs
// TO DO : Add styling (dark mode?)
// TO DO : Add button for connection/file transfer history?
// TO DO : Flesh out the file transfer screen (Looks too empty). Add outline around box where transfered files show up?
// TO DO : Camera zoom?

//TO DO : ...more neat features :)

void main() {
  runApp(const MyApp());
}

late BuildContext publicContext;

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    publicContext = context;
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: SocketProvider()),
        ChangeNotifierProvider.value(value: FilesProvider()),
      ],
      child: MaterialApp(
        title: 'Symple',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const ConnectScreen(),
      ),
    );
  }
}
