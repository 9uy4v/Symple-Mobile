import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:symple_mobile/providers/files_provider.dart';
import 'package:symple_mobile/providers/settings_provider.dart';
import 'package:symple_mobile/providers/socket_provider.dart';
import 'package:symple_mobile/screens/connection_screen.dart';

// TODO : Add timeout to file uploading
// TODO : Add button for connection/file transfer history?
// TODO : When selecting files from the cloud (drive/photos), the app returns to the add file screen before these items are downloaded. Must add a loading screen for this time intervall.

// UI :
// TODO : design together a theme for the app- both pc and mobile.
// TODO : Flesh out the file transfer screen (Looks too empty). Add outline around box where transfered files show up?

//TODO : ...more neat features :)

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
                  surface: Color.fromARGB(255, 32, 32, 32),
                  // surfaceContainer: Color.fromARGB(255, 35, 35, 35),
                ),
              ),
              themeMode: snapshot.data,
              home: const ConnectScreen(),
            );
          }),
    );
  }
}
