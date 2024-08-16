import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:symple_mobile/providers/files_provider.dart';
import 'package:symple_mobile/providers/socket_provider.dart';
import 'package:symple_mobile/screens/connection_screen.dart';

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
