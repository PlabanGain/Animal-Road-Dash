import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/game_state.dart';
import 'screens/main_menu_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => GameState(),
      child: const AnimalRoadDashApp(),
    ),
  );
}

class AnimalRoadDashApp extends StatelessWidget {
  const AnimalRoadDashApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Animal Road Dash',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        primaryColor: const Color(0xFF00FFCC),
        // Modern typography fallbacks
        fontFamily: 'monospace',
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white, letterSpacing: 0.5),
          bodyMedium: TextStyle(color: Colors.white70, letterSpacing: 0.5),
        ),
      ),
      home: const MainMenuScreen(),
    );
  }
}
