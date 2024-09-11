import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:symple_mobile/providers/files_provider.dart';
import 'package:symple_mobile/providers/settings_provider.dart';
import 'package:symple_mobile/providers/socket_provider.dart';
import 'package:symple_mobile/screens/connection_screen.dart';

// TO DO : Fix behaviour after file transfer failure. Test for bugs
// TO DO : Add styling (dark mode?)
// TO DO : border and shadow of uploaded files in dark mode, circular progress bar in dark mode , button colors
// TO DO : Add button for connection/file transfer history?
// TO DO : Flesh out the file transfer screen (Looks too empty). Add outline around box where transfered files show up?

//TO DO : ...more neat features :)

StreamController<ThemeMode> themeMode = StreamController();

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
        ChangeNotifierProvider.value(value: SettingsProvider()),
        ChangeNotifierProvider.value(value: SocketProvider()),
        ChangeNotifierProvider.value(value: FilesProvider()),
      ],
      child: StreamBuilder(
          initialData: ThemeMode.system,
          stream: themeMode.stream,
          builder: (context, snapshot) {
            return MaterialApp(
              title: 'Symple',
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                useMaterial3: true,
                colorScheme: const ColorScheme.light(),
              ),
              darkTheme: ThemeData(
                useMaterial3: true,
                colorScheme: const ColorScheme.dark(
                    surface: Color.fromARGB(255, 18, 18, 18)),
              ),
              themeMode: snapshot.data,
              home: const ConnectScreen(),
            );
          }),
    );
  }
}
